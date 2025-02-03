//
//  ScanListViewModel.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-02-02.
//

import SwiftUI

class ScanListViewModel: ObservableObject {
    @Published var scans: [Scan] = []
    @Published var isShowingAddScanSheet = false
    
    private var storageManager = FirebaseManager()
    
    // Function to fetch the scan list for a patient
    func fetchScans(for patientID: UUID) {
        storageManager.fetchScanListForPatient(patientID: patientID) { [weak self] fetchedScans in
            self?.scans = fetchedScans
        }
    }
    
    // Function to add a new scan to the patient
    func addScan(patientID: UUID, scanName: String) {
        storageManager.addScanToFirebase(patientId: patientID, scanName: scanName) { [weak self] success in
            if success {
                self?.fetchScans(for: patientID) // Reload scans after adding a new one
            }
        }
    }
}
