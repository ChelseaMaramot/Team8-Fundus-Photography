//
//  CameraView.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2024-11-11.
//

import SwiftUI
import UIKit

struct CameraView: View {
    
    @ObservedObject private var cameraManager = CameraManager()
    @State private var capturedImage: UIImage?
    @State private var showCapturedPhoto = false
    @State private var isFlashing = false

    //@State private var celsius: Double = 0
    
    var body: some View {
        GeometryReader {geometry in
            ZStack{
                Color.black.edgesIgnoringSafeArea(.all)
                VStack{
                    CameraPreview(session: cameraManager.getSession()).onAppear() {
                        cameraManager.startSession()
                    }.onDisappear() {
                        cameraManager.stopSession()
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.8)
                    .ignoresSafeArea()
                    .overlay(
                        Group{
                            if isFlashing {FlashView(isFlashing: $isFlashing).zIndex(1)}
                        }
                    )
                    
                    Spacer()
                    
                    // Anjola can add slider in here
                    //Slider(value: $celsius, in: -100...100)
                    
                    CameraButton(action: {
                        isFlashing = true
                        
                        cameraManager.capturePhoto {image in
                            capturedImage = image
                            showCapturedPhoto = image != nil}
                    })
                    .padding(.bottom, 30)
                }
            }
        }
    }
}


#Preview {
    CameraView()
}
