//
//  ScanModel.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-01-29.
//

import Foundation

struct Scan: Identifiable{
    let id: UUID
    let name: String
    var regions: ScanRegions
    
    init(id: UUID = UUID(), name: String, regions: ScanRegions) {
        self.id = id
        self.name = name
        self.regions = regions
    }
}


struct ScanRegions{
    var superior: [ImageData]
    var inferior: [ImageData]
    var central: [ImageData]
    var nasal: [ImageData]
    var temporal: [ImageData]
    
    init(
        superior: [ImageData] = []
        , inferior: [ImageData] = []
        , central: [ImageData] = []
        , nasal: [ImageData] = []
        , temporal: [ImageData] = []
    ){
        self.superior = superior
        self.inferior = inferior
        self.central = central
        self.nasal = nasal
        self.temporal = temporal
    }
}

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
