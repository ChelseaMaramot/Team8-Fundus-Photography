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
        NavigationView{
            VStack{
                
                Rectangle()
                    .frame(width: 138, height:138)
                    .cornerRadius(32)
                    .foregroundStyle(.blue)
                
                Text("Smart")
                    .foregroundStyle(.blue)
                    .font(.system(size: 48))
                    .fontWeight(.thin)
                Text("Scope")
                    .foregroundStyle(.blue)
                    .font(.system(size: 48))
                    .fontWeight(.thin)
                    .padding(.bottom, 90)
                
                
                Text("Step into the future of eye care with Smart Scope. Combining advanced technology and accessibility, for clearer vision and better health outcomes.")
                    .font(.system(size: 12))
                    .fontWeight(.light)
                    .multilineTextAlignment(.center)
                    .frame(width: 300, height: 60)
                    .padding()
                
                
                NavigationLink(destination: loginView()){
                    Text("Login")
                }   .font(.system(size: 24))
                    .fontWeight(.medium)
                    .padding()
                    .frame(width: 300, height: 60)
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(30)
                
                
                NavigationLink(destination: registerView()){
                    Text("Sign Up")
                } .font(.system(size: 24))
                    .fontWeight(.medium)
                    .padding()
                    .frame(width: 300, height: 60)
                    .background(colors.cardBackground)
                    .foregroundColor(.blue)
                    .cornerRadius(30)
            }
        }
    }
    
}


#Preview {
    registerView()
}
