//
//  PatientListViewModel.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-02-02.
//

import SwiftUI
import Combine

class PatientListViewModel: ObservableObject {
    
    @Published var patientList: [Patient] = []
    @Published var isShowingAddPatientSheet = false
    
    private var storageManager = FirebaseManager()
    
    func fetchPatients() {
        storageManager.fetchPatientList { [weak self] fetchedPatients in
            self?.patientList = fetchedPatients
        }
    }
    
    func addPatient(name: String) {
        storageManager.addPatientToFirebase(name: name) { [weak self] success in
            if success {
                self?.fetchPatients()
            }
        }
    }
}
