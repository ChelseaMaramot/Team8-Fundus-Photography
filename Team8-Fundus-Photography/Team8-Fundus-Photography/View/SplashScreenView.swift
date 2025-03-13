//
//  SplashScreenView.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-03-13.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    @State private var rotation: Double = 0
    @State private var textOffset = CGSize(width: -UIScreen.main.bounds.width, height: 0)
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            
            VStack(spacing: 0){
                VStack{
                    Image(.logo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 210, height: 200)
                        .clipped() 
                }
                .scaleEffect(size)
                .opacity(opacity)
                .rotationEffect(.degrees(rotation))
                .onAppear{
                    withAnimation(.easeIn(duration: 1.2)){
                        self.size = 0.9
                        self.opacity = 1.0
                    }
                    
                    withAnimation(.easeInOut(duration: 1).delay(1.2)) {
                        self.rotation = 360
                    }
                }
                
                Text("SmartSc🔍pe")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(.blue)
                    .offset(textOffset)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1).delay(1.5)) {
                            self.textOffset = CGSize(width: 0, height: 0)
                        }
                    }
            }
            .onAppear{
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.isActive = true
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
