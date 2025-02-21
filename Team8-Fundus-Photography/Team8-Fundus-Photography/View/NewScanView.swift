//
//  NewScanView.swift
//  Team8-Fundus-Photography
//
//  Created by Anjola Adewale on 2025-02-21.
//


import SwiftUI

struct NewScanView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var scanName: String = ""
    @State private var scanDetails: String = ""
    @State private var scanDate: Date = Date()
    @State private var isSaving: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        NavigationView { // Embed in NavigationView for toolbar
            VStack { // Use VStack for main layout
                Text("Scan Summary") // Title at the top
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)

                // Eye Diagram View (replace with your actual implementation)
                EyeDiagramView()
                    .frame(height: 200) // Adjust height as needed
                    .padding(.vertical)

                // Form Inputs
                VStack(alignment: .leading) { // Align labels to the left
                    Text("Scan Name")
                        .padding(.bottom, 5)
                    TextField("scan name", text: $scanName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom)

                    Text("Session Comments")
                        .padding(.bottom, 5)
                    TextField("Session Comments", text: $scanDetails)
                        .frame(height: 100)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray))
                            
                }
                .padding(.horizontal) // Add horizontal padding to the form fields

                Spacer() // Push button to the bottom

                // Scan List Button
                Button(action: {
                    // Action for Scan List button
                }) {
                    Text("Scan List")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .padding(.bottom) // Add padding at the bottom
            }
            .navigationBarBackButtonHidden(true) // Hide default back button
            .toolbar { // Add custom back button to the toolbar
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left") // Use a chevron or custom image
                        Text("Save Scan") // Match the design
                    }
                }
            }
        }
    }

    // ... (saveScan function remains the same)
}

// Placeholder for Eye Diagram View (replace with your actual view)
struct EyeDiagramView: View {
    var body: some View {
        // Replace with your custom eye diagram drawing code
        // This example uses a ZStack with circles for the points
        ZStack {
            Circle()
                .fill(Color.gray.opacity(0.2))
            Circle()
                .fill(Color.black)
                .frame(width: 20, height: 20)
                .offset(x: -50, y: -50) // Example position
            Circle()
                .fill(Color.black)
                .frame(width: 20, height: 20)
                .offset(x: 50, y: -50) // Example position
            Circle()
                .fill(Color.black)
                .frame(width: 20, height: 20)
                .offset(x: -50, y: 50) // Example position
            Circle()
                .fill(Color.black)
                .frame(width: 20, height: 20)
                .offset(x: 50, y: 50) // Example position
            Circle()
                .fill(Color.black)
                .frame(width: 20, height: 20)
                .offset(y: -70) // Example position
            Circle()
                .fill(Color.black)
                .frame(width: 20, height: 20)
                .offset(y: 70) // Example position
        }
    }
}


#Preview {
    NewScanView()
}
