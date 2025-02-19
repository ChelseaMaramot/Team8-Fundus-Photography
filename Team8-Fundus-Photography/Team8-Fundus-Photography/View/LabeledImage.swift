//
//  LabeledImage.swift
//  Team8-Fundus-Photography
//
//  Created by Anjola Adewale on 2025-02-01.
//

import SwiftUI

struct LabeledImage: Identifiable {
    let id: String  // Ensures each image is uniquely identifiable
//    let url = String()
    let image: UIImage?
    var isPrimary: Bool // should i add postion here too?
    let position: String
    
    
    init(id: String, isPrimary: Bool, position: String, image: UIImage? = nil) {
        self.id = id
        self.isPrimary = isPrimary
        self.position = position
        self.image = image
    }

}
