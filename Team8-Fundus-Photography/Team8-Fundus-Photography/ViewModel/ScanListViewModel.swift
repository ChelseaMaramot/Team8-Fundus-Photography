//
//  ScanListViewModel.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-02-02.
//

import SwiftUI
import FirebaseFirestore

class ScanListViewModel: ObservableObject {
    @Published var scanList: [Scan] = []
    @Published var isShowingAddScanSheet = false
    
 
    private var patientID: String
    private var storageManager = FirebaseManager()
    
    init(patientID: String) {
        self.patientID = patientID
        fetchScans()
    }
    
    func fetchScans() {
       
        var fetchedScans: [Scan] = []
        let db = Firestore.firestore()
        let selectedPatientID = self.patientID
        
        print("fetching scans for", selectedPatientID)
        
        let scanRef = db.collection("patients").document(selectedPatientID)
            .collection("scans")
        
        scanRef.getDocuments{ querySnapshot, error in
            if let error = error {
                print("Error fetching scans: \(error.localizedDescription)")
                return
            }
            
            for document in querySnapshot?.documents ?? [] {
                let data = document.data()
                _ = document.documentID
                let name = data["name"]
                let isStitched = data["isStitched"]
                
                let scan = Scan(name: name as! String,
                                regions: ScanRegions(),
                                isStitched: (isStitched != nil))
                
                fetchedScans.append(scan)
                
            }
            self.scanList = fetchedScans
            print(self.scanList)
        }
    }
    
    // Function to add a new scan to the patient
    func addScan(patientID: String, scanName: String) {
        let db = Firestore.firestore()
        let newScanRef = db.collection("patients").document(patientID).collection("scans").document(UUID().uuidString)
        
        newScanRef.setData([
            "name": scanName,
            "isStitched": false,
            "regions": ScanRegions()
        ]){ error in
            if let error = error {
                print("Error adding scans: \(error.localizedDescription)")
            } else {
                print("Scan added successfully")
                self.fetchScans()
            }
        }
    }
}
