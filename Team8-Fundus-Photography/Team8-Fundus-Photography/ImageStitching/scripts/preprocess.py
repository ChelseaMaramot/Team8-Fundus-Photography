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

def extract_green_channel(image):
    cv2.imshow('Original_Image', image)
    b,g,r = cv2.split(image)

    # cv2.imshow('Green_Channel', g)
    # cv2.waitKey(0)

    return g 
    

# https://pyimagesearch.com/2021/02/01/opencv-histogram-equalization-and-adaptive-histogram-equalization-clahe/
# CLAHE improves the contrast of images. Histogram equalization is applied to small regions of the image, as opposed to the entire image.
# clipLimit: Threshold for contrast limiting. Default of 40
# tileGridSize: Size of grid for histogram equalization.  Sets # of tiles in row and column. Default of 8x8.
def CLAHE(image, clipLimit=2.0, tileGridSize=(8,8)):
    clahe = cv2.createCLAHE(clipLimit, tileGridSize)
    final_image = clahe.apply(image)

    # cv2.imshow('CLAHE', final_image)
    # cv2.waitKey(0)

    return final_image

# preserves edges while removing noise
def median_filter(image, kernel_size=5):
    filtered_image = cv2.medianBlur(image, kernel_size)

    # cv2.imshow('Median_Filter', filtered_image)
    # cv2.waitKey(0)

    return filtered_image

def preprocess_retinal_image(image):
    median_filtered_image = median_filter(image)
    clahe_image = CLAHE(median_filtered_image)

    return clahe_image
