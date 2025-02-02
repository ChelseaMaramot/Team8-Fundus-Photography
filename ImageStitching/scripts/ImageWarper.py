import cv2
import numpy as np

class ImageWarper:
    def __init__(self, image1, image2, homography=None):
        self.image1 = image1
        self.image2 = image2
        self.homography = homography


    def warp_image(self):
        if self.homography is None:
            raise ValueError("Homography matrix must be provided before warping.")
    
        height2, width2 = 5000,5000#self.image2.shape[:2]
        warped_img1 = cv2.warpPerspective(self.image1, self.homography, (width2, height2))
        return warped_img1
    

    def show_warped_image(self, warped_img):
        combined_image = np.hstack([self.image2, warped_img])
        cv2.imshow("Original and Warped Image", combined_image)
        cv2.waitKey(0)
        cv2.destroyAllWindows()

    def save_warped_image(self, warped_img, save_path="./data/warped_image.jpg"):
        cv2.imwrite(save_path, warped_img)



    
    
