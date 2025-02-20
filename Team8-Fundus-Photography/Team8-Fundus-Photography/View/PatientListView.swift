import SwiftUI

struct PatientListView: View {
    
    @StateObject private var viewModel = PatientListViewModel()
    @EnvironmentObject var selectedDataManager: SelectedDataManager
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        NavigationStack {
            VStack{
                
                Button("Log out") {
                    print("Log out tapped!")
                    authService.regularSignOut { error in
                        if let e = error {
                            print(e.localizedDescription)
                        }
                    }
                }
                
                VStack {
                    if !viewModel.patientList.isEmpty {
                        List(viewModel.patientList) { patient in
                            NavigationLink(destination: ScanListView(patientID: patient.id)) {
                                let name = patient.firstName + " " + patient.lastName
                                Card(name: name, scanNumber: patient.scanCount)
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
                        let newPatient = Patient(
                            id: UUID().uuidString,
                            firstName: newPatientName,
                            lastName: "",
                            scanCount: 0)
                        
                        viewModel.addPatient(patient: newPatient)
                    }
                    .presentationDetents([.fraction(0.50)])
                }
            }
        }
    }
}

#Preview {
    PatientListView()
        .environmentObject(SelectedDataManager())
}
