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
    
    @StateObject var storageManager = FirebaseManager()
    
    var body: some View {
        NavigationStack{
            VStack {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                HStack {
                    Button("Save") {
                        storageManager.saveToFirebase(image: image)
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
