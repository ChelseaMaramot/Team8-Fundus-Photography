//
//  ScanListView.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-01-09.
//

import SwiftUI

struct ScanListView: View {
    
    var patientId: String
    @StateObject private var storageManager = FirebaseManager()
    @State private var scans: [Scan] = []
    @State private var isShowingAddScanSheet = false
    
    var body: some View {
        

            VStack {
                
                if !scans.isEmpty{
                    List(scans) { scan in
                        NavigationLink(destination: ImageView()) {
                            Card(name: scan.name, date: scan.createdDate, isStitched: scan.isStitched)
                        }
                    }
                } else {
                    Text("No Scan found.")
                }
                
                NavigationLink{
                    CameraView()
                } label: {
                    Text("Add New Scan")
                }  .buttonStyle(.borderedProminent)
                    .controlSize(.large)
            }
            .onAppear {
                storageManager.fetchScanListForPatient(patientID: patientId) { fetchedScans in
                    scans = fetchedScans
                }
            }
            .sheet(isPresented: $isShowingAddScanSheet) {
                BottomSheet(
                    title: "Add New Scan",
                    placeholder: "Enter Scan Name"
                ) {newScanName in
                    storageManager.addScanToFirebase(patientId: patientId, scanName: newScanName){ success in
                        if success {
                            // update the list
                            storageManager.fetchScanListForPatient(patientID: patientId) { fetchedScans in
                                scans = fetchedScans
                            }
                        }
                    }
                    
                }
            }
        }
    
}

#Preview {
    ScanListView(patientId: "Chelsea")
}
