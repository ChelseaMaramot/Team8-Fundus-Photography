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
    @State private var previousSelectedQuadrant: String = "Central"

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    // Mini version when not showing the selector
                    if !showQuadrantSelector {
                        QuadrantSelectorView(
                            selectedQuadrant: $selectedQuadrant,
                            isInteractive: false,
                            size: 20
                        )
                        .frame(width: 120, height: 120)
                        .offset(x: -10, y: 10)
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
                }
                Spacer()
            }
            if showQuadrantSelector {
                
                Color.black.opacity(0.5)
                                   .edgesIgnoringSafeArea(.all)
                                   .blur(radius: 10)
                                   .transition(.opacity)
                                   .animation(.easeInOut, value: showQuadrantSelector)

                
                
                QuadrantSelectorView(
                    selectedQuadrant: $selectedQuadrant,
                    isInteractive: true,
                    size: 90
                )
                .onChange(of: selectedQuadrant) { newQuadrant in
                    if newQuadrant != previousSelectedQuadrant {
                        previousSelectedQuadrant = newQuadrant
                        withAnimation(.spring()) {
                            showQuadrantSelector = false
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    QuadrantView()
}
