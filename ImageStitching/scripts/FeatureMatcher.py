import cv2
import numpy as np

class FeatureMatcher:
    def __init__(self, matcher_type="BF", ratio=0.8):
        self.matcher_type = matcher_type
        self.ratio = ratio
        self.matcher = self.create_matcher(matcher_type)


    def create_matcher(self, matcher_type):
        if matcher_type == "BF":
            return self.create_bf_matcher()
        elif matcher_type == "FLANN":
            return self.create_flann_matcher()
        else:
            raise ValueError(f"Unknown matcher type: {matcher_type}")
    

    def create_bf_matcher(self):
        return cv2.BFMatcher(cv2.NORM_L2)
    

    def create_flann_matcher(self):
        index_params = dict(algorithm=1, trees=10)
        search_params = dict(checks=50)
        return cv2.FlannBasedMatcher(index_params, search_params)


    def match_features(self, descriptor1, descriptor2, k=2):
        if descriptor1 is None or descriptor2 is None:
            raise ValueError("Cannot match features: One of the descriptors is None")
        
        if self.matcher_type == "FLANN":
            descriptor1 = np.float32(descriptor1)
            descriptor2 = np.float32(descriptor2)
        
        if k == 1:
            return self.matcher.match(descriptor1, descriptor2)
        else:
            return self.matcher.knnMatch(descriptor1, descriptor2, k=k)


    def filter_matches_by_ratio(self, matches):
        good_matches = []
        for m, n in matches:
            if m.distance < self.ratio * n.distance:
                good_matches.append(m)
        return good_matches
    

    def apply_ransac(self, kp1, kp2, matches):
        points1 = np.float32([kp1[m.queryIdx].pt for m in matches])
        points2 = np.float32([kp2[m.queryIdx].pt for m in matches])

        H, mask = cv2.findHomography(points1, points2, cv2.RANSAC, 5.0)
        return H, mask


    def draw_matches_and_save(self, image1, image2, kp1, kp2, matches, save_path="./data/matched_image.jpg"):
            match_image = cv2.drawMatches(image1, kp1, image2, kp2, matches, None, flags=cv2.DrawMatchesFlags_NOT_DRAW_SINGLE_POINTS)
        
            cv2.imwrite(save_path, match_image)
            print(f"Image with matches saved to {save_path}")


