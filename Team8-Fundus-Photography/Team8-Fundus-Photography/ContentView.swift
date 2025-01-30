import SwiftUI

struct ContentView: View {
    
    var body: some View {
        
        @StateObject var selectedDataManager = SelectedDataManager()

        
        
        ZStack {
            PatientListView()
                .environmentObject(selectedDataManager)
        }
    }
}

#Preview {
    ContentView()
}
