//
//  ContentView.swift
//  Flashlight App Demo
//
//  Created by Anjola Adewale on 2024-11-06.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State var BackgroundC = Color.black
    @State var torchColor = Color.white
    var body: some View {
        ZStack{
            BackgroundC.edgesIgnoringSafeArea(.all)
            VStack{
                HStack{
                    Button(action: {
                        BackgroundC = Color.black
                        torchColor = Color.white
                        toggleTorch(on: false)
                    }){
                        Image(systemName: "flashlight.off.fill").foregroundColor(torchColor).font(.largeTitle)
                    }
                    Button(action: {
                        BackgroundC = Color.white
                        torchColor = Color.black
                        toggleTorch(on: true)
                    }){
                        Image(systemName: "flashlight.on.fill").foregroundColor(torchColor).font(.largeTitle)
                    }
                    
                }.padding()
            }
        }
    }
    
    func toggleTorch(on: Bool){
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                if on == true {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }
            } catch {
                print("Torch could not be used now.")
            }
        }
        
    }
}

#Preview {
    ContentView()
}
