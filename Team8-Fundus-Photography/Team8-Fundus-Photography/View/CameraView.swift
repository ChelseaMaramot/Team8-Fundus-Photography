//
//  CameraView.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2024-11-11.
//

import SwiftUI
import UIKit

struct CameraView: View {
    @State private var isRecording = false
    @State private var mode = "photo"
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var lightManager = LightManager()
    @EnvironmentObject var selectedDataManager: SelectedDataManager
    
    @State private var capturedImage: UIImage?
    @State private var showCapturedPhoto = false
    @State private var isFlashing = false
    @State private var isAdjustingZoom: Bool = false
    @State private var isAdjustingFocus: Bool = false
    @State private var sliderValue: Double = 0.0
    
    @State private var currentZoomFactor: CGFloat = 3.0
    @State private var lastZoomFactor: CGFloat = 3.0
    
    @State private var isFocused = false
    @State private var focusLocation: CGPoint = .zero
    @State private var focusValue: Float = 0.5
    @State private var isScaled = false
    
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer? = nil

    
    
    var body: some View {
        
        GeometryReader { geometry in
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
                QuadrantView(cameraManager: cameraManager)
                    .zIndex(2)
                
                
                VStack {
                    
                    recordingTimeIndicator
                        
                    CameraFeed
                        .onAppear { cameraManager.startSession{
                            print("Camera session started successfully.") }
                        }
                        .onDisappear {
                            cameraManager.stopSession()
                            print("Camera session stopped.")
                        }
                        .gesture(zoomGesture)
                    
                    FocusControlView(focusValue: $focusValue, isAdjustingFocus: $isAdjustingFocus, cameraManager: cameraManager)
                    
                    ZoomControlView(currentZoomFactor: $currentZoomFactor, isAdjustingZoom: $isAdjustingZoom, cameraManager: cameraManager)
                    
                    
                    LightControlView(
                        sliderValue: $sliderValue,
                        lightManager: lightManager
                    )
                    
                    CameraButton(
                        isRecording: $isRecording,
                        mode: $mode,
                        captureAction: capturePhoto,
                        startRecordingAction: startRecording,
                        stopRecordingAction: stopRecording
                    )
                }
            }
        }
        .navigationDestination(isPresented: $showCapturedPhoto) {
            PreviewPage(
                image: $capturedImage,
                onSave: { print("Saving image to cloud") },
                onRetake: {
                    print("retaking image")
                    capturedImage = nil
                    showCapturedPhoto = false
                    
                }
            )
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
                   cameraManager.setZoomScale(factor: min(max(cameraManager.zoomFactor + (value - 1.0), 0.5), 10))
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
                .padding(.bottom, 5)
                .foregroundColor(isAdjusting ? .red : .blue)
        }
    }
    
    private struct ZoomControlView: View {
        @Binding var currentZoomFactor: CGFloat
        @Binding var isAdjustingZoom: Bool
        let cameraManager: CameraManager
        
        var body: some View {
            VStack(spacing: 3){
                Text("Zoom: \(String(format: "%.2f", currentZoomFactor))")
                    .foregroundColor(isAdjustingZoom ? .red : .blue)
                    .frame(maxWidth: .infinity, alignment: .leading)
               
                Slider(
                    value: $currentZoomFactor,
                    in: 0.5...10,
                    step: 0.1,
                    onEditingChanged: { editing in
                        isAdjustingZoom = editing
                    }
                )
                .onChange(of: currentZoomFactor) { newValue in
                    cameraManager.setZoomScale(factor: newValue)
                }
            }
            .padding(.horizontal, 30)
        }
    }
    
    
    private struct LightControlView: View {
        @Binding var sliderValue: Double
        let lightManager: LightManager

        var body: some View {
            VStack(spacing: 3) {
                Text("Intensity: \(lightManager.lightIntensity, specifier: "%.0f")")
                    .foregroundColor(lightManager.isAdjusting ? .red : .blue)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
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
                
            }
            .padding(.horizontal, 30)
            
        }
    }
    
    private struct FocusControlView: View {
        @Binding var focusValue: Float
        @Binding var isAdjustingFocus: Bool
        let cameraManager: CameraManager
        
        var body: some View {
            VStack(spacing: 3) {
                Text("Focus: \(String(format: "%.2f", focusValue))")
                    .foregroundColor(isAdjustingFocus ? .red : .blue)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Slider(
                    value: $focusValue,
                    in: 0.0...1.0,
                    step: 0.01,
                    onEditingChanged: { editing in
                        if editing {
                            isAdjustingFocus = true
                        } else {
                            isAdjustingFocus = false
                        }
                    }
                )
                .onChange(of: focusValue) { newValue in
                    cameraManager.setFocusWithSlider(newValue)
                }
             
            }
            .padding(.horizontal, 30)
        }
    }
    
    private func capturePhoto() {
            isFlashing = true
            cameraManager.capturePhoto { image in
                print("new image is captured")
                capturedImage = image
                DispatchQueue.main.async {
                    if image != nil{
                        showCapturedPhoto = true
                    }
                }
            }
        }
    
    
    private func startRecording() {
        isRecording = true
        elapsedTime = 0
        print("starting to record...")
        cameraManager.startRecording()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                elapsedTime += 1
        }
    }

    private func stopRecording() {
        isRecording = false
        cameraManager.stopRecording()
        timer?.invalidate()
        timer = nil
    }
    
    private var formattedElapsedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private var recordingTimeIndicator: some View {
        Text(isRecording ? "\(formattedElapsedTime)" : " ")
            .font(.system(size: 20))
            .foregroundColor(.white)
            .background(isRecording ? Color.red : Color.clear)
            .padding(5)
            .cornerRadius(10)
            .opacity(isRecording ? 1 : 0)
    }
}

#Preview {
    CameraView()
}
