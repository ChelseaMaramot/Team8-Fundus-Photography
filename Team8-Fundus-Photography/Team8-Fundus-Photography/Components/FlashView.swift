//
//  FlashView.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2024-11-14.
//

import SwiftUI

struct FlashView: View {
    @Binding var isFlashing: Bool

    var body: some View {
        Color.black
            .opacity(isFlashing ?  1 : 0)
            .animation(.easeOut(duration: 0.4), value: isFlashing)
            .edgesIgnoringSafeArea(.all)
            .onAppear() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isFlashing = false
                }
            }
    }
}

//#Preview {
//    FlashView(isFlashing: .constant(true))
//}
