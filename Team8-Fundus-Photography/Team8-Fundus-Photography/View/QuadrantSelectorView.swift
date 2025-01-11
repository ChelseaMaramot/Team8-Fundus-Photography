//
//  QuadrantSelectorView.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-01-09.
//

import SwiftUI


struct CircleButton: View {
    let quadrant: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(isSelected ? Color.blue : Color.gray.opacity(0.3))
                .frame(width: 90, height: 90)
                .overlay(Text(quadrant).foregroundColor(isSelected ? Color.white : Color.black))
        }
    }
}

struct QuadrantSelectorView: View {
    @State private var selectedQuadrant: String? = nil
    
    var body: some View {
        VStack{
            
            ZStack{
                CircleButton(quadrant: "Central", isSelected: selectedQuadrant == "Central"){
                    selectedQuadrant = "Central"
                }
                
                CircleButton(quadrant: "Superior", isSelected: selectedQuadrant == "Superior"){
                    selectedQuadrant = "Superior"
                }.offset(y: -100)
                
                CircleButton(quadrant: "Nasal", isSelected: selectedQuadrant == "Nasal"){
                    selectedQuadrant = "Nasal"
                }.offset(x: -100)
                
                CircleButton(quadrant: "Inferior", isSelected: selectedQuadrant == "Inferior"){
                    selectedQuadrant = "Inferior"
                }
                .offset(y:100)
                
                CircleButton(quadrant: "Temporal", isSelected: selectedQuadrant == "Temporal"){
                    selectedQuadrant = "Temporal"
                }
                .offset(x: 100)
            }
        }
    }
}

#Preview {
    QuadrantSelectorView()
}
