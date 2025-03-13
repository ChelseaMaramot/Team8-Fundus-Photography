//
//  registerView.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-02-04.
//

import SwiftUI
import UIKit

struct registerView: View {
    
    let colors = cardColors()
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                let screenWidth = geometry.size.width
                let screenHeight = geometry.size.height
                
                VStack {
                    ZStack {
                        Rectangle()
                            .frame(width: screenWidth * 0.35, height: screenWidth * 0.35)
                            .cornerRadius(screenWidth * 0.08)
                            .foregroundStyle(.blue)
                        
                        Image(.logo)
                            .resizable()
                            .scaledToFit()
                            .frame(width: screenWidth * 0.25, height: screenWidth * 0.25)
                            .cornerRadius(screenWidth * 0.08)
                    }
                    
                    Text("Smart")
                        .foregroundStyle(.blue)
                        .font(.system(size: screenWidth * 0.12))
                        .fontWeight(.thin)
                    
                    Text("Scope")
                        .foregroundStyle(.blue)
                        .font(.system(size: screenWidth * 0.12))
                        .fontWeight(.thin)
                        .padding(.bottom, screenHeight * 0.05)
                    
                    Text("Step into the future of eye care with Smart Scope. Combining advanced technology and accessibility, for clearer vision and better health outcomes.")
                        .font(.system(size: screenWidth * 0.03))
                        .fontWeight(.light)
                        .multilineTextAlignment(.center)
                        .frame(width: screenWidth * 0.8)
                        .padding()
                    
                    NavigationLink(destination: LoginView()) {
                        Text("Login")
                            .font(.system(size: screenWidth * 0.06))
                            .fontWeight(.medium)
                            .padding()
                            .frame(width: screenWidth * 0.8, height: screenHeight * 0.08)
                            .background(.blue)
                            .foregroundColor(.white)
                            .cornerRadius(30)
                    }
                    .buttonStyle(PlainButtonStyle())
               
                    
                    NavigationLink(destination: signUpView()) {
                        Text("Sign Up")
                            .font(.system(size: screenWidth * 0.06))
                            .fontWeight(.medium)
                            .padding()
                            .frame(width: screenWidth * 0.8, height: screenHeight * 0.08)
                            .background(colors.cardBackground)
                            .foregroundColor(.blue)
                            .cornerRadius(30)
                    }
                    .buttonStyle(PlainButtonStyle())
                
                }
                .frame(width: screenWidth, height: screenHeight)
            }
        }
    }
}

#Preview {
    registerView()
}
