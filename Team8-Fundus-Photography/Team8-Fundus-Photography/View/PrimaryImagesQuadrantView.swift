//
//  PrimaryImagesQuadrantView.swift
//  Team8-Fundus-Photography
//
//  Created by Anjola Adewale on 2025-03-09.



import SwiftUI

struct PrimaryImagesQuadrantView: View {
    let images: [LabeledImage] // ✅ Now using LabeledImage array

    var body: some View {
        ZStack {
            // Define the standard order of quadrants
            let quadrants = ["Superior", "Inferior", "Nasal", "Temporal", "Central"]

            ForEach(quadrants, id: \.self) { quadrant in
                // Try to find the image for this quadrant
                if let labeledImage = images.first(where: { $0.position == quadrant }) {
                    NavigationLink(destination: ImageView(labeledImage: labeledImage)) {
                        if let uiImage = labeledImage.image {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 90, height: 90)
                                .clipShape(Circle())
                                .overlay(
                                    Circle().stroke(Color.blue, lineWidth: 2)
                                )
                        }
                    }
                    .offset(offsetForQuadrant(quadrant))
                } else {
                    // Placeholder for missing quadrant image
                    Circle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 90, height: 90)
                        .overlay(
                            Text(quadrant.prefix(2))
                                .foregroundColor(.black)
                                .font(.caption)
                        )
                        .offset(offsetForQuadrant(quadrant))
                }
            }
        }
    }

    private func offsetForQuadrant(_ quadrant: String) -> CGSize {
        let offset: CGFloat = 110

        switch quadrant {
        case "Superior": return CGSize(width: 0, height: -offset)
        case "Inferior": return CGSize(width: 0, height: offset)
        case "Nasal": return CGSize(width: -offset, height: 0)
        case "Temporal": return CGSize(width: offset, height: 0)
        default: return CGSize.zero // Central or unknown
        }
    }
}
