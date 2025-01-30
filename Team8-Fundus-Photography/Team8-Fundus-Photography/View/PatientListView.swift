//
//  PatientListView.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-01-09.
//

import SwiftUI

struct PatientListView: View {
    
    //Observed objects marked with the @StateObject property wrapper don’t get destroyed and re-instantiated at times their containing view struct redraws.
    @StateObject private var storageManager = FirebaseManager()
    @State private var patientList: [Patient] = []
    @State private var isShowingAddPatientSheet = false
    
    
    var body: some View {
        NavigationView {
            VStack {
                if !patientList.isEmpty{
                    List(patientList) {patient in
                        NavigationLink(destination: ScanListView(patientId: patient.name)) {
                            Card(name: patient.name, date: Date(), scanNumber: patient.scanCount)
                        }
                    }
                }else {
                    Text("No Patients found.")
                }
                
                Button {
                    isShowingAddPatientSheet = true
                } label: {
                    Text("Add New Patient")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
            }
            .onAppear{
                storageManager.fetchPatientList {
                    fetchedPatients in
                    patientList = fetchedPatients
                }
            }
            .sheet(isPresented: $isShowingAddPatientSheet) {
                BottomSheet(
                    title: "Add New Patient",
                                    placeholder: "Enter Patient Name"
                ) { newPatientName in
                    storageManager.addPatientToFirebase(name: newPatientName) { success in
                        if success {
                            // update the list
                            storageManager.fetchPatientList { fetchedPatients in
                                patientList = fetchedPatients
                            }
                        }
                    }
                }
                .presentationDetents([.fraction(0.50)])
            }
        }
    }
}


#Preview {
    PatientListView()
}
