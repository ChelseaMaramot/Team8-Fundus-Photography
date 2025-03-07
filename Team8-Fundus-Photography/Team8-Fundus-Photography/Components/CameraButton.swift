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
    
    @State private var selectionOffset: CGFloat = 0
    
    var body: some View {
        VStack {
            
            Button(action: {
                if mode == "photo" {
                    captureAction()
                } else {
                    isRecording ? stopRecordingAction() : startRecordingAction()
                }
            }, label: {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(1), lineWidth: isRecording ? 10 : 5 )
                            .fill(mode == "video" ? (isRecording ? Color.red : Color.blue) : Color.blue)
                            .frame(width: isRecording ? 45 : 55, height: isRecording ? 45 : 55)
                    )
                    .animation(.spring(), value: isRecording)
            })
            .padding(.bottom, 10)

            ZStack(alignment: .leading) {

                HStack {
                    Text("Photo")
                        .frame(width: 150)
                        .foregroundColor(mode == "photo" ? .white : .black)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                mode = "photo"
                                selectionOffset = 0
                            }
                        }
                    
                    Text("Video")
                        .frame(width: 150)
                        .foregroundColor(mode == "video" ? .white : .black)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                mode = "video"
                                selectionOffset = 150
                            }
                        }
                }
                .padding(10)
                .background(Color.blue.opacity(1))
                .clipShape(Capsule())
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
                
                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white)
                                    .frame(width: 150, height: 3)
                                    .offset(x: selectionOffset)
                                    .animation(.spring(), value: selectionOffset)
                                    .padding(.top, 40)
                                    .shadow(radius: 5)
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
