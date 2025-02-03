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
            GeometryReader { geometry in
                ZStack {
                    Color.white.edgesIgnoringSafeArea(.all)
                    
                    QuadrantView().zIndex(2)
                    
                    VStack {
                        
                        ZoomIndicator(currentZoomFactor: currentZoomFactor, isAdjusting: isAdjustingZoom)
                       
                    
                        CameraFeed
                            .onAppear { cameraManager.startSession() }
                            .onDisappear { cameraManager.stopSession() }
                            .gesture(zoomGesture)
                          
                        Spacer().frame(height: 40)
                  
                         LightControlView(
                             sliderValue: $sliderValue,
                             lightManager: lightManager
                         )
                        
                        CameraButton(action: capturePhoto)
                        .padding(.bottom, 20)
                    }
                }
            }
            
            .navigationDestination(isPresented: $showCapturedPhoto) {
                if let image = capturedImage {
                    PreviewPage(
                        image: $capturedImage,
                        onSave: { print("Saving image to cloud") },
                        onRetake: {
                            capturedImage = nil
//                            image = nil
                            showCapturedPhoto = false
                            
                            // Restart the camera session
                            cameraManager.stopSession()
                            DispatchQueue.main.async {
                                cameraManager.startSession()
                            }
                        } // Reset capturedImage on retake
                    )
                }
            }
        }
    }

#Preview {
    CameraView()
}
// subviews
extension CameraView {
    
    
    private var CameraFeed: some View {
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
        .aspectRatio(contentMode: .fill)
        .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.width)
        .ignoresSafeArea()
        .clipShape(Circle())
        .overlay(
            Group {
                if isFlashing { FlashView(isFlashing: $isFlashing).zIndex(1) }
            }
        )
        
       }
       
    
    private var focusOverlay: some View {
        Group {
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
    }
    
    private var zoomGesture: some Gesture {
           MagnificationGesture()
               .onChanged { value in
                   isAdjustingZoom = true
                   currentZoomFactor = min(max(currentZoomFactor + (value - 1.0), 0.5), 10)
                   cameraManager.setZoomScale(factor: currentZoomFactor)
               }
               .onEnded { _ in
                   isAdjustingZoom = false
               }
       }
    
    private struct ZoomIndicator: View {
        let currentZoomFactor: CGFloat
        let isAdjusting: Bool
        
        var body: some View {
            Text("Current Zoom: \(String(format: "%.2f", currentZoomFactor))")
                .padding()
                .foregroundColor(isAdjusting ? .red : .blue)
        }
    }
    
    
    private struct LightControlView: View {
        @Binding var sliderValue: Double
        let lightManager: LightManager

        var body: some View {
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
            
        }
    }
    
    private func capturePhoto() {
            isFlashing = true
            cameraManager.capturePhoto { image in
                print("new image is captured")
                capturedImage = image
                showCapturedPhoto = image != nil
            }
        }
    

    
}

#Preview {
    CameraView()
}
