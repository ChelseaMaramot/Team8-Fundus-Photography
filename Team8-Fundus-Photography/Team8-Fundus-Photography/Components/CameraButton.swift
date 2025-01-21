//
//  CameraButton.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2024-11-13.
//

import SwiftUI

struct CameraButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action, label: {
            Circle()
                .foregroundColor(.blue)
                .frame(width:80, height: 80, alignment: .center)
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.8), lineWidth: 2)
                        .frame(width: 65, height: 65, alignment: .center)
                )
        })
    }
}

#Preview {
    CameraButton(action: {
        print("Camera button tapped!")
    })
}
