//
//  ScanListView.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-01-09.
//

import SwiftUI

struct ScanListView: View {
    
    @StateObject private var storageManager = FirebaseManager()
    @State private var scans: [Scan] = []
    @State private var isShowingAddScanSheet = false
    
    @EnvironmentObject var selectedDataManager: SelectedDataManager
    
    var body: some View {
        

            VStack {
                
                if !scans.isEmpty{
                    List(scans) { scan in
                        NavigationLink(destination: ImageView()) {
                            Card(name: scan.name, isStitched: scan.isStitched)
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
                if let patientID = selectedDataManager.selectedPatientID {
                    storageManager.fetchScanListForPatient(patientID: patientID) { fetchedScans in
                        scans = fetchedScans
                    }
                }
            }
            .sheet(isPresented: $isShowingAddScanSheet) {
                BottomSheet(
                    title: "Add New Scan",
                    placeholder: "Enter Scan Name"
                ) {newScanName in
                    if let patientId = selectedDataManager.selectedPatientID {
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
    
}

#Preview {
    ScanListView()
}
