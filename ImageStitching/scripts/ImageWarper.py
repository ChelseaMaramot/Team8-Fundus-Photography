import cv2
import numpy as np
import os

class ImageWarper:
    def __init__(self, images, homographies=None):
        self.images = images
        self.homographies = homographies

    def warp_images(self):
        if self.homographies is None:
            raise ValueError("Homography matrix must be provided before warping.")
        
        warped_images = []

        for i in range(1, len(self.images)):
            image = self.images[i]
            H = self.homographies[i-1] 
            warped_image = self.apply_warping(image.get_data(), H)
            warped_images.append(warped_image)

        return warped_images
    
    def apply_warping(self, image, H):
        
        height, width = image.shape[:2]
        warped_image = cv2.warpPerspective(image, H, (width, height))

        return warped_image

    def show_warped_image(self, warped_images):
        combined_image = np.hstack(warped_images)
        cv2.imshow("Original and Warped Image", combined_image)
        cv2.waitKey(0)
        cv2.destroyAllWindows()

    def save_warped_image(self, warped_img, folder_name, save_dir="./data/warped/"):
    
        warped_filename = f"{folder_name}/{folder_name}.jpg"
        save_path = os.path.join(save_dir, warped_filename)

        print("Saving warped image in ", save_path)
        cv2.imwrite(save_path, warped_img)



    
    
