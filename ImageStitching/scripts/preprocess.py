# #
# //  preprocess.py
# //  Team8-Fundus-Photography
# //
# //  Created by chelsea maramot on 2025-01-24.
# //


'''
To extract clearer images, the original image need to be preprocessed.
Based on a study with FIRE dataset, the green channel will be used as the initial image.


CLAHE (Contrast Limited Adaptive Histogram Equalization) and median filtering will be used to enhance the detail of extracted retinal images, improving contrast of blood vessels and tissues.
'''

import cv2

class Preprocessing:

    @staticmethod
    def resize(image_data, width, height):
        return cv2.resize(image_data, (width, height))

    @staticmethod
    def extract_channel(image_data, channel='R'):

        if len(image_data.shape) == 3:
            if channel == 'R':
                return image_data[:,:,2]
            elif channel == 'G':
                return image_data[:,:,1]
            elif channel == 'B':
                return image_data[:,:,0]
            else:
                print("Invalid channel. Choose from 'R', 'G', 'B'.")
        else:
            print("Image does not have multiple channels.")
        return None

    @staticmethod
    def remove_black_bg():
        pass

    @staticmethod
    def convert_to_gray(image_data):
        return cv2.cvtColor(image_data, cv2.COLOR_BGR2GRAY)
        

    @staticmethod
    def CLAHE(image_data, clipLimit=10, tileGridSize=(8,8)):
        clahe = cv2.createCLAHE(clipLimit, tileGridSize)
        return clahe.apply(image_data)
    

    @staticmethod
    def median_filter(image, kernel_size=5):
        return cv2.medianBlur(image, kernel_size)
    

    @staticmethod
    def process_retinal_image(image_data):
        #image_data = Preprocessing.extract_channel(image_data, channel='G')  
        image_data = Preprocessing.convert_to_gray(image_data)
        image_data = Preprocessing.CLAHE(image_data)  
        image_data = Preprocessing.median_filter(image_data)  
        return image_data
    

