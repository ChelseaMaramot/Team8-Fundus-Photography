//
//  SelectedDataManager.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-01-30.
//


import Foundation
import Combine

class SelectedDataManager: ObservableObject {
    
    @Published private var selectedPatientID: String = ""
    @Published private var selectedScanID: String = ""
    
    private var storageManager: FirebaseManager
    
    init(storageManager: FirebaseManager = FirebaseManager()){
        self.storageManager = storageManager
    }
    
    func setPatientID(_ ID: String) {
        self.selectedPatientID = ID
    }
    
    func setScanID(_ ID: String) {
        self.selectedScanID = ID
    }
    
    func getPatientID() -> String{
        return self.selectedPatientID
    }
    
    func getScanID() -> String{
        return self.selectedScanID
    }
        
    
}




