import SwiftUI

struct ContentView: View {
    
    var body: some View {
        ZStack {
            CameraView()
            QuadrantView()
        }
    }
}

#Preview {
    ContentView()
}
