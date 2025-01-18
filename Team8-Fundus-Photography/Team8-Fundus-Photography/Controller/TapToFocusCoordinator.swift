//
//  TapToFocusCoordinator.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-01-17.
//

import UIKit

class TapToFocusCoordinator: NSObject {
    var parent: CameraPreview
    
    init(_ parent: CameraPreview) {
        self.parent = parent
    }
    
    @objc func handleTapGesture(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sender.view)
        parent.onTap(location)
    }
}
