//
//  ImageCard.swift
//  Team8-Fundus-Photography
//
//  Created by Anjola Adewale on 2025-02-02.
//

import SwiftUI

struct ImageCard: View {
    @ObservedObject var viewModel: FirebaseManager
    var isFromScanList: Bool
    var position: String
    var onAddImage: () -> Void
    var onSelectImage: (LabeledImage) -> Void
    @EnvironmentObject var selectedDataManager: SelectedDataManager
    
    var body: some View {
        
        let images = viewModel.imagesByPosition[position] ?? []
        let isMaxImagesReached = images.count >= 4
        
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
                                .onLongPressGesture{
                                    triggerHapticFeedback()
                                    onSelectImage(labeledImage)
                                }
                        } else {
                            // Handle the nil case: show a placeholder or error message
                            Text("No image available")
                        }
                        
                        
                    }
                }
                
                // Add Image Button
                Button(action: {
                    if !isMaxImagesReached && !isFromScanList {
                        onAddImage()
                        
                    }
                }) {
                    
                    
                    Image(systemName: "plus")
                        .font(.system(size: 24))
                        .foregroundColor((isMaxImagesReached || isFromScanList) ? .black : .white)
                        .padding(10)
                        .background((isMaxImagesReached || isFromScanList) ? Color.gray : Color.blue)
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

private func triggerHapticFeedback() {
       let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
       impactFeedback.prepare()
       impactFeedback.impactOccurred()
   }

#Preview {
    //Card(name: "Chelsea Grace", date: Date(), scanNumber: 1)
}
