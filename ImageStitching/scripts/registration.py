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
    def __init__(self, images, detector: FeatureDetector, matcher: FeatureMatcher, ratio=0.7, threshold=300):

        if not isinstance(images, list):
            raise ValueError("Images must be a list of images")
        
        self.images = images
        self.ratio = ratio
        self.threshold = threshold
        self.detector = detector
        self.matcher = matcher
        self.matches = []



    def register_two_images(self, image1, image2):

        # find keypoints
        kp1, desc1 = self.detector.detect_and_compute(image1)
        kp2, desc2 = self.detector.detect_and_compute(image2)

        # match image features
        self.matches = self.matcher.match_features(desc1, desc2, k=2)
        good_matches = self.matcher.filter_matches_by_ratio(self.matches)
        
        self.matcher.draw_matches_and_save(image1, image2, kp1, kp2, good_matches)

        H, mask = self.matcher.apply_ransac(kp1,kp2, good_matches)

        # warper = ImageWarper(image1, image2, H)
        # warped_img = warper.warp_image()

        # warper.save_warped_image(warped_img)

        return H, mask






