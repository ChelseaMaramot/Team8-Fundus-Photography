//
//  ScanSummary.swift
//  Team8-Fundus-Photography
//
//  Created by Anjola Adewale on 2025-01-16.
//

// for future, only show empty postions if we are still in imaging mode


import SwiftUI

struct ScanSummary: View {
    @ObservedObject var firebaseManager: FirebaseManager

    var body: some View {
        NavigationStack{
            ZStack {
                
                Color(UIColor.systemGray6) // Background color
                    .edgesIgnoringSafeArea(.all) // Extend to full screen
                
                VStack {
                    Text("Scan - \(formattedDate())")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding(.top, 10)

                    ScrollView {
                        ForEach(firebaseManager.imagesByPosition.keys.sorted(), id: \.self) { position in
                            ImageCard(
                                position: position,
                                images: firebaseManager.imagesByPosition[position] ?? [],
                                onAddImage: {
                                    print("Add image for \(position)")
                                }
                            )
                        }
                    }

                    Button(action: {
                        print("Navigate to Scan List")
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
                    .padding(.bottom, 20)
                }
                .padding(.top)
            }
            .colorScheme(.light)
            .navigationBarTitle("Image Summary", displayMode: .inline)
            .onAppear {
                firebaseManager.retrievePhotos()
                
            }
        
        }
    }

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd @h:mma"
        return formatter.string(from: Date())
    }
}

