//
//  ImageView.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-01-09.
//

import SwiftUI

struct ImageView: View {
    @State var image: UIImage?
    

    
    @State private var scale = 1.0
    @State private var lastScale = 0.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var navigateToSummary = false
    @State private var showCropView = false
    @StateObject private var storageManager = FirebaseManager()

    var body: some View {
       
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Scan - \(formattedDate())")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding(.top, 10)

                    // Image preview with gesture support
                    ZStack {
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: UIScreen.main.bounds.width * 0.9,
                                       height: UIScreen.main.bounds.width)
                                .scaleEffect(scale)
                                .offset(offset)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.blue, lineWidth: 4)
                                )
                                .gesture(
                                    MagnificationGesture(minimumScaleDelta: 0)
                                        .onChanged { value in
                                            withAnimation(.interactiveSpring()) {
                                                scale = handleScaleChange(value)
                                            }
                                        }
                                        .onEnded { _ in
                                            lastScale = scale
                                        }
                                        .simultaneously(
                                            with: DragGesture(minimumDistance: 0)
                                                .onChanged { value in
                                                    withAnimation(.interactiveSpring()) {
                                                        offset = handleOffsetChange(value.translation)
                                                    }
                                                }
                                                .onEnded { _ in
                                                    lastOffset = offset
                                                }
                                        )
                                )
                        } else {
                            Text("No image selected")
                                .frame(width: UIScreen.main.bounds.width * 0.9,
                                       height: UIScreen.main.bounds.width)
                                .background(Color.gray)
                                .cornerRadius(10)
                        }
                    }
                    
                }
                .padding(.top)
            }
            .navigationBarTitle("Preview", displayMode: .inline)
            .onAppear {
                // Load images or perform any additional setup if needed
            }
            // Present crop view as a sheet
            .sheet(isPresented: $showCropView) {
                ImageCropView(
                    image: $image, // Pass the image binding to the crop view
                    croppingStyle: .circular,
                    onCancel: { showCropView = false } // Dismiss the crop view on cancel
                )
            }
        
    }

    // Helper functions for gesture handling
    private func handleScaleChange(_ zoom: CGFloat) -> CGFloat {
        max(1, lastScale + zoom - (lastScale == 0 ? 0 : 1))
    }

    private func handleOffsetChange(_ translation: CGSize) -> CGSize {
        CGSize(width: translation.width + lastOffset.width,
               height: translation.height + lastOffset.height)
    }
    
    // Helper function to format the date
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd @h:mma"
        return formatter.string(from: Date())
    }
}
