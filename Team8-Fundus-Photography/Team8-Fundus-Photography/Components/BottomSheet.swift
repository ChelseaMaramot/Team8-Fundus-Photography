//
//  BottomSheet.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-01-23.
//

import SwiftUI

struct BottomSheet: View {
    
    @Environment(\.dismiss) var dismiss
    
    
    @State private var inputText = ""
    
    var title: String
    var placeholder: String
    var onSave: (String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            
            VStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
            }
            
            VStack(spacing: 16){
                TextField(placeholder, text: $inputText)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 30))
                    .padding()
                
             
                Button(action: {
                    print("Button tapped with input: \(inputText)")
                    onSave(inputText)
                    dismiss()
                }) {
                    Text("Confirm")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(inputText.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .contentShape(Rectangle()) 
                .padding(.horizontal)
                .disabled(inputText.isEmpty)

                Spacer()
            }
            .padding(.top, 16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: -2)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    BottomSheet(
        title: "Add New Patient",
        placeholder: "Enter Patient Name"
    ) { newPatientName in
        print("New patient name: \(newPatientName)")
    }
}
