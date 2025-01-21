//
//  PreviewPage.swift
//  Team8-Fundus-Photography
//
//  Created by Anjola Adewale on 2025-01-07.
//

import SwiftUI

struct PreviewPage: View {
    let image: UIImage
    let onSave: () -> Void
    @State var scale = 1.0
    @State var lastScale = 0.0
    @State var offset: CGSize = .zero
    @State var lastOffset: CGSize = .zero
    @State private var navigateToSummary = false
    
    var body: some View {
        NavigationStack{
            VStack {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .scaleEffect(scale)
                    .offset(offset)
                    .clipShape(Circle())
                    .overlay(
                        Circle() // Add a circle overlay for the border
                            .stroke(Color.blue, lineWidth: 4) // Border color and width
                    )
                    .gesture(
                        MagnificationGesture(minimumScaleDelta: 0)
                            .onChanged({ value in
                                withAnimation(.interactiveSpring()) {
                                    scale = handleScaleChange(value)
                                }
                            })
                            .onEnded({ _ in
                                lastScale = scale
                            })
                            .simultaneously(
                                with: DragGesture(minimumDistance: 0)
                                    .onChanged({ value in
                                        withAnimation(.interactiveSpring()) {
                                            offset = handleOffsetChange(value.translation)
                                        }
                                    })
                                    .onEnded({ _ in
                                        lastOffset = offset
                                    })

                            )
                    )
                HStack(spacing: 10) {  // Adjust spacing between buttons
                    Button(action: {
                        saveToFirebase(image: image)
                        navigateToSummary = true
                    }) {
                        Text("Save")
                            .frame(width: 120, height: 44)  // Equal size
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    NavigationLink(destination: CameraView()) {
                        Text("Retake")
                            .frame(width: 120, height: 44)  // Same size as Save
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.bottom, 50)

                    NavigationLink(
                        destination: ScanSummary(),
                        isActive: $navigateToSummary,  // Bind the state to trigger navigation
                        label: { EmptyView() } // Invisible link, only used for navigation
                    )
                    
            }
            .background(Color.white)
            .navigationTitle("Preview (manually cropped) Image")
        }
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


//Image("cute-kitten").resizable().aspectRatio(contentMode: .fit).padding().mask {Circle().offset(x:##,y:##)}
