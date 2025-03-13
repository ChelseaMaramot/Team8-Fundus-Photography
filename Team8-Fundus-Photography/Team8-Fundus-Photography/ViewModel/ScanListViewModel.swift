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
    @Published var searchQuery: String = ""
    
    @EnvironmentObject var selectedDataManager: SelectedDataManager
 
    private var patientID: String
    private var storageManager = FirebaseManager()
    
    init(patientID: String) {
        self.patientID = patientID
        fetchScans()
    }
    func fetchScanDetails(scanID: String, completion: @escaping (String, String, Date?) -> Void) {
        let db = Firestore.firestore()
        let patientID = self.patientID // Ensure correct patient ID is used

        let scanRef = db.collection("patients").document(patientID).collection("scans").document(scanID)

        scanRef.getDocument { document, error in
            if let error = error {
                print("Error fetching scan details: \(error.localizedDescription)")
                completion("", "", nil)
            } else if let document = document, document.exists {
                let scanName = document.get("name") as? String ?? "Unknown"
                let scanDetails = document.get("details") as? String ?? "No details available."
                let scanDate = (document.get("date") as? Timestamp)?.dateValue()

                completion(scanName, scanDetails, scanDate)
            } else {
                print("Scan document does not exist")
                completion("", "", nil)
            }
        }
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
                self.updateScanCount(patientID: patientID){ error in
                    if let error = error {
                        completion(error)
                    }  else{
                        DispatchQueue.main.async {
                            self.fetchScans()
                        }
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func deleteScan(scanID: String) {
        let db = Firestore.firestore()
        let scanRef = db.collection("patients").document(patientID).collection("scans").document(scanID)
        
        scanRef.delete { error in
            if let error = error {
                print("Error deleting scan: \(error.localizedDescription)")
            } else {
                print("Scan deleted successfully")
                self.scanList.removeAll { scan in
                    scan.id == scanID
                }
            }
        }
    }
    
    func updateScan(patientID: String, scanID: String, scanName: String, scanDetails: String, scanDate: Date, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        
        
        let newScanRef = db.collection("patients").document(patientID).collection("scans").document(scanID)

        let data: [String: Any] = [
            "name": scanName,
            "isStitched": false,
            "date": scanDate,
            "details": scanDetails
        ]
       
        newScanRef.updateData(data) { error in
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
    
    func updateScanCount(patientID: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let patientRef = db.collection("patients").document(patientID)
        
        print("updating scan count")

        patientRef.collection("scans").getDocuments { snapshot, error in
            if let error = error {
                completion(error)
            } else {
                let scanCount = snapshot?.documents.count ?? 0
                patientRef.updateData(["scanCount": scanCount]) { error in
                    if let error = error {
                        completion(error)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }

    
    func searchScans(query: String) {
            self.searchQuery = query
            
            if query.isEmpty {
                self.fetchScans()
            } else {
                self.scanList = self.scanList.filter { scan in
                    scan.name.lowercased().contains(query.lowercased())
                }
            }
        }
    
}
