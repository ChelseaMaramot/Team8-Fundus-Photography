//
//  ScanSummary.swift
//  Team8-Fundus-Photography
//
//  Created by Anjola Adewale on 2025-01-16.
//

//import SwiftUI
import SwiftUI

struct ScanSummary: View {
    @ObservedObject var firebaseManager: FirebaseManager

    var body: some View {
        List {
            ForEach(firebaseManager.imagesByPosition.values.flatMap { $0 }, id: \.self) { image in
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150) // Adjust size for readability
                    .cornerRadius(10)
                    .shadow(radius: 3)
                    .padding(.vertical, 5)
            }
        }
        .navigationTitle("Scan Summary")
        .onAppear {
            firebaseManager.retrievePhotos()
            // fix this to only append new images to the list
        }
    }
}
