//
//  QuadrantView.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-01-11.
//

import SwiftUI

struct QuadrantView: View {
    @EnvironmentObject var selectedDataManager: SelectedDataManager
    @State private var selectedQuadrant: RegionTypes
    @Binding var showQuadrantSelector: Bool
    @State private var previousSelectedQuadrant: RegionTypes
    var cameraManager: CameraManager
    
    init(cameraManager: CameraManager,  showQuadrantSelector: Binding<Bool>, selectedDataManager: SelectedDataManager) {
        _selectedQuadrant = State(initialValue: selectedDataManager.getQuadrant())
        _previousSelectedQuadrant = State(initialValue: selectedDataManager.getQuadrant())
        _showQuadrantSelector = showQuadrantSelector
        self.cameraManager = cameraManager
    }
    
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
                        .frame(width: 100, height: 100)
                        .offset(x: -10, y: 0)
                        .overlay(
                            Rectangle()
                                .stroke(Color.clear)
                                .frame(width: 100, height: 100)
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
                
                Color.black.opacity(0.7)
                                   .edgesIgnoringSafeArea(.all)
                                   .blur(radius: 5)
                                   .transition(.opacity)
                                   .animation(.easeInOut, value: showQuadrantSelector)
                                   .onTapGesture {
                                       withAnimation(.spring()) {
                                           showQuadrantSelector = false
                                       }
                                   }

                QuadrantSelectorView(
                    selectedQuadrant: $selectedQuadrant,
                    isInteractive: true,
                    size: 90
                )
                .onChange(of: selectedQuadrant) { newQuadrant in
                    if newQuadrant != previousSelectedQuadrant {
                        previousSelectedQuadrant = newQuadrant
                        selectedDataManager.setQuadrant(newQuadrant)
                        withAnimation(.spring()) {
                            showQuadrantSelector = false
                        }
                    }
                }
                .onAppear {
                    // Stop camera session when the quadrant selector is large
                    cameraManager.stopSession()
                }
                .onDisappear {
                    // Start camera session when the quadrant selector is smaller
                    cameraManager.startSession {
                    }
                }
            }
        }
    }
}


//#Preview {
//    QuadrantView(
//        showQuadrantSelector: false
//    ).environmentObject(SelectedDataManager())
//}
