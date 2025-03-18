//
//  ResizableTextField.swift
//  Team8-Fundus-Photography
//
//  Created by Anjola Adewale on 2025-03-18.
//

import SwiftUI

struct ResizableTextField: View {
    @Binding var text: String
    @State private var dynamicHeight: CGFloat = 50

    var body: some View {
        TextEditor(text: $text)
            .frame(minHeight: dynamicHeight, maxHeight: 150)
            .padding(8)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
            .onChange(of: text) { _ in
                updateHeight()
            }
    }

    private func updateHeight() {
        let size = CGSize(width: UIScreen.main.bounds.width - 40, height: .infinity)
        let estimatedSize = text.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [.font: UIFont.systemFont(ofSize: 16)], context: nil)
        self.dynamicHeight = min(max(50, estimatedSize.height + 20), 150)
    }
}
