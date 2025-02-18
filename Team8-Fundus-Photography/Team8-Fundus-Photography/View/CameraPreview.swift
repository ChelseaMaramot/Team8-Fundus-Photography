//
//  CameraPreviewRepresentable.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2024-11-10.
//

import SwiftUI
import AVFoundation


/*
 * Allows us to use CameraPreviewView and binds a session to it
 */
struct CameraPreview: UIViewRepresentable {
    
    
    class VideoPreviewView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        
        var videoPreviewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }
    
    let session: AVCaptureSession
    var onTap: (CGPoint) -> Void
    
    func makeCoordinator() -> TapToFocusCoordinator {
        TapToFocusCoordinator(self)
    }
    
    //  Initialize and return a CameraPreviewView
    //  creates view controller obkect and configures init state
    func makeUIView(context: Context) -> VideoPreviewView{
        print("make ui view in cam preview...")
        print(session)
        let videoPreview = VideoPreviewView()
        videoPreview.videoPreviewLayer.session = session
        videoPreview.videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreview.backgroundColor = .black
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTapGesture(_:)))
        videoPreview.addGestureRecognizer(tapGesture)
        
        return videoPreview
    }
    
    //  called when there is an update from SwiftUI
    func updateUIView(_ uiView: VideoPreviewView, context: Context) {
       
    }
}
