import cv2
import numpy as np
import os

class ImageWarper:
    def __init__(self, images, homographies=None):
        self.images = images
        self.warped_images = []
        self.stitched_image = None
        self.homographies = homographies

    def warp_images(self):
        if self.homographies is None:
            raise ValueError("Homography matrix must be provided before warping.")
        
        warped_images = []

        # apply homography on 2
        for i in range(1, len(self.images)):
            image = self.images[i]
            H = self.homographies[i-1] 
            warped_image = self.apply_warping(image.get_data(), H)
            warped_images.append(warped_image)
        
        self.warped_images = warped_images

        return warped_images
    
    def apply_warping(self, image, H):
        
        height, width = image.shape[:2] 
        warped_image = cv2.warpPerspective(image, H, (width, height))

        return warped_image
    
    def stitch_images(self):
        # the first img is our base img for now
        print("stiching images...")
        base_image = self.images[0].get_data()
        
        for warped_image in self.warped_images:
            base_image = self.blend_images(base_image, warped_image)

        self.stitched_image = base_image
        return base_image
    
    def blend_images(self, base_image, warped_image):
        if base_image.shape != warped_image.shape:
            print(f"Resizing warped_image from {warped_image.shape} to {base_image.shape}")
            warped_image = cv2.resize(warped_image, (base_image.shape[1], base_image.shape[0]))
        
        blended_image = cv2.addWeighted(base_image, 0.5, warped_image, 0.5, 0)
        return blended_image
    

    def save_stitched_image(self, folder_name, save_dir="./data/stitched/"):
        if self.stitched_image is None:
            raise ValueError("No stitched images found. Run stitch_images() first.")

        stitched_filename = f"{folder_name}/{folder_name}.jpg"
        save_path = os.path.join(save_dir, stitched_filename)
        print("Saving stitched image in ", save_path)
        cv2.imwrite(save_path, self.stitched_image)



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



    
    
