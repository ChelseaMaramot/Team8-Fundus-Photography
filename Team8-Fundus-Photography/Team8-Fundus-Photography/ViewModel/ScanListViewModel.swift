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
    
    func updateScan(patientID: String, scanID: String, scanName: String, scanDetails: String, scanDate: Date, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        
        let newScanRef = db.collection("patients").document(patientID).collection("scans").document(scanID)

        let data: [String: Any] = [ // Use a dictionary of type [String: Any]
            "name": scanName,
            "isStitched": false,
            "date": scanDate, // Consider storing as Timestamp for better Firestore compatibility
            "details": scanDetails
        ]
       
        newScanRef.updateData(data) { error in // Use the completion handler provided by setData
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
    

    func getScanName(scanID: String, completion: @escaping (String, Date?) -> Void) {
        let db = Firestore.firestore()
        
        // Assume that the patientID and scanID are used to navigate to the scan document
        let patientID = selectedDataManager.getPatientID() // Replace with actual patient ID
        let scanRef = db.collection("patients").document(patientID).collection("scans").document(scanID)
        
        scanRef.getDocument { document, error in
            if let error = error {
                print("Error fetching scan: \(error.localizedDescription)")
                completion("", nil)
            } else if let document = document, document.exists {
                // Extract scanName and scanDate from Firestore document
                let scanName = document.get("name") as? String ?? "Unknown"
                let scanDate = document.get("date") as? Timestamp
                let date = scanDate?.dateValue()
            
                // Return the values through the completion handler
                completion(scanName, date)
            } else {
                print("Document does not exist")
                completion("", nil)
            }
        }
    }

}
