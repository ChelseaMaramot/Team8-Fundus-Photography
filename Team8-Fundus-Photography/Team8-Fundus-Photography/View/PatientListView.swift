//
//  PatientListView.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-01-09.
//

import SwiftUI


// to change to firebase later
struct Patient: Hashable {
    var name: String
    var date: Date
    var scanNumber: Int?
}

struct PatientListView: View {
    
    
    // Sample fake data
    let patients: [Patient] = [
        Patient(name: "John Doe", date: Date(), scanNumber: 3),
        Patient(name: "Jane Smith", date: Date(), scanNumber: 5),
        Patient(name: "Alex Brown", date: Date(), scanNumber: 2),
        Patient(name: "John Doe", date: Date(), scanNumber: 3),
        Patient(name: "Jane Smith", date: Date(), scanNumber: 5),
        Patient(name: "Alex Brown", date: Date(), scanNumber: 2),
        Patient(name: "John Doe", date: Date(), scanNumber: 3),
        Patient(name: "Jane Smith", date: Date(), scanNumber: 5),
        Patient(name: "Alex Brown", date: Date(), scanNumber: 2)
    ]
    
    var body: some View {
        GeometryReader {geometry in
            ScrollView{
                VStack {
                    ForEach(patients, id: \.self) {patient in
                        Card(name: patient.name, date: patient.date, scanNumber: patient.scanNumber)
                            .frame(maxWidth: geometry.size.width * 0.88, alignment: .center)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}

#Preview {
    PatientListView()
}
