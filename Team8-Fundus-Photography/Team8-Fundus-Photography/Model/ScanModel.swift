//
//  ScanModel.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-01-29.
//

import Foundation

struct Scan: Identifiable{
    let id: String
    let name: String
    let isStitched: Bool
//    let date: Date
    let details: String
//    var regions: ScanRegions

    
    init(id: String, createdDate: Date = Date(),  name: String, isStitched: Bool, details: String) {
        self.id = id
        self.name = name
//        self.date = createdDate
        self.details = details
        self.isStitched = isStitched
    }
}


enum RegionTypes: String, CaseIterable {
    case superior = "Superior"
    case inferior = "Inferior"
    case nasal = "Nasal"
    case temporal = "Temporal"
    case central = "Central"
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

