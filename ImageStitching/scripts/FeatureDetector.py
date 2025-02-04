
import cv2

class FeatureDetector():

    def __init__(self, detector_type = "SIFT", threshold=300, sigma = 12):
        self.detector_type = detector_type
        self.detector = self.create_detector(sigma=sigma)
        self.threshold = threshold

    def create_detector(self, sigma):

        if self.detector_type == "SIFT":
            return cv2.xfeatures2d.SIFT_create(sigma = sigma)
        elif self.detector_type == "SURF":
            return cv2.xfeatures2d.SURF_create(self.threshold)
        else:
            raise ValueError(f"Unknown detector type: {self.detector_type}")
        
    def detect_and_compute(self, image):
        kp, desc = self.detector.detectAndCompute(image, None)
        return kp, desc
    
    
    @staticmethod
    def draw_keypoints(img, features, **kwargs):
        kwargs.setdefault("color", (0, 255, 0))
        keypoints = features.getKeypoints()
        return cv2.drawKeypoints(img, keypoints, None, **kwargs)
    