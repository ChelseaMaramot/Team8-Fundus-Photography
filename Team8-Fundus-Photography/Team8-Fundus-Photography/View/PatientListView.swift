import SwiftUI

struct PatientListView: View {
    @StateObject private var viewModel = PatientListViewModel()
    @EnvironmentObject var selectedDataManager: SelectedDataManager
    @EnvironmentObject var authService: AuthService
    
    @State private var showConfirmationModal = false
    @State private var patientIDsToDelete: [String] = []
    @State private var isEditing = false
    
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
                                let name = patient.firstName + " " + patient.lastName
                                HStack {
                                    if isEditing {
                                        Image(systemName: patientIDsToDelete.contains(patient.id) ? "checkmark.circle.fill" : "circle")
                                            .onTapGesture {
                                                toggleSelection(for: patient)
                                            }
                                    }
                                    NavigationLink(destination: ScanListView(patientID: patient.id)) {
                                        Card(name: name, scanNumber: patient.scanCount)
                                    }
                                }
                            }
                            .onDelete(perform: swipeToDelete)
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Done" : "Edit") {
                        isEditing.toggle()
                        if !isEditing {
                            patientIDsToDelete.removeAll()
                        }
                    }
                }
                
                if isEditing && !patientIDsToDelete.isEmpty {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Delete", role: .destructive) {
                            showConfirmationModal = true
                        }
                    }
                }
            }
            .confirmationDialog("Are you sure you want to delete these patients?", isPresented: $showConfirmationModal, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    for patientID in patientIDsToDelete {
                        viewModel.deletePatient(patientID: patientID)
                    }
                    patientIDsToDelete.removeAll()
                    isEditing = false
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
    
    private func toggleSelection(for patient: Patient) {
        if let index = patientIDsToDelete.firstIndex(of: patient.id) {
            patientIDsToDelete.remove(at: index)
        } else {
            patientIDsToDelete.append(patient.id)
        }
    }
    
    private func swipeToDelete(at offsets: IndexSet) {
        for index in offsets {
            let patient = viewModel.patientList[index]
            viewModel.deletePatient(patientID: patient.id)
        }
    }
}

#Preview {
    PatientListView()
        .environmentObject(SelectedDataManager())
}
