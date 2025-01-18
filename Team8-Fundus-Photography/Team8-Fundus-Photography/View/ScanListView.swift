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
    @State private var scans: [FirebaseManager.Scan] = []
    
    var body: some View {
        VStack {
            
            if !scans.isEmpty{
                List(scans, id: \.self) { scan in
                    NavigationLink(destination: ImageView()) {
                        Card(name: scan.name, date: scan.createdDate, isStitched: scan.isStitched)
                    }
                }
            } else {
                Text("No Scan found.")
            }
            Button {
            } label: {
                Text("Add New Scan")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .onAppear {
            storageManager.fetchScanListForPatient(patientID: patientId) { fetchedScans in
                scans = fetchedScans
            }
        }
    }
}

#Preview {
    ScanListView(patientId: "testPatient1")
}
