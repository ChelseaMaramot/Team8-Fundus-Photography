//
//  ImageView.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-01-09.
//


import SwiftUI
import Firebase

struct ImageView: View {
    @State var labeledImage: LabeledImage

    @State private var scale = 1.0
    @State private var lastScale = 0.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @StateObject private var viewModel = FirebaseManager()
    @State private var showCropView = false
    @State private var showCommentSheet = false
    @State private var editedComment: String = ""
    @EnvironmentObject var selectedDataManager: SelectedDataManager

    var imageBinding: Binding<UIImage?> {
        Binding(
            get: { labeledImage.image },
            set: { labeledImage.image = $0 }
        )
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 16) {
                Text("Scan - \(formattedDate())")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .padding(.top, 10)

                // Image with gesture support
                ZStack {
                    if let image = labeledImage.image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width * 0.9,
                                   height: UIScreen.main.bounds.width)
                            .scaleEffect(scale)
                            .offset(offset)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.blue, lineWidth: 4))
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
                                    .simultaneously(with: DragGesture(minimumDistance: 0)
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
                        Text("No image available")
                            .frame(width: UIScreen.main.bounds.width * 0.9,
                                   height: UIScreen.main.bounds.width)
                            .background(Color.gray)
                            .cornerRadius(10)
                    }
                }

                // Comment display
                if let comment = labeledImage.comment, !comment.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Comment:")
                            .fontWeight(.bold)
                        Text(comment)
                            .italic()
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }

                // Add/Edit Comment Button
                Button(action: {
                    editedComment = labeledImage.comment ?? ""
                    showCommentSheet = true
                }) {
                    Text((labeledImage.comment ?? "").count > 2 ? "Edit Comment" : "Add Comment")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }

                Spacer()
            }
        }
        .navigationTitle("Preview")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing:
            Button("Edit") {
                showCropView = true
            }
        )
        .sheet(isPresented: $showCropView, onDismiss: {
            if let updatedImage = labeledImage.image {
                viewModel.updateCroppedImageInFirebase(
                    image: updatedImage,
                    patientID: selectedDataManager.getPatientID(),
                    scanID: selectedDataManager.getScanID(),
                    position: labeledImage.position,
                    imageID: labeledImage.id
                ) { success in
                    if success {
                        print("Cropped image successfully updated.")
                    }
                }
            }
        }) {
            ImageCropView(
                image: imageBinding,
                croppingStyle: .circular,
                onCancel: { showCropView = false }
            )
        }

      
        .sheet(isPresented: $showCommentSheet) {
            NavigationView {
                VStack {
                    TextEditor(text: $editedComment)
                        .padding()
                        .frame(minHeight: 150)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                        .padding()

                    Spacer()
                }
                .navigationTitle("Comment")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            viewModel.updateImageComment(imageID: labeledImage.id, newComment: editedComment) { success in
                                if success {
                                    labeledImage.comment = editedComment
                                }
                                showCommentSheet = false
                            }
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showCommentSheet = false
                        }
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func handleScaleChange(_ zoom: CGFloat) -> CGFloat {
        max(1, lastScale + zoom - (lastScale == 0 ? 0 : 1))
    }

    private func handleOffsetChange(_ translation: CGSize) -> CGSize {
        CGSize(width: translation.width + lastOffset.width,
               height: translation.height + lastOffset.height)
    }

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd @h:mma"
        return formatter.string(from: Date())
    }
}
