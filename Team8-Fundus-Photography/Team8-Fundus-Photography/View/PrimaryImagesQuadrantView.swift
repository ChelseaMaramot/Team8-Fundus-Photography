//
//  PrimaryImagesQuadrantView.swift
//  Team8-Fundus-Photography
//
//  Created by Anjola Adewale on 2025-03-09.
//

import SwiftUI



struct PrimaryImagesQuadrantView: View {
    let images: [String: UIImage] // Dictionary of quadrant names to images
    
    var body: some View {
        ZStack {

            // Position each image in its quadrant
            ForEach(["Superior", "Inferior", "Nasal", "Temporal", "Central"], id: \.self) { quadrant in
                if let image = images[quadrant] {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90) // Adjust size as needed
                        .clipShape(Circle()) // Ensure images are circular
                        .overlay(
                            Circle().stroke(Color.blue, lineWidth: 2) // Border to indicate active scan
                        )
                        .offset(offsetForQuadrant(quadrant)) // Position image correctly
                } else {
                    // Placeholder if no image exists for this quadrant
                    Circle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 90, height: 90)
                        .overlay(
                            Text(quadrant.prefix(2)) // Show initials (e.g., "Su" for Superior)
                                .foregroundColor(.black)
                                .font(.caption)
                        )
                        .offset(offsetForQuadrant(quadrant))
                }
            }
        }
    }
    
    private func offsetForQuadrant(_ quadrant: String) -> CGSize {
        let offset: CGFloat = 110 // Adjust distance from center

        switch quadrant {
        case "Superior": return CGSize(width: 0, height: -offset)
        case "Inferior": return CGSize(width: 0, height: offset)
        case "Nasal": return CGSize(width: -offset, height: 0)
        case "Temporal": return CGSize(width: offset, height: 0)
        default: return CGSize.zero
        }
    }
}
