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
    
    @Binding var isEditing: Bool
    @Binding var selectedEditImages: [LabeledImage]
    
    var body: some View {
        let images = viewModel.imagesByPosition[position] ?? []
        let isMaxImagesReached = images.count >= 4
        
        VStack(alignment: .leading) {
            Text(position)
                .font(.headline)
                .foregroundColor(.blue)
                .padding([.leading, .top], 10)
        }
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(images) { labeledImage in
                    imageView(for: labeledImage)
                }
                
                addImageButton(isMaxImagesReached: isMaxImagesReached)
            }
            .padding([.top, .bottom], 10)
            .padding(.trailing, 10)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 3))
        .padding(.horizontal)
    }
    
    private func imageView(for labeledImage: LabeledImage) -> some View {
        let image = labeledImage.image ?? UIImage()
        
        return Group {
            if isEditing {
                editableImageView(for: labeledImage, image: image)
            } else {
                NavigationLink(destination: ImageView(image: image)) {
                    standardImageView(labeledImage: labeledImage)
                }
            }
        }
    }
    
    private func editableImageView(for labeledImage: LabeledImage, image: UIImage) -> some View {
        return Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            .overlay(Circle().stroke(labeledImage.isPrimary ? Color.blue : Color.clear, lineWidth: 3))
            .padding(.horizontal, 4)
            .onTapGesture {
                handleImageSelectionOnEdit(labeledImage)
            }
            .onLongPressGesture {
                triggerHapticFeedback()
                onSelectImage(labeledImage)
            }
            .overlay(
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.green)
                    .opacity(selectedEditImages.contains(where: { $0.id == labeledImage.id }) ? 1 : 0)
                    .padding(4),
                alignment: .topTrailing
            )
    }
    
    private func standardImageView(labeledImage: LabeledImage) -> some View {
        return Image(uiImage: labeledImage.image ?? UIImage())
            .resizable()
            .scaledToFit()
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            .overlay(Circle().stroke(labeledImage.isPrimary ? Color.blue : Color.clear, lineWidth: 3))
            .padding(.horizontal, 4)
    }
    
    private func addImageButton(isMaxImagesReached: Bool) -> some View {
        Button(action: {
            if !isMaxImagesReached && !isFromScanList {
                onAddImage()
            }
        }) {
            Image(systemName: "plus")
                .font(.system(size: 24))
                .foregroundColor((isEditing || isMaxImagesReached || isFromScanList) ? .black : .white)
                .padding(10)
                .background((isEditing || isMaxImagesReached || isFromScanList) ? Color.gray : Color.blue)
                .clipShape(Circle())
        }
        .disabled(isEditing)
    }
    
    private func handleImageSelectionOnEdit(_ labeledImage: LabeledImage) {
        if isEditing {
            if let index = selectedEditImages.firstIndex(where: { $0.id == labeledImage.id }) {
                selectedEditImages.remove(at: index)
            } else {
                selectedEditImages.append(labeledImage)
            }
        }
        print(selectedEditImages)
    }
    
    private func triggerHapticFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.prepare()
        impactFeedback.impactOccurred()
    }
}
