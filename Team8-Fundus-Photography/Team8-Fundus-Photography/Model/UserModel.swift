//
//  UserModel.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-01-29.
//

import Foundation

class User: ObservableObject{
    let id: UUID
    let firstName: String
    let lastName: String
    let email: String
    @Published var patients: [Patient]
    
    init(id: UUID=UUID(), firstName:String, lastName: String, email
         :String, patients: [Patient] = []) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.patients = patients
    }
}
