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
    let isStitched: Bool
    var regions: ScanRegions

    
    init(id: UUID = UUID(),createdDate: Date = Date(),  name: String, regions: ScanRegions, isStitched: Bool) {
        self.id = id
        self.name = name
        self.regions = regions
        self.isStitched = isStitched
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

