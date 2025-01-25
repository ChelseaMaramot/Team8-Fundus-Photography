#
# //  main.py
# //  Team8-Fundus-Photography
# //
# //  Created by chelsea maramot on 2025-01-24.
# //

import cv2
import os

from preprocess import extract_green_channel, preprocess_retinal_image

def main():
    input_path= './data/input'
    output_path = './data/output'
     
    input_images = [f for f in os.listdir(input_path)]
    
    for img in input_images:
        image = cv2.imread(os.path.join(input_path, img))

        green_channel = extract_green_channel(image)

        preprocessed_image = preprocess_retinal_image(green_channel)

        #save preprocessed image
        cv2.imwrite(os.path.join(output_path, img), preprocessed_image)
    

if __name__ == "__main__":
    main()
