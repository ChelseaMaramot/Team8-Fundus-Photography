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
    @ObservedObject private var lightManager = LightManager()
    @State private var capturedImage: UIImage?
    @State private var showCapturedPhoto = false
    @State private var isFlashing = false
    @State private var sliderValue: Double = 0.0
    
    var body: some View {
        NavigationStack{ // Add NavigationView here
            GeometryReader { geometry in
                ZStack {
                    Color.white.edgesIgnoringSafeArea(.all)
                    VStack {
                        CameraPreview(session: cameraManager.getSession())
                            .onAppear { cameraManager.startSession() }
                            .onDisappear { cameraManager.stopSession() }
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height * 0.6)
                            .ignoresSafeArea()
                            .overlay(
                                Group {
                                    if isFlashing { FlashView(isFlashing: $isFlashing).zIndex(1) }
                                }
                            )
                        
                        Spacer()
                        
                        VStack(spacing: 10) {
                            Slider(
                                value: $sliderValue,
                                in: lightManager.minIntensity...lightManager.maxIntensity,
                                step: 1
                            ) {
                                Text("Light Intensity")
                            } minimumValueLabel: {
                                Text("\(lightManager.minIntensity, specifier: "%.0f")")
                            } maximumValueLabel: {
                                Text("\(lightManager.maxIntensity, specifier: "%.0f")")
                            } onEditingChanged: { editing in
                                if editing {
                                    lightManager.startAdjusting()
                                } else {
                                    lightManager.setLightIntensity(intensity: sliderValue)
                                    lightManager.stopAdjusting()
                                }
                            }
                            
                            Text("Intensity: \(lightManager.lightIntensity, specifier: "%.0f")")
                                .foregroundColor(lightManager.isAdjusting ? .red : .blue)
                        }
                        .padding(.bottom, 20)
                        
                        CameraButton(action: {
                            isFlashing = true
                            cameraManager.capturePhoto { image in
                                capturedImage = image
                                showCapturedPhoto = image != nil
                            }
                        })
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationDestination(isPresented: $showCapturedPhoto) { // Navigate to PreviewPage
                if let image = capturedImage {
                    PreviewPage(image: image) {
                        // Optional: Add a completion handler if you need to handle anything when the image is saved
                        print("Saving image to cloud")
                    }
                    .onAppear {
                        // This will be called when the PreviewPage is shown
                        print("Navigating to preview page")
                    }
                    
                }
            }
        }
    }
}

#Preview {
    CameraView()
}
