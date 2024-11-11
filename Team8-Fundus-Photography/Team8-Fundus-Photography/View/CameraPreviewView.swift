//
//  CameraPreviewView.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2024-11-10.
//

import SwiftUI
import AVFoundation


/*
 @description: layer provides a preview of the content of camera captures
 Documentation: https://developer.apple.com/documentation/avfoundation/avcapturevideopreviewlayer
 */

class CameraPreviewView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    
    // connecting layer to capture session
    var session: AVCaptureSession? {
        get {videoPreviewLayer.session}
        set {videoPreviewLayer.session = newValue}
    }
}

