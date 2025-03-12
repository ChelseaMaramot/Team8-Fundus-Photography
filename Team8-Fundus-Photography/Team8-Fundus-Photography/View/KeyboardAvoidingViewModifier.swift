//
//  KeyboardAvoidingViewModifier.swift
//  Team8-Fundus-Photography
//
//  Created by Anjola Adewale on 2025-03-10.
//

import SwiftUI
import Combine

struct KeyboardAvoidingViewModifier: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight) // Adjust padding when keyboard appears
            .onReceive(Publishers.keyboardHeight) { height in
                withAnimation {
                    self.keyboardHeight = height
                }
            }
    }
}

extension View {
    func keyboardAvoidingView() -> some View {
        self.modifier(KeyboardAvoidingViewModifier())
    }
}

// Helper extension to detect keyboard changes
extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { $0.keyboardHeight }
        
        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }

        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}
