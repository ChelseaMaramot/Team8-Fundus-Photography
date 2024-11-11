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
struct CameraPreviewRepresentable: UIViewRepresentable {
    let session: AVCaptureSession
    
    //  Initialize and return a CameraPreviewView
    //  creates view controller obkect and configures init state
    func makeUIView(context: Context) -> CameraPreviewView {
        let cameraPreviewView = CameraPreviewView()
        cameraPreviewView.session = session
        return cameraPreviewView
    }

    //  called when there is an update from SwiftUI
    func updateUIView(_ uiView: CameraPreviewView, context: Context) {
        uiView.session = session
    }}
