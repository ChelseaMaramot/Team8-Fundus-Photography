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

def register_images(image1, image2):
    feature_detector = FeatureDetector(detector_type="SIFT") 
    feature_matcher = FeatureMatcher(matcher_type='BF', ratio=0.8)
    registration = Registration([image1, image2],feature_detector, feature_matcher, ratio=0.7, threshold=300)
    return registration.register_two_images(image1, image2)


def warp_with_homography(original_image1, original_image2, H):
    warper = ImageWarper(original_image1, original_image2, H)
    warped_image = warper.warp_image()
    warper.save_warped_image(warped_image)
    return warped_image


def preprocess_image(img_obj):
    img_data = img_obj.get_data()
    processed_img_data = Preprocessing.process_retinal_image(img_data)
    processed_img_obj = Image(image_data=processed_img_data)
    return processed_img_obj


def main(input_folder_path, output_folder_path):
    input_images = [f for f in os.listdir(input_folder_path)]
    input_images_read = []
    
    for img in input_images:
        input_image_path = os.path.join(input_folder_path, img)
        input_images_read.append(cv2.imread(input_image_path))
        output_image_path = os.path.join(output_folder_path, img)
   
        # image preprocessing
        img_obj = Image(image_path = input_image_path)
        processed_img_obj = preprocess_image(img_obj)

        if processed_img_obj:
            processed_img_obj.save(output_image_path)
            print(f"Processed and saved image: {output_image_path}")

    # registration
    output_images_name = [f for f in os.listdir(input_folder_path)]
    output_images_read = []
    for img in output_images_name:
        output_image_path = os.path.join(output_folder_path, img)
        output_images_read.append(cv2.imread(output_image_path))

    H, mask = register_images(output_images_read[0], output_images_read[1])
    warped_image = warp_with_homography(input_images_read[0], input_images_read[1], H)
    

if __name__ == "__main__":
    input_path= './data/input'
    output_path = './data/output'
    main(input_path, output_path)
