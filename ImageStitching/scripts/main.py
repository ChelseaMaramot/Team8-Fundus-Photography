#
# //  main.py
# //  Team8-Fundus-Photography
# //
# //  Created by chelsea maramot on 2025-01-24.
# //

import cv2
import os


from preprocess import extract_green_channel, preprocess_retinal_image
from registration import incremental_search, stitch_image

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

    
    output_image1 = cv2.imread(os.path.join(output_path, input_images[0]))
    output_image2 = cv2.imread(os.path.join(output_path, input_images[1]))
    
    input_image1 = cv2.imread(os.path.join(input_path, input_images[0])) 
    input_image2 = cv2.imread(os.path.join(input_path, input_images[1]))



    offset = incremental_search(output_image1, output_image2, initial_orientation=2, feature_search_length=0.2, threshold=0.6)
    print("Offset: ", offset)

    if offset:
        stitch_image(input_image1, input_image2, offset)
    else:
        print("Cannot stitch images together")

    

if __name__ == "__main__":
    main()
