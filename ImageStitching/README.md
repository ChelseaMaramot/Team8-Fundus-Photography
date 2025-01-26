# Retinal Image Stitching Algorithm

This project implements an image stitching algorithm specifically designed for retinal images. The algorithm is intended to preprocess, register, and stitch multiple retinal images together to create a composite image. The method is based on feature extraction, image registration, and fusion, with a focus on enhancing the quality of retinal images, such as increasing contrast and reducing noise.

## Overview

Retinal image stitching involves aligning multiple retinal images to form a larger, more comprehensive image, allowing for better analysis and understanding of the retina. This method is used in medical imaging to detect conditions like retinopathy and other eye diseases.

Key components of this project:
1. **Preprocessing**: Convert the image to a specific color channel (green channel for better contrast), followed by contrast enhancement and noise reduction.
2. **Feature Matching**: Use feature-based methods like SIFT (Scale-Invariant Feature Transform) to extract and match key points.
3. **Image Registration**: Align and register the images using techniques like RANSAC (Random Sample Consensus) to eliminate false matches.
4. **Image Fusion**: Combine the registered images into a single composite image.

## References
- FIRE Dataset: [FIRE Retinal Image Dataset](https://projects.ics.forth.gr/cvrl/fire/)
- Paper on Image Stitching: [An automatic algorithm for stitching multi-sequence retinal images](https://carlos.hernandez.im/papers/2017_07_JMO.pdf)

## Requirements


## Installation

