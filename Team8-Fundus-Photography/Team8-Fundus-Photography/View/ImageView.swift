//
//  ImageView.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-01-09.
//



import SwiftUI

struct ImageView: View {
    @State var image: UIImage?
    @EnvironmentObject var selectedDataManager: SelectedDataManager
    @State var isFromVideoCapture: Bool = false

    @State private var scale = 1.0
    @State private var lastScale = 0.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var navigateToSummary = false
    @State private var showCropView = false
    @StateObject private var storageManager = FirebaseManager()

    var imageBinding: Binding<UIImage?> {
        Binding(
            get: { image },
            set: { image = $0 }
        )
    }

    var body: some View {
        VStack {
            HStack {
                Text(" Scan: \(selectedDataManager.getScanName()) - \(selectedDataManager.getQuadrant().rawValue)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity, alignment: .leading) // Align left
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            Spacer().frame(height: 20)

            // ZStack: Image & Crop Button Layered
            ZStack {
                //  Image Preview with Gestures
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
                            Circle().stroke(Color.blue, lineWidth: 4)
                        )
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    withAnimation(.interactiveSpring()) {
                                        scale = handleScaleChange(value)
                                    }
                                }
                                .onEnded { _ in
                                    lastScale = scale
                                }
                                .simultaneously(
                                    with: DragGesture()
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
                        .clipShape(Circle())
                }

               
                if isFromVideoCapture {
                    VStack {
                        HStack {
                            Spacer() // Push button to the right
                            Button(action: {
                                print("Image size before cropping: \(image?.size.width ?? 0)x\(image?.size.height ?? 0)")
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.prepare()
                                generator.impactOccurred()
                                showCropView = true
                            }) {
                                Text("Crop")
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            
                            .padding(.top, 10) // Ensure it's not too close to the image
                        }
                        Spacer() // Keep button at the top
                    }
                    .zIndex(2) // Makes sure the crop button is ALWAYS on top!
                }
            }
            .padding(.top, 10)

            .sheet(isPresented: $showCropView) {
                if let _ = image {
                    ImageCropView(
                        image: imageBinding,
                        croppingStyle: .circular,
                        onCancel: { showCropView = false }
                    )
                } else {
                    Text("No image available for cropping")
                        .frame(width: 300, height: 200)
                        .background(Color.red)
                }
            }
        }
        .navigationBarTitle("Preview", displayMode: .inline)
    }

    private func handleScaleChange(_ zoom: CGFloat) -> CGFloat {
        max(1, lastScale + zoom - (lastScale == 0 ? 0 : 1))
    }

    private func handleOffsetChange(_ translation: CGSize) -> CGSize {
        CGSize(width: translation.width + lastOffset.width,
               height: translation.height + lastOffset.height)
    }
}

#Preview {
    ImageView(image: UIImage(named: "sample") ?? UIImage(), isFromVideoCapture: true)
}
