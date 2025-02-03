//
//  PatientModel.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-01-29.
//

import Foundation

struct Patient: Identifiable{
    let id: String
    let firstName: String
    let lastName: String
    let scanCount: Int
    
    init(id: String, firstName: String, lastName: String, scanCount: Int) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.scanCount = scanCount
    }
}
