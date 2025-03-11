//
//  SelectedDataManager.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-01-30.
//


import Foundation
import Combine
import SwiftUI

class SelectedDataManager: ObservableObject {
    
    @Published private var selectedPatientID: String = ""
    @Published private var selectedScanID: String = ""
    @Published private var selectedScanName: String = ""
    @Published private var selectedQuadrant: RegionTypes = .central
    @Published private var previousSelectedQuadrant: RegionTypes = .central
    
    private var storageManager: FirebaseManager
    
    
    init(storageManager: FirebaseManager = FirebaseManager()){
        self.storageManager = storageManager
    }
    
    func setPatientID(_ ID: String) {
        self.selectedPatientID = ID
    }
    
    func setScanName(_ Name: String) {
        self.selectedScanName = Name
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
    
    func getScanName() -> String{
        return self.selectedScanName
    }
    
    func setQuadrant(_ quadrant: RegionTypes) {
        self.previousSelectedQuadrant = selectedQuadrant
        self.selectedQuadrant = quadrant
        
        print("changing quadrants in env to: ", self.selectedQuadrant)
    }
   
    func getQuadrant() -> RegionTypes {
       return self.selectedQuadrant
   }
    
    func getPreviousQuadrant() -> RegionTypes {
        return self.previousSelectedQuadrant
   }
    
}




