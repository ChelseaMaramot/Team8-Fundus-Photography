import SwiftUI

struct PatientListView: View {
    
    @StateObject private var viewModel = PatientListViewModel()
    @EnvironmentObject var selectedDataManager: SelectedDataManager
    @EnvironmentObject var authService: AuthService
    
    @State private var showConfirmationModal = false
    @State private var patientToDeleteID: String? = nil
    @State private var patientToDeleteName: String? = nil
    
    var body: some View {
        NavigationStack {
            VStack {
                
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
                        List {
                            ForEach(viewModel.patientList) { patient in
                                NavigationLink(destination: ScanListView(patientID: patient.id)) {
                                    let name = patient.firstName + " " + patient.lastName
                                    Card(name: name, scanNumber: patient.scanCount)
                                }
                            }
                            .onDelete(perform: deletePatient)
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
            .confirmationDialog("Are you sure you want to delete \(patientToDeleteName ?? "this patient")?", isPresented: $showConfirmationModal, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    if let patientID = patientToDeleteID {
                        viewModel.deletePatient(patientID: patientID)
                    }
                }
                Button("Cancel", role: .cancel) {
                    patientToDeleteID = nil
                    patientToDeleteName = nil
                }
            }
        }
    }
    
    private func deletePatient(at offsets: IndexSet) {
        for index in offsets {
            let patient = viewModel.patientList[index]
            patientToDeleteID = patient.id
            patientToDeleteName = patient.firstName + " " + patient.lastName
            showConfirmationModal = true
        }
    }
}

#Preview {
    PatientListView()
        .environmentObject(SelectedDataManager())
}
