//
//  LabeledImage.swift
//  Team8-Fundus-Photography
//
//  Created by Anjola Adewale on 2025-02-01.
//

import SwiftUI

struct LabeledImage: Identifiable {
    let id = UUID()  // Ensures each image is uniquely identifiable
    let url = String()
    let image: UIImage
    var isPrimary: Bool // should i add postion here too?
}
