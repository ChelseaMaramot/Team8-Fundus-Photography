//
//  SelectedDataManager.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-01-30.
//


import Foundation
import Combine

class SelectedDataManager: ObservableObject {
    
    @Published var selectedPatientID: UUID?
    @Published var selectedScanID: UUID?
    
    private var storageManager: FirebaseManager
    
    init(storageManager: FirebaseManager = FirebaseManager()){
        self.storageManager = storageManager
    }
    
    func selectPatientID(_ ID: UUID) {
        self.selectedPatientID = ID
        self.selectedScanID = nil
    }
    
    func selectScanID(_ ID: UUID) {
        self.selectedScanID = ID
    }
        
    
}




