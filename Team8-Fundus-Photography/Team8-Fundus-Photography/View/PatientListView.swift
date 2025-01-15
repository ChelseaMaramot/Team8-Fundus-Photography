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
    
    
    var body: some View {
        NavigationView {
            VStack {
                List(storageManager.patients, id: \.self) {patient in
                    NavigationLink(destination: ScanListView()) {
                        Card(name: patient.name, date: Date(), scanNumber: 3)}
                }.onAppear(perform: storageManager.fetchPatientList)
    
                Button {
                } label: {
                    Text("Add New Patient")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
            }
        }
    }
}


#Preview {
    PatientListView()
}
