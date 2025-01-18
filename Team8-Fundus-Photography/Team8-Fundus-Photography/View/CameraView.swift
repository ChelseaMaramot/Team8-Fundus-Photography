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
    @State private var isAdjustingZoom: Bool = false
    @State private var sliderValue: Double = 0.0
    @State private var currentZoomFactor: CGFloat = 3.0
    @State private var lastZoomFactor: CGFloat = 3.0
    @State private var isFocused = false
    @State private var focusLocation: CGPoint = .zero
    @State private var isScaled = false
    
    
    var body: some View {
        NavigationStack{ 
            GeometryReader { geometry in
                ZStack {
                    Color.white.edgesIgnoringSafeArea(.all)
                    VStack {
                        
                        Text("Current Zoom: \(String(format: "%.2f", currentZoomFactor))")
                                      .padding()
                                      .foregroundColor(isAdjustingZoom ? .red : .blue)
                        ZStack{
                        CameraPreview(session: cameraManager.getSession()){ tapPoint in
                            isFocused = true
                            focusLocation = tapPoint
                            cameraManager.setFocusOnTap(devicePoint: focusLocation)

                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        } .edgesIgnoringSafeArea(.all)
                    
                            if isFocused {
                                FocusView(position: $focusLocation)
                                    .scaleEffect(isScaled ? 0.8 : 1)
                                    .onAppear {
                                        // springy animation effect for visual appeal.
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0)) {
                                            self.isScaled = true
                                            // Return to the default state after 0.6 seconds for an elegant user experience.
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                                self.isFocused = false
                                                self.isScaled = false
                                            }
                                        }
                                    }
                            }
                            
                            
                        }
                            .onAppear { cameraManager.startSession() }
                            .onDisappear { cameraManager.stopSession() }
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width * 0.9, height: geometry.size.width * 1)
//                            .padding(.top, 5)
                            .ignoresSafeArea()
                            .clipShape(Circle())
                            .gesture(
                                MagnificationGesture()
                                    .onChanged{ value in
                                        isAdjustingZoom = true
                                        currentZoomFactor += value - 1.0
                                        currentZoomFactor = min(max(self.currentZoomFactor, 0.5), 10)
                                        cameraManager.setZoomScale(factor: currentZoomFactor)
                                        print(currentZoomFactor)
                                    }.onEnded{ value in
                                        lastZoomFactor = currentZoomFactor
                                        isAdjustingZoom = false
                                    }
                                
                            )
                            .overlay(
                                Group {
                                    if isFlashing { FlashView(isFlashing: $isFlashing).zIndex(1) }
                                }
                            )
                        
                        Spacer().frame(height: 40)
                  
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
                        .padding(.horizontal, 20)
                        
                        CameraButton(action: {
                            isFlashing = true
                            cameraManager.capturePhoto { image in
                                capturedImage = image
                                showCapturedPhoto = image != nil
                            }
                        })
                        .padding(.bottom, 20)
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
