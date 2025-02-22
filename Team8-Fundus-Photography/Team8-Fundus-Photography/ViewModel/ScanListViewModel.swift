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
    @EnvironmentObject var selectedDataManager: SelectedDataManager
 
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
                let createdDate = data["date"] as? String ?? " "
                let isStitched = data["isStitched"]
                let details = data["details"] as? String ?? ""
                let id = document.documentID
                // add scan data and get scan details
                let scan = Scan(id: id, name: name as! String,
                                isStitched: (isStitched != nil), details: details)
            
                
                fetchedScans.append(scan)
                
            }
            self.scanList = fetchedScans
//            print(self.scanList)
        }
    }
    
    func addScanName(patientID: String, scanName: String, scanID: String ) {
        let db = Firestore.firestore()
        let newPatientRef = db.collection("patients").document(UUID().uuidString)
        let newScanRef = db.collection("patients").document(patientID).collection("scans").document(scanID)
        
        newScanRef.setData([
            "name": scanName
        ]){ error in
            if let error = error {
                print("Error adding scan: \(error.localizedDescription)")
            } else {
                print("Scan added successfully")
            }
        }
    }
    func addScan(patientID: String, scanID: String, scanName: String, scanDetails: String, scanDate: Date, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()

//        let patientID = selectedDataManager.getPatientID()
//
//       let scanID = selectedDataManager.getScanID()
        
        let newScanRef = db.collection("patients").document(patientID).collection("scans").document(scanID)

        let data: [String: Any] = [ // Use a dictionary of type [String: Any]
            "name": scanName,
            "isStitched": false,
            "date": scanDate, // Consider storing as Timestamp for better Firestore compatibility
            "details": scanDetails
        ]
       
        newScanRef.setData(data) { error in // Use the completion handler provided by setData
            if let error = error {
                completion(error)
            } else {
                DispatchQueue.main.async {
                    self.fetchScans()
                }
                completion(nil)
            }
        }
    }
}
