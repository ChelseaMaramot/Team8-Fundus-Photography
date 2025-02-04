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

import FeatureDetector 
import FeatureMatcher
from ImageWarper import ImageWarper


class Registration:
    def __init__(self, images,folder, detector: FeatureDetector, matcher: FeatureMatcher, ratio=0.7, threshold=300):

        if not isinstance(images, list):
            raise ValueError("Images must be a list of images")
        
        self.images = images
        self.ratio = ratio
        self.threshold = threshold
        self.detector = detector
        self.matcher = matcher
        self.matches = []
        self.folder = folder


    # def create_connectivity_matrix(images):
    #     N = len(images)
    #     connectivity_matrix = np.zeros((N, N))

    #     for i in range(N):
    #         for j in range(i + 1, N):  # Avoid redundant pairs (i,j) and (j,i)
    #             num_matches = match_keypoints(images[i], images[j])
    #             connectivity_matrix[i, j] = num_matches
    #             connectivity_matrix[j, i] = num_matches  # Symmetric matrix

    #     return connectivity_matrix


    # find image with highest sum of total key point matches wrt all other images
    def select_anchor_image(connectivity_matrix):
        N = len(connectivity_matrix)
        min_connections = float('inf')
        anchor_image_index = -1

        for i in range(N):
            num_connections = np.sum(connectivity_matrix[i, :] > 0)  # Count non-zero connections
            if num_connections < min_connections:
                min_connections = num_connections
                anchor_image_index = i
    
        return anchor_image_index
    

    def register_images(self):
        homographies = []

        for i in range(1, len(self.images)):
            image1 = self.images[i-1]
            image2 = self.images[i]

            H, mask = self.register_two_images(image1, image2)
            homographies.append(H)

        return homographies


    def register_two_images(self, image1, image2):
        img1_data = image1.get_data() 
        img2_data = image2.get_data() 

        kp1, desc1 = self.detector.detect_and_compute(img1_data)
        kp2, desc2 = self.detector.detect_and_compute(img2_data)

        # match image features
        self.matches = self.matcher.match_features(desc1, desc2, k=2)
        good_matches = self.matcher.filter_matches_by_ratio(self.matches)
        self.matches = good_matches
        
        #self.matcher.draw_matches_and_save(image1, image2, kp1, kp2, good_matches, self.folder)

        H, mask = self.matcher.apply_ransac(kp1,kp2, good_matches)

        self.matcher.draw_ransac_matches_and_save(image1, kp1, image2, kp2, self.matches, mask, self.folder)



        # warper = ImageWarper(image1, image2, H)
        # warped_img = warper.warp_image()

        # warper.save_warped_image(warped_img)

        return H, mask






