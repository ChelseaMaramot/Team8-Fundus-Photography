import cv2
import numpy as np
import os

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
        # points1 = np.float32([kp1[m.queryIdx].pt for m in matches])
        # points2 = np.float32([kp2[m.queryIdx].pt for m in matches])


        points1 = []
        points2 = []
        for m in matches:
            # if m.queryIdx < len(kp1) and m.trainIdx < len(kp2):
            points1.append(kp1[m.queryIdx].pt)
            points2.append(kp2[m.trainIdx].pt)

        H, mask = cv2.findHomography(np.float32(points1), np.float32(points2), cv2.RANSAC, 5.0)

        if H is None or mask is None:
            print("Homography computation failed")
            return None, None

        return H, mask
    

    def draw_ransac_matches_and_save(self, image1, kp1, image2, kp2, matches, mask, folder_name, save_dir="./data/matched/"):
        img1_data = image1.get_data()
        img2_data = image2.get_data()
        match_filename = f"{folder_name}/{os.path.splitext(image1.get_name())[0]}_{os.path.splitext(image2.get_name())[0]}.jpg"
        save_path = os.path.join(save_dir, match_filename)

        mask = mask.ravel().tolist()
        
        inlier_matches = [m for i, m in enumerate(matches) if mask[i]]
        
        img_matches = cv2.drawMatches(img1_data, kp1, img2_data, kp2, inlier_matches, None,
                                    matchColor=(0, 255, 0), 
                                    singlePointColor=(255, 0, 0), 
                                    flags=cv2.DrawMatchesFlags_NOT_DRAW_SINGLE_POINTS)
        

        cv2.imwrite(save_path, img_matches)
        print(f"Image with matches saved to {save_path}")
                
        return img_matches



    def draw_matches_and_save(self, image1, image2, kp1, kp2, matches, folder_name, save_dir="./data/matched/"):
            
            img1_data = image1.get_data()
            img2_data = image2.get_data()
            match_filename = f"{folder_name}/{os.path.splitext(image1.get_name())[0]}_{os.path.splitext(image2.get_name())[0]}.jpg"
            save_path = os.path.join(save_dir, match_filename)

            match_image = cv2.drawMatches(img1_data, kp1, img2_data, kp2, matches, None, flags=cv2.DrawMatchesFlags_NOT_DRAW_SINGLE_POINTS)
        
            cv2.imwrite(save_path, match_image)
            print(f"Image with matches saved to {save_path}")


