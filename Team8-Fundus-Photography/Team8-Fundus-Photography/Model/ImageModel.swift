//
//  ImageModel.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-01-29.
//

import Foundation


struct ImageData: Identifiable{
    let id: UUID
    let url: URL
    let description: String?
    
    init(id: UUID = UUID(), url: URL, description: String? = nil) {
        self.id = id
        self.url = url
        self.description = description
    }
    
}
