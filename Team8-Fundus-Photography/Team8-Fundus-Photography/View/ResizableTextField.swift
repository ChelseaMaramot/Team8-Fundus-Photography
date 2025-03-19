//
//  ResizableTextField.swift
//  Team8-Fundus-Photography
//
//  Created by Anjola Adewale on 2025-03-18.
//

import SwiftUI

struct ResizableTextField: View {
    @Binding var text: String
    let characterLimit = 100

    var body: some View {
        TextEditor(text: $text)
            .frame(height: 50)  // Approx 2 lines height
            .padding(8)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
            .onChange(of: text) { newText in
                enforceCharacterLimit(newText)
            }
            .onReceive(text.publisher.collect()) { _ in
                // Prevent line breaks by removing newlines
                text = text.replacingOccurrences(of: "\n", with: " ")
            }
    }

    private func enforceCharacterLimit(_ newText: String) {
        if newText.count > characterLimit {
            text = String(newText.prefix(characterLimit))
        }
    }
}
