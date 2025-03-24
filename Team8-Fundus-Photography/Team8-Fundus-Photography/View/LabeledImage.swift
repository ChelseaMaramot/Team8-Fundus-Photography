//
//  LabeledImage.swift
//  Team8-Fundus-Photography
//
//  Created by Anjola Adewale on 2025-02-01.
//

import SwiftUI

struct LabeledImage: Identifiable {
    let id: String
    let image: UIImage?
    var isPrimary: Bool
    let position: String
    var comment: String? // ✅ new field

    init(id: String, isPrimary: Bool, position: String, image: UIImage? = nil, comment: String? = nil) {
        self.id = id
        self.isPrimary = isPrimary
        self.position = position
        self.image = image
        self.comment = comment
    }
}
