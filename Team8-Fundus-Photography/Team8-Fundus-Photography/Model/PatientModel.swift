//
//  PatientModel.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-01-29.
//

import Foundation

struct Patient: Identifiable{
    let id: UUID
    let name: String
    let scans: [Scan]
    
    init(id: UUID=UUID(), name: String, scans:[Scan]=[]){
        self.id = id
        self.scans = scans
        self.name = name
    }
}
