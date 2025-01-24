////
////  PreviewPage.swift
////  Team8-Fundus-Photography
////
////  Created by Anjola Adewale on 2025-01-07.
////
//

import SwiftUI

struct PreviewPage: View {
    @State var image: UIImage // Make the image mutable
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

                HStack(spacing: 10) {
                    Button(action: {
                        storageManager.saveToFirebase(image: image)
                        navigateToSummary = true
                    }) {
                        Text("Save")
                            .frame(width: 120, height: 44)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        onRetake() // Close the crop view
                    }) {
                        NavigationLink(
                            destination: CameraView()
                        ) {
                            Text("Retake")
                                .frame(width: 120, height: 44)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }

                    Button("Crop") {
                        print("Image size before cropping: \(image.size.width)x\(image.size.height)")
                        showCropView = true // Show cropping view
                    }
                }
                .padding(.bottom, 50)
                
                NavigationLink(
                    destination: ScanSummary(),
                    isActive: $navigateToSummary,
                    label: { EmptyView() }
                )
            }
            .sheet(isPresented: $showCropView) {
                ImageCropView(
                    image: $image, // Pass image binding
                    croppingStyle: .circular,
                    onCancel: { showCropView = false } // Close on cancel
                )
            }
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

//struct PreviewPage: View {
//    @State var image: UIImage // Make the image mutable
////    @State var originalImage: UIImage
//    let onSave: () -> Void
//    let onRetake: () -> Void
//    @State var scale = 1.0
//    @State var lastScale = 0.0
//    @State var offset: CGSize = .zero
//    @State var lastOffset: CGSize = .zero
//    @State private var navigateToCrop = false
//    @State private var navigateToSummary = false
//    @State private var showCropView = false
//    @StateObject var storageManager = FirebaseManager()
//
//    var body: some View {
//        NavigationStack {
//            VStack {
//                Image(uiImage: image)
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    
//                    .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.width)
//                    .scaleEffect(scale)
//                    .offset(offset)
//                    .clipShape(Circle())
//                    .overlay(
//                        Circle()
//                            .stroke(Color.blue, lineWidth: 4)
//                    )
//                    .gesture(
//                        MagnificationGesture(minimumScaleDelta: 0)
//                            .onChanged { value in
//                                withAnimation(.interactiveSpring()) {
//                                    scale = handleScaleChange(value)
//                                }
//                            }
//                            .onEnded { _ in
//                                lastScale = scale
//                            }
//                            .simultaneously(
//                                with: DragGesture(minimumDistance: 0)
//                                    .onChanged { value in
//                                        withAnimation(.interactiveSpring()) {
//                                            offset = handleOffsetChange(value.translation)
//                                        }
//                                    }
//                                    .onEnded { _ in
//                                        lastOffset = offset
//                                    }
//                            )
//                    )
//                
//                HStack(spacing: 10) {
//                    Button(action: {
//                        storageManager.saveToFirebase(image: image)
//                        navigateToSummary = true
//                    }) {
//                        Text("Save")
//                            .frame(width: 120, height: 44)
//                            .background(Color.blue)
//                            .foregroundColor(.white)
//                            .cornerRadius(10)
//                    }
//                    
//                    Button(action: {
//                        onRetake() // Close the crop view
//                    }) {
//                        NavigationLink(
//                            destination: CameraView()
//                        ) {
//                            Text("Retake")
//                                .frame(width: 120, height: 44)
//                                .background(Color.blue)
//                                .foregroundColor(.white)
//                                .cornerRadius(10)
//                        }
//                    }
//
//
//                    // Navigate to the crop view
//                    Button("Crop") {
//                        print("Image size before cropping: \(image.size.width)x\(image.size.height)")
//                        showCropView = true // Show cropping view
//                    }
//                    
//                }
//                .padding(.bottom, 50)
//                
//                NavigationLink(
//                    destination: ScanSummary(),
//                    isActive: $navigateToSummary,
//                    label: { EmptyView() }
//                )
//            }
//            .sheet(isPresented: $showCropView) {
//                ImageCropView(
//                    image: $image, // Pass image binding
//                    croppingStyle: .circular,
//                    onCancel: { showCropView = false } // Close on cancel
//                )
//            }
//            
//            .navigationTitle("Preview (manually cropped) Image")
//        }
//        .background(Color.white)
//    }
//
//    private func handleScaleChange(_ zoom: CGFloat) -> CGFloat {
//        max(1, lastScale + zoom - (lastScale == 0 ? 0 : 1))
//    }
//
//    private func handleOffsetChange(_ offset: CGSize) -> CGSize {
//        var newOffset: CGSize = .zero
//
//        newOffset.width = offset.width + lastOffset.width
//        newOffset.height = offset.height + lastOffset.height
//
//        return newOffset
//    }
//}
