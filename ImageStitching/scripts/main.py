#
# //  main.py
# //  Team8-Fundus-Photography
# //
# //  Created by chelsea maramot on 2025-01-24.
# //

import cv2
import os


from FeatureDetector import FeatureDetector
from FeatureMatcher import FeatureMatcher
from Registration import Registration
from Preprocess import Preprocessing
from Image import Image
from ImageWarper import ImageWarper


def load_image(image_path):
    if not os.path.exists(image_path):
        raise FileNotFoundErrors(f"Image not found at path: {image_path}")
    return cv2.imread(image_path)  

def register_images(image_list):
    feature_detector = FeatureDetector(detector_type="SIFT") 
    feature_matcher = FeatureMatcher(matcher_type='BF', ratio=0.8)

    registration = Registration(image_list,feature_detector, feature_matcher, ratio=0.7, threshold=300)
    return registration.register_images()


def warp_with_homography(original_image1, original_image2, H):
    warper = ImageWarper(original_image1, original_image2, H)
    warped_image = warper.warp_image()
    warper.save_warped_image(warped_image)
    return warped_image


def preprocess_image(img_obj, processed_path):
    img_data = img_obj.get_data()
    processed_img_data = Preprocessing.process_retinal_image(img_data)
    processed_img_obj = Image(image_data=processed_img_data, image_path=processed_path)
    return processed_img_obj



def main(data_folder_path):

    input_folder_path = os.path.join(data_folder_path, "input")
    matched_folder_path = os.path.join(data_folder_path, "matched")
    processed_folder_path = os.path.join(data_folder_path, "processed")
    warped_folder_path = os.path.join(data_folder_path, "warped")
                                      
    subfolders = [f.path for f in os.scandir(input_folder_path) if f.is_dir()]
    
    for subfolder in subfolders:
        subfolder_name = os.path.basename(subfolder)

        matched_subfolder_path = os.path.join(matched_folder_path, subfolder_name)
        processed_subfolder_path = os.path.join(processed_folder_path, subfolder_name)
        warped_subfolder_path = os.path.join(warped_folder_path, subfolder_name)

        os.makedirs(matched_subfolder_path, exist_ok=True)
        os.makedirs(processed_subfolder_path, exist_ok=True)
        os.makedirs(warped_subfolder_path, exist_ok=True)
        
        images_in_subfolder = [f for f in os.listdir(subfolder) if f.endswith(('.jpg', '.png'))]
        
        processed_images = []
        for img in images_in_subfolder:
            img_path = os.path.join(subfolder, img)
            img_obj = Image(image_path=img_path)
            processed_path = os.path.join(processed_subfolder_path, img)
            processed_img_obj = preprocess_image(img_obj, processed_path)  
            
            if processed_img_obj:
                processed_images.append(processed_img_obj)
                processed_img_obj.save(processed_path)
            
        # Registration
        feature_detector = FeatureDetector(detector_type="SIFT")
        feature_matcher = FeatureMatcher(matcher_type='BF', ratio=0.8)

        registration = Registration(processed_images, subfolder_name, feature_detector, feature_matcher, ratio=0.7, threshold=300)
        homographies = registration.register_images()
        
        # Apply warping to the images
        image_warper = ImageWarper(processed_images, homographies)
        warped_images = image_warper.warp_images()
        
        # Save the warped images into the output folder
        for i, warped_image in enumerate(warped_images):
            image_warper.save_warped_image(warped_image, subfolder_name)
            

if __name__ == "__main__":
    input_path= './data/input'
    output_path = './data/output'
    main('./data')
