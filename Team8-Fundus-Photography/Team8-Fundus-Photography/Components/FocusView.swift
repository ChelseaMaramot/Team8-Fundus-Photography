//
//  FocusView.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-01-17.
//


import SwiftUI
struct FocusView: View {
 
 @Binding var position: CGPoint
 
 var body: some View {
    Circle()
       .frame(width: 70, height: 70)
       .foregroundColor(.clear)
       .border(Color.yellow, width: 1.5)
       .position(x: position.x, y: position.y) // To show view at the specific place
    }
}
