//
//  PreviewPage.swift
//  Team8-Fundus-Photography
//
//  Created by Anjola Adewale on 2025-01-07.
//

import SwiftUI

struct PreviewPage: View {
    let image: UIImage
    let onSave: () -> Void
    @State private var currentZoom = 0.0
    @State private var totalZoom = 1.0
    
    var body: some View {
        NavigationStack{
            VStack {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .scaleEffect(totalZoom)
                    .clipShape(Circle())
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                currentZoom = value - 1
                            }
                            .onEnded { value in
                                totalZoom += currentZoom
                                totalZoom = max(1, totalZoom)
                                currentZoom = 0
                            }
                    )
//                max(1.0
                
                
                
                HStack {
                    Button("Save") {
                        saveToFirebase(image: image)
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    NavigationLink(destination: CameraView()){
                        Text("Retake")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        
                    }
                }
                .padding()
            }
            .navigationTitle("Preview Image")
        }
    }
}
