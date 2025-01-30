//
//  UserModel.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-01-29.
//

import Foundation

class User: ObservableObject{
    let id: UUID
    let name: String
    @Published var patients: [Patient]
    
    init(id: UUID=UUID(), name:String, patients: [Patient] = []) {
        self.id = id
        self.name = name
        self.patients = patients
    }
}
