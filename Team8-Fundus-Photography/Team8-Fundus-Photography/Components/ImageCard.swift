//
//  ImageCard.swift
//  Team8-Fundus-Photography
//
//  Created by Anjola Adewale on 2025-02-02.
//

import SwiftUI

struct ImageCard: View {
    var position: String
    @State var images: [LabeledImage]
    var onAddImage: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(position)
                .font(.headline)
                .foregroundColor(.blue)
                .padding(.leading, 10)
                .padding(.top, 10)
        }
        ScrollView(.horizontal, showsIndicators: false){
            HStack{
                ForEach(images) { labeledImage in
                    NavigationLink(destination: ImageView(image: labeledImage.image)){
                        
                        if let nonOptionalImage = labeledImage.image {
                            // Use nonOptionalImage here; it is a non-optional UIImage
                            Image(uiImage: nonOptionalImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .overlay(
                                    Circle().stroke(labeledImage.isPrimary ? Color.blue : Color.clear, lineWidth: 3)
                                )
                                .padding(.horizontal, 4)
                        } else {
                            // Handle the nil case: show a placeholder or error message
                            Text("No image available")
                        }
                        
                        
                    }
                }
                
                // Add Image Button
                Button(action: onAddImage) {
                    Image(systemName: "plus")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.blue)
                        .clipShape(Circle())
                    }
            }
            .padding(.top, 10)
            .padding(.bottom, 10)
            .padding(.trailing, 10)
            .frame(maxWidth: .infinity, alignment: .trailing) // Align to the right
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 3))
        .padding(.horizontal)
    }
    
}

//#Preview {
//    Card(name: "Chelsea Grace", date: Date(), scanNumber: 1)
//}
