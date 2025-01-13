//
//  ScanListView.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-01-09.
//

import SwiftUI

struct Scan: Hashable {
    var name: String
    var isStitched: Bool
    var createdDate: Date
}


let scans: [Scan] = [
    Scan(name: "Retina Scan 001", isStitched: true, createdDate: Date()),
    Scan(name: "Fundus Image 2025", isStitched: false, createdDate: Date()),
    Scan(name: "Optic Nerve Capture", isStitched: true, createdDate: Date()),
    Scan(name: "Macula Study 1", isStitched: false, createdDate: Date()),
    Scan(name: "Choroid Scan", isStitched: true, createdDate: Date()),
    Scan(name: "Peripheral View A", isStitched: false, createdDate: Date()),
    Scan(name: "Anterior Segment Image", isStitched: true, createdDate: Date()),
    Scan(name: "High-Res Retina 07", isStitched: false, createdDate: Date()),
    Scan(name: "OCT Scan B5", isStitched: true, createdDate: Date()),
    Scan(name: "Wide-Field Capture", isStitched: false, createdDate: Date())
]


struct ScanListView: View {
    var body: some View {
        VStack{
            List(scans, id: \.self) { scan in
                NavigationLink(destination: ImageView()) {
                    Card(name: scan.name, date: scan.createdDate, isStitched: scan.isStitched)
                }
                
            }
            Button {
            } label: {
                Text("Add New Scan")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
}

#Preview {
    ScanListView()
}
