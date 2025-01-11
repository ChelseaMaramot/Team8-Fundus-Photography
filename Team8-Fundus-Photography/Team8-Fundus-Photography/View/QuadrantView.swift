//
//  QuadrantView.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-01-11.
//

import SwiftUI

struct QuadrantView: View {
    @State private var selectedQuadrant: String = "Central"
    @State private var showQuadrantSelector = false
    
    var body: some View {
        ZStack{
            VStack {
                HStack {
                    Spacer()
                        QuadrantSelectorView(
                            selectedQuadrant: $selectedQuadrant,
                            isInteractive: false,
                            size: 20
                        )
                        .frame(width: 120, height: 120)
                        .offset(x: -20, y:10)
                        .overlay(
                                Rectangle()
                                    .stroke(Color.clear)
                                    .frame(width: 120, height: 120)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        withAnimation(.spring()) {
                                            showQuadrantSelector.toggle()
                                        }
                                    }
                                )
                }
                Spacer()
            }
            
            if showQuadrantSelector {
                QuadrantSelectorView(selectedQuadrant: $selectedQuadrant, isInteractive: true, size: 90)
            }
        }
    }
}
#Preview {
    QuadrantView()
}
