import SwiftUI
import FirebaseCore


struct ContentView: View {
    

    var body: some View {
        ZStack {
            StartView()
        }
    }
}

#Preview {
    StartView().environmentObject(AuthService())
        .environmentObject(SelectedDataManager())
        .environmentObject(FirebaseManager())
    
}
