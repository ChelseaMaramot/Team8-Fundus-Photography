import cv2
import numpy as np
import os

class Image:

    def __init__(self, image_path=None, image_data=None):

        self.image_path = image_path 
        self.image_data = image_data
        self.name = None

        if image_path:
            self.load(image_path)
        elif image_data is not None:
            self.image_data = image_data
        else:
            raise ValueError("Either 'image_path' or 'image_data' must be provided.")
        
    
    def load(self, image_path):
        self.image_path = image_path
        self.name = os.path.basename(self.image_path)
        self.image_data = cv2.imread(image_path, cv2.IMREAD_UNCHANGED)


    def get_name(self):
        return self.name

    def save(self, output_path):
        cv2.imwrite(output_path, self.image_data)

    def get_data(self):
        return self.image_data

    def show(self, width=600, height=400):
        resized_image = cv2.resize(self.image_data, (width, height))
        cv2.imshow('Image', resized_image)
        cv2.waitKey(0)
        cv2.destroyAllWindows()