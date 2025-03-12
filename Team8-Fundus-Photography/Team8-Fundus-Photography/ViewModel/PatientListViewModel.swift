//
//  PatientListViewModel.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-02-02.
//

import SwiftUI
import FirebaseFirestore
import Combine

class PatientListViewModel: ObservableObject {
    
  
    @Published var patientList: [Patient] = []
    @Published var isShowingAddPatientSheet = false
        
    private var storageManager = FirebaseManager()
    private var authService: AuthService
    
    init(authService: AuthService) {
        self.authService = authService
        
        NotificationCenter.default.addObserver(self, selector: #selector(fetchPatients), name: NSNotification.Name("UserLoggedIn"), object: nil)
    }
    
    @objc func fetchPatients() {
        
        print("fetching patients ...")
        var fetchedPatients: [Patient] = []
        let db = Firestore.firestore()
        let patientRef = db.collection("patients").whereField("userIDs", arrayContains: authService.userID ?? "")
        
        patientRef.getDocuments { querySnapshot, error in
            if let error = error {
                print("Error fetching patients: \(error.localizedDescription)")
                return
            }
            
            for document in querySnapshot?.documents ?? [] {
                let data = document.data()
                let patientID = document.documentID
                let firstName = data["firstName"] as? String ?? ""
                let lastName = data["lastName"] as? String ?? ""
                let scanCount = data["scanCount"] as? Int ?? 0
                
                let patient = Patient(id: patientID,
                                      firstName: firstName,
                                      lastName: lastName,
                                      scanCount: scanCount)
                fetchedPatients.append(patient)
            }
            
    
            self.patientList = fetchedPatients
            print(self.patientList)
            
        }
    }
    
    
    // im only adding first name for now cause bottom sheet only accepts name
    func addPatient(patient: Patient) {
        let db = Firestore.firestore()
        let newPatientRef = db.collection("patients").document(UUID().uuidString)
        
        
        newPatientRef.setData([
            "firstName": patient.firstName,
            "lastName": patient.lastName,
            "scanCount": patient.scanCount,
            "userIDs": [authService.userID]  // chnage this when we have the authentication stuff
        ]){ error in
            if let error = error {
                print("Error adding patient: \(error.localizedDescription)")
            } else {
                print("Patient added successfully")
                self.fetchPatients()
            }
        }
    }
    
    
    func deletePatient(patientID: String){
        let db = Firestore.firestore()
        let patientRef = db.collection("patients").document(patientID)
        
        patientRef.delete { error in
            if let error = error {
                print("Error deleting patient: \(error.localizedDescription)")
            } else {
                print("Patient deleted successfully")
                self.patientList.removeAll { $0.id == patientID }
            }
        }
    }
}
