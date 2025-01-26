# #
# //  registration.py
# //  Team8-Fundus-Photography
# //
# //  Created by chelsea maramot on 2025-01-24.
# //

'''
Consists of incremental search, offset calculation, MODE matching and multi-sequence image fusion.
1.) Extract feature points and match by incremental search
2.) Eliminate mismatched points by calculating by MODE to complete accurate matching of feature points
3.) Calculate the offset of feature point pairs to obtain geometric relations between reference images and target images
4.) Achieve multi-sequence stitching image.
'''

import cv2
from collections import Counter


# feature extraction using SURF (Speeded-Up Robust Features)
# https://www.youtube.com/watch?v=PBTrwymDVCg
# SURF uses Hessian matrix to detect points of interest in an image.
# returns keypoints and descriptors. 
# keypoints are the points of interest in the image
# descriptors are the vectors that describe the keypoints. these contain encoded info about the appearance of pixels around that keypoint
def SURF(image, threshold=400):
    surf = cv2.xfeatures2d.SURF_create(threshold)
    kp, des = surf.detectAndCompute(image, None)

    return kp, des


def feature_matching_with_mode(h, w, kp1, kp2, des1, des2, mode='horizontal', threshold=0.7):

    # use brute force matcher to match features -> might need to change this
    bf = cv2.BFMatcher(cv2.NORM_L2, crossCheck=True)
    matches = bf.match(des1, des2)

    # Sort matches based on distance
    matches = sorted(matches, key=lambda x: x.distance)
    matches = [m for m in matches if m.distance <= threshold]

    #   Compute dx, dy offsets
    dx_list, dy_list = [], []
    for match in matches:

        # Get matching keypoints
        pt1 = kp1[match.queryIdx].pt  # (x1, y1) in img1
        pt2 = kp2[match.trainIdx].pt  # (x2, y2) in img2

        x1, y1 = int(pt1[0]), int(pt1[1])
        x2, y2 = int(pt2[0]), int(pt2[1])

       
        if mode == 'horizontal':
            dx = w - x1 + x2
            dy = y1 - y2
        elif mode == 'vertical':
            dx = x1 - x2
            dy = h - y1 + y2
        else:
            raise ValueError("Mode must be 'horizontal' or 'vertical'")
        
        dx_list.append(dx)
        dy_list.append(dy)


    '''
    We record the offset (dx and dy) according to the position of the corresponding feature, which is the most frequent value in the data
    '''
    most_common_dx = Counter(dx_list).most_common(1)[0][0]
    most_common_dy = Counter(dy_list).most_common(1)[0][0]

    
    return most_common_dx, most_common_dy


# Initial orientation indicates the stitching orientation of the consecutive partial images. The parameter ranges from 1 to 4
# 1 represents the first picture is above the second picture; 2 expresses the first picture is beneath the second picture, and so on.
# P is the stitching direction of the next sequence of fragments with value -1, 0 or 1
# When P equals -1, d2 is rotated 90° counterclockwise in the d1 direction. If P equals 0, d1 and d2 are in the same direction. When P is equivalent to 1, the algorithm rotates d1 clockwise by 90 degrees to form d2
# feature_search_length is the search length of the feature point.
def incremental_search(image1, image2, initial_orientation, feature_search_length=0.2, threshold=0.6):


    h,w = image1.shape[:2]
    search_length = int(feature_search_length * h)
    max_search_length = int(threshold * h)

    while search_length < max_search_length:

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

        # compare the matched features
        if des1 is not None and des2 is not None:
            try:
                dx, dy = feature_matching_with_mode(h, w, kp1, kp2, des1, des2, mode='horizontal' if initial_orientation in [3, 4] else 'vertical')

                return dx, dy
            except Exception as e:
                print(f"Matching failed: {e}")

        # Modify the initial orientation and search length
        initial_orientation = (initial_orientation % 4) + 1
        search_length *= 2

    print("These retinal images registration cannot be matched successfully.")
    return None, None
