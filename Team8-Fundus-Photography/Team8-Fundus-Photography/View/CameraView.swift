//
//  CameraView.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2024-11-11.
//

import SwiftUI
import UIKit

struct CameraView: View {
    
    @State private var cameraManager = CameraManager()
    @State private var capturedImage: UIImage?
    @State private var showCapturedPhoto = false

    var body: some View {
        ZStack{
            CameraPreviewRepresentable(session: cameraManager.getSession()).onAppear() {
                cameraManager.startSession()
            }.onDisappear() {
                cameraManager.stopSession()
            }.edgesIgnoringSafeArea(.all)
            
            VStack
            {
                Spacer()
                CameraButton(action: {
                    cameraManager.capturePhoto {image in
                        capturedImage = image
                        showCapturedPhoto = image != nil}
                })
                .padding(.bottom, 30)
            }
        }
        
      
    }
}


#Preview {
    CameraView()
}
