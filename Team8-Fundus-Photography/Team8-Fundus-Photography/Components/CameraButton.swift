//
//  CameraButton.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2024-11-13.
//

import SwiftUI

struct CameraButton: View {
    @Binding var isRecording: Bool
    @Binding var mode: String

    var captureAction: () -> Void
    var startRecordingAction: () -> Void
    var stopRecordingAction: () -> Void
    
    @State private var selectionOffset: CGFloat = 0 // To track the selected button offset
    
    var body: some View {
        VStack {
            
            // The main camera button
            Button(action: {
                if mode == "photo" {
                    captureAction()
                } else {
                    isRecording ? stopRecordingAction() : startRecordingAction()
                }
            }, label: {
                Circle()
                    .fill(isRecording ? Color.red : (mode == "photo" ? Color.blue : Color.red))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(Color.black.opacity(0.8), lineWidth: 2)
                            .frame(width: 65, height: 65)
                    )
            })
            .padding(.bottom, 10)

            ZStack(alignment: .leading) {

                HStack {
                    Text("Photo")
                        .frame(width: 150)
                        .foregroundColor(mode == "photo" ? .white : .gray)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                mode = "photo"
                                selectionOffset = 0
                            }
                        }
                    
                    Text("Video")
                        .frame(width: 150)
                        .foregroundColor(mode == "video" ? .white : .gray)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                mode = "video"
                                selectionOffset = 150
                            }
                        }
                }
                .padding(10)
                .background(Color.black.opacity(0.7))
                .clipShape(Capsule())
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
                
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 150, height: 3)
                    .offset(x: selectionOffset)
                    .animation(.spring(), value: selectionOffset)
                    .padding(.top, 40)
            }
        }
    }
}


#Preview {
    CameraButton(
        isRecording: .constant(false),
        mode: .constant("photo"),
        captureAction: { print("Photo captured!") },
        startRecordingAction: { print("Video recording started!") },
        stopRecordingAction: { print("Video recording stopped!") }
    )
}
