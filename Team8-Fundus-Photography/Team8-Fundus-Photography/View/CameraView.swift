//
//  CameraView.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2024-11-11.
//

import SwiftUI
import UIKit

struct CameraView: View {
    
    @StateObject private var cameraManager = CameraManager()
    @State private var capturedImage: UIImage?
    @State private var showCapturedPhoto = false

    var body: some View {
        ZStack{
            CameraPreviewRepresentable(session: cameraManager.captureSession).onAppear() {
                cameraManager.startSession()
            }.onDisappear() {
                cameraManager.stopSession()
            }.edgesIgnoringSafeArea(.all)
        }
        
        VStack
        {
            Spacer()
            Button(action: {
                cameraManager.capturePhoto {image in
                    capturedImage = image
                    showCapturedPhoto = image != nil}
            }) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 70, height: 70)
                    .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                    .padding(.bottom, 30)
            }
        }
    }
}


#Preview {
    CameraView()
}
