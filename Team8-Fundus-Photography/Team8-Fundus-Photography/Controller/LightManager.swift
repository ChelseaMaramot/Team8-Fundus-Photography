//
//  LightManager.swift
//  Team8-Fundus-Photography
//
//  Created by Anjola Adewale on 2024-11-16.
//


import SwiftUI
import AVFoundation

class LightManager: ObservableObject {
    @Published var isFlashOn: Bool = false
    @Published var lightIntensity: Double = 0.0
    @Published var isAdjusting: Bool = false
    
    
    let minIntensity: Double = 0.0
    let maxIntensity: Double = 4.0
    
    func setLightIntensity( intensity: Double){
        lightIntensity = intensity;
//        max(minIntensity, min(maxIntensity, intensity))
        setTorch(value: lightIntensity)
        print("Light intensity set to \(lightIntensity)")
    }
    
    
    func startAdjusting() {
        isAdjusting = true
        print("Light adjustment started.")
    }
    
    func stopAdjusting() {
        isAdjusting = false
        print("Light adjustment stopped.")
    }
    func setTorch(value: Double){
        let adjustedValue = value / 4.0
            guard let device = AVCaptureDevice.default(for: .video) else { return }
            
            if device.hasTorch {
                do {
                    try device.lockForConfiguration()
                    if adjustedValue > 0.0 {
                        try device.setTorchModeOn(level: Float(adjustedValue))

                    } else {
                        device.torchMode = .off
                    }
                    device.unlockForConfiguration()
                } catch {
                    print("Torch could not be used now.")
                }
            }
            
        }
}

