import SwiftUI

struct PatientListView: View {
    
    @StateObject private var viewModel = PatientListViewModel()
    @EnvironmentObject var selectedDataManager: SelectedDataManager
    
    var body: some View {
        NavigationView {
            VStack {
                if !viewModel.patientList.isEmpty {
                    List(viewModel.patientList) { patient in
                        NavigationLink(destination: ScanListView(patientID: patient.id)) {
                            Card(name: patient.name, scanNumber: patient.scanCount)
                        }
                    }
                } else {
                    Text("No Patients found.")
                }
                
                Button {
                    viewModel.isShowingAddPatientSheet = true
                } label: {
                    Text("Add New Patient")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
            }
            .onAppear {
                viewModel.fetchPatients()
            }
            .sheet(isPresented: $viewModel.isShowingAddPatientSheet) {
                BottomSheet(
                    title: "Add New Patient",
                    placeholder: "Enter Patient Name"
                ) { newPatientName in
                    viewModel.addPatient(name: newPatientName)
                }
                .presentationDetents([.fraction(0.50)])
            }
        }
    }
}

#Preview {
    PatientListView()
        .environmentObject(SelectedDataManager())
}
