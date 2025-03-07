//
//  CameraButton.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2024-11-13.
//

import SwiftUI

struct CameraButton: View {
    @Binding var isRecording: Bool
    var captureAction: () -> Void
    var startRecordingAction: () -> Void
    var stopRecordingAction: () -> Void
    
    var body: some View {
        Button(action: {
            if !isRecording {
                captureAction()
            }else{
                isRecording = false
                stopRecordingAction()
            }
        }, label: {
            Circle()
                .fill(isRecording ? Color.red : Color.blue)
                .frame(width: 80, height: 80, alignment: .center)
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.8), lineWidth: 2)
                        .frame(width: 65, height: 65, alignment: .center)
                )
        })
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.3)
                .onEnded { _ in
                    isRecording = true
                    startRecordingAction()
                }
        )
    }
}


#Preview {
    CameraButton(
        isRecording: .constant(false),
        captureAction: {
            print("Photo captured!")
        },
        startRecordingAction: {
            print("Video recording started!")
        },
        stopRecordingAction: {
            print("Video recording stopped!")
        }
    )
}
