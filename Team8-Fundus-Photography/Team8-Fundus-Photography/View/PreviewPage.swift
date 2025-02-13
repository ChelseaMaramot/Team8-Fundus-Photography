//
//  PreviewPage.swift
//  Team8-Fundus-Photography
//
//  Created by Anjola Adewale on 2025-01-07.


import SwiftUI

struct PreviewPage: View {
    @Binding var image: UIImage?
    let onSave: () -> Void
    let onRetake: () -> Void
    @State var scale = 1.0
    @State var lastScale = 0.0
    @State var offset: CGSize = .zero
    @State var lastOffset: CGSize = .zero
    @State private var navigateToCrop = false
    @State private var navigateToSummary = false
    

    @State private var showCropView = false
    @StateObject var storageManager = FirebaseManager()

    var body: some View {
        NavigationStack {
            VStack {
                // Background color
                   // .edgesIgnoringSafeArea(.all) // Extend to full screen
                // ZStack to layer image and overlay
                ZStack {
                    if let image = image { // Safely unwrap the optional image
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.width)
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
                            .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.width)
                            .background(Color.gray)
                            .cornerRadius(10)
                    }
                }

                // Bottom controls (buttons)
                VStack {
                    Button("Crop") {
                        print("Image size before cropping: \(image?.size.width ?? 0)x\(image?.size.height ?? 0)")
                        showCropView = true // Show cropping view
                    }
                    .frame(width: 120, height: 44)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }.padding(.bottom, 10)

                HStack(spacing: 10) {
                    Button(action: {
                        if let image = image {
                            storageManager.saveToFirebase(image: image)
                        }
                        navigateToSummary = true
                    }) {
                        Text("Save")
                            .frame(width: 120, height: 44)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    NavigationLink(
                        destination: CameraView(),
                        label: {
                            Button(action: {
                                onRetake() // Reset crop view or any other logic
                                scale = 1.0
                                lastScale = 0.0
                                offset = .zero
                                lastOffset = .zero
                            }) {
                                Text("Retake")
                                    .frame(width: 120, height: 44)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    )
                }
                .padding(.bottom, 10)

                NavigationLink(
                    destination: ScanSummary(firebaseManager: FirebaseManager()),
                    isActive: $navigateToSummary,
                    label: { EmptyView() }
                )
            }
            .sheet(isPresented: $showCropView) {
                ImageCropView(
                    image: $image, // Pass the image binding
                    croppingStyle: .circular,
                    onCancel: { showCropView = false } // Close on cancel
                )
                
            }
//            Color(UIColor.white)
            .colorScheme(.light)
            .navigationTitle("Preview (manually cropped) Image")
        }
        .background(Color.white.edgesIgnoringSafeArea(.all)) // Move this here
    }

    private func handleScaleChange(_ zoom: CGFloat) -> CGFloat {
        max(1, lastScale + zoom - (lastScale == 0 ? 0 : 1))
    }

    private func handleOffsetChange(_ offset: CGSize) -> CGSize {
        var newOffset: CGSize = .zero
        newOffset.width = offset.width + lastOffset.width
        newOffset.height = offset.height + lastOffset.height
        return newOffset
    }
}
