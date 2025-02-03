import SwiftUI

struct ContentView: View {
    
    @StateObject var selectedDataManager = SelectedDataManager()

    var body: some View {
        ZStack {
            PatientListView()
                .environmentObject(selectedDataManager)
        }
    }
}

#Preview {
    ContentView().environmentObject(SelectedDataManager())
}
