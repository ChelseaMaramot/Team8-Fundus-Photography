import SwiftUI
import UIKit

extension Color {
    static let lightBlue = Color(red: 236/255, green: 241/255, blue: 255/255)
}

struct NewScanView: View {
    @State private var images: [String: UIImage] = [:]
    @EnvironmentObject var selectedDataManager: SelectedDataManager
    @StateObject var storageManager = FirebaseManager()
    @State private var scanName: String = ""
    @State private var scanDetails: String = ""

    
    var body: some View {
        NavigationView {
            VStack {
                Text("Scan Summary")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                    

                // Display primary images in quadrants
                PrimaryImagesQuadrantView(images: images)
                    .frame(width: 350, height: 300)
                    .padding(.vertical)
                    .background(Color.lightBlue) // Apply background
                    .cornerRadius(16) // Add rounded corners

                // Form Inputs
                VStack(alignment: .leading) {
                    Text("Scan Name").padding(.bottom, 5).fontWeight(.bold)
                    TextField("Scan name", text: $scanName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom)
                        .background(Color.lightBlue)
                        .cornerRadius(10)

                    Text("Session Comments").fontWeight(.bold)
                        .padding(.bottom, 5)
                    TextField("Session Comments", text: $scanDetails)
                        .frame(height: 100)
                        .padding(.bottom)
                        .background(Color.lightBlue)
                        .cornerRadius(16)
                }
                .padding(.horizontal)

                Spacer()

                Button(action: { /* Save Scan Logic */ }) {
                    Text("Done")
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .onAppear {
                storageManager.fetchPrimaryImages(patientID: selectedDataManager.getPatientID(), scanID: selectedDataManager.getScanID()) { fetchedImages in
                    self.images = fetchedImages
                }
            }
        }
    }
}
