# #
# //  registration.py
# //  Team8-Fundus-Photography
# //
# //  Created by chelsea maramot on 2025-01-24.
# //

#Good unused src: https://kushalvyas.github.io/stitching.html


'''
Consists of incremental search, offset calculation, MODE matching and multi-sequence image fusion.
1.) Extract feature points and match by incremental search
2.) Eliminate mismatched points by calculating by MODE to complete accurate matching of feature points
3.) Calculate the offset of feature point pairs to obtain geometric relations between reference images and target images
4.) Achieve multi-sequence stitching image.
'''

import cv2
import numpy as np
from collections import Counter
import os
import matplotlib.pyplot as plt

# feature extraction using SURF (Speeded-Up Robust Features)
# https://www.youtube.com/watch?v=PBTrwymDVCg
# SURF uses Hessian matrix to detect points of interest in an image.
# returns keypoints and descriptors. 
# keypoints are the points of interest in the image
# descriptors are the vectors that describe the keypoints. these contain encoded info about the appearance of pixels around that keypoint
def SURF(image, threshold=300):
    surf = cv2.xfeatures2d.SURF_create(threshold)
    kp, des = surf.detectAndCompute(image, None)

    return kp, des


# https://docs.opencv.org/4.x/dc/dc3/tutorial_py_matcher.html
def match_features(des1, des2, threshold=0.7):
    index_params = dict(algorithm=1, trees=5)
    search_params = dict(checks=50)

    flann = cv2.FlannBasedMatcher(index_params, search_params)
    matches = flann.knnMatch(des1, des2, k=2)

    good_matches = []
    for i,(m, n) in enumerate(matches):
        if m.distance < threshold * n.distance:
            good_matches.append(m)

    return good_matches



def match_features_bf(des1, des2, threshold=0.7):
   
    bf = cv2.BFMatcher(cv2.NORM_L2, crossCheck=True)
    matches = bf.knnMatch(des1, des2, k=2)

    good_matches = []
    for m, n in matches:
        if m.distance < threshold * n.distance:
            good_matches.append(m)

    return good_matches


def calculate_offset(h,w, x1, y1, x2, y2, mode='horizontal'):

    if mode == 'horizontal':
        dx = x1 + x2
        dy = y1 - y2
    elif mode == 'vertical':
        dx = x1 - x2
        dy = y1 + y2
    else:
        raise ValueError("Mode must be 'horizontal' or 'vertical'")
    
    return dx, dy
        

def get_mode(list):
    return Counter(list).most_common(1)[0][0]
   


# Initial orientation indicates the stitching orientation of the consecutive partial images. The parameter ranges from 1 to 4
# 1 represents the first picture is above the second picture; 2 expresses the first picture is beneath the second picture, and so on.
# P is the stitching direction of the next sequence of fragments with value -1, 0 or 1
# When P equals -1, d2 is rotated 90° counterclockwise in the d1 direction. If P equals 0, d1 and d2 are in the same direction. When P is equivalent to 1, the algorithm rotates d1 clockwise by 90 degrees to form d2
# feature_search_length is the search length of the feature point.
def incremental_search(image1, image2, initial_orientation, feature_search_length=0.2, threshold=0.6):


    h,w = image1.shape[:2]
    search_length = int(feature_search_length * h)
    max_search_length = int(threshold * h)
    dx_list = []
    dy_list = []

    while search_length <= max_search_length:

        # get search regions
        if initial_orientation == 1: #image 2 below image 1
            region1 = image1[-search_length, :] # bottom part of image 1
            region2 = image2[:search_length, :] # top part of image2
        elif initial_orientation == 2: #image 2 above image 1
            region1 = image1[:search_length, :]
            region2 = image2[-search_length:, :]
        elif initial_orientation == 3: #image 2 to the right of image 1
            region1 = image1[:, -search_length:]
            region2 = image2[:, :search_length]
        elif initial_orientation == 4:  #image 2 to the left of image 1
            region1 = image1[:, :search_length]
            region2 = image2[:, -search_length]
        else:
            raise ValueError("Invalid initial orientation. Must be 1, 2, 3, or 4.")

        # search and match features
        kp1, des1 = SURF(region1)
        kp2, des2 = SURF(region2)

        matches = match_features(des1, des2)

        if len(matches) > 15:
            print("Orientation", initial_orientation)
            print("Matches found: ", len(matches))
            matched_image = cv2.drawMatches(image1, kp1, image2, kp2, matches, None, flags=cv2.DrawMatchesFlags_NOT_DRAW_SINGLE_POINTS)
            matched_image = cv2.resize(matched_image, (960, 540)) 


            output_path = os.path.join('./data/', 'matched_img.jpg')
            os.makedirs(os.path.dirname(output_path), exist_ok=True)
            cv2.imwrite(output_path, matched_image)
            #cv2.imshow("Matched Features", matched_image)
            #cv2.waitKey(0)

            for match in matches:
                pt1 = kp1[match.queryIdx].pt  # (x1, y1) in img1
                pt2 = kp2[match.trainIdx].pt  # (x2, y2) in img2

                x1, y1 = int(pt1[0]), int(pt1[1])
                x2, y2 = int(pt2[0]), int(pt2[1])

                dx, dy = calculate_offset(h,w, x1, y1, x2, y2, mode='horizontal' if initial_orientation in [3, 4] else 'vertical')
                dx_list.append(dx)
                dy_list.append(dy)
        else:
            print("Not enough matches found")

        print("Readjusting search window...")
        initial_orientation = (initial_orientation % 4) + 1
        search_length *= 2

    if len(dx_list) == 0 or len(dy_list) == 0:
        print("No matches found. Exiting...")
        return None

  
    return get_mode(dx_list), get_mode(dy_list)


def ignore_black_bg(image):
    mask = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY) > 0
    rgba_image = cv2.cvtColor(image, cv2.COLOR_BGR2BGRA) 
    rgba_image[:, :, 3] = np.uint8(mask * 255)

    return rgba_image

def stitch_image(image1, image2, offset):

    image1 = ignore_black_bg(image1)
    image2 = ignore_black_bg(image2)

    h1, w1 = image1.shape[:2]
    h2, w2 = image2.shape[:2]

    dx, dy = offset

    stitched_height = 4*max(h1,h2)
    stitched_width = 4*max(w1,w2)

    print("stitched_height: ", stitched_height)
    print("stitched_width: ", stitched_width)

    #canvas
    stitched_image = np.zeros((stitched_height, stitched_width, 4), dtype=image1.dtype)


    print("h1, w1: ", h1, w1)
    print("h2, w2: ", h2, w2)
    print("dx, dy: ", dx, dy)

    # Calculate the position to place the first image in the middle of the canvas
    y_center = (stitched_height - h1) // 2
    x_center = (stitched_width - w1) // 2

    stitched_image[y_center:y_center + h1, x_center:x_center + w1] = image1

    print("start y: ", y_center+dy)
    print("end y: ", y_center+dy+h2)  
    print("start x: ", x_center+dx)
    print("end x: ", x_center+dx+w2)

    non_transparent_mask = image2[:, :, 3] != 0  # Non-transparent pixels in image2

    image2_rgba = np.dstack((image2[:, :, :3], image2[:, :, 3]))

    # Use the mask to place non-transparent pixels from image2 onto the stitched_image
    stitched_image[y_center + dy:y_center + dy + h2, x_center + dx:x_center + dx + w2][non_transparent_mask] = image2_rgba[:, :, :][non_transparent_mask]


    
    #cv2.imshow("Stitched Image", stitched_image)
    output_path = os.path.join('./data/', 'stitched_img.jpg')
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    cv2.imwrite(output_path, stitched_image)

    #cv2.waitKey(0)

    return stitched_image