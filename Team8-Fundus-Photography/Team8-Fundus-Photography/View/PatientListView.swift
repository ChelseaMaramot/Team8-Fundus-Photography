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
                logoutButton
                
                patientListView
                
                if !isEditing {
                    addPatientButton
                }
            }
            .onAppear {
                viewModel.fetchPatients()
            }
            .sheet(isPresented: $viewModel.isShowingAddPatientSheet, content: addPatientSheet)
            .toolbar { toolbarContent() }
            .confirmationDialog(
                "Are you sure you want to delete these patients?",
                isPresented: $showConfirmationModal,
                titleVisibility: .visible
            ) {
                deleteConfirmationDialog
            }
        }
    }
}

// MARK: - UI Components
extension PatientListView {
    private var logoutButton: some View {
        Button("Log out") {
            authService.regularSignOut { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private var patientListView: some View {
        VStack {
            if viewModel.patientList.isEmpty {
                Text("No Patients found.")
            } else {
                List {
                    ForEach(viewModel.patientList) { patient in
                        patientRow(for: patient)
                    }
                    .onDelete(perform: swipeToDelete)
                }
            }
        }
    }
    
    private func patientRow(for patient: Patient) -> some View {
        HStack {
            if isEditing {
                selectionIndicator(for: patient)
            }
            
            NavigationLink(destination: ScanListView(patientID: patient.id)) {
                Card(name: "\(patient.firstName) \(patient.lastName)", scanNumber: patient.scanCount)
            }
        }
    }
    
    private func selectionIndicator(for patient: Patient) -> some View {
        Image(systemName: patientIDsToDelete.contains(patient.id) ? "checkmark.circle.fill" : "circle")
            .onTapGesture { toggleSelection(for: patient) }
    }
    
    private var addPatientButton: some View {
        Button(action: { viewModel.isShowingAddPatientSheet = true }) {
            Text("Add New Patient")
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }
    
    private func addPatientSheet() -> some View {
        BottomSheet(
            title: "Add New Patient",
            placeholder: "Enter Patient Name"
        ) { newPatientName in
            let newPatient = Patient(
                id: UUID().uuidString,
                firstName: newPatientName,
                lastName: "",
                scanCount: 0
            )
            viewModel.addPatient(patient: newPatient)
        }
        .presentationDetents([.fraction(0.50)])
    }
}

// MARK: - Toolbar
extension PatientListView {
    private func toolbarContent() -> some ToolbarContent {
        Group {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                editButton
            }

            if isEditing && !patientIDsToDelete.isEmpty {
                ToolbarItem(placement: .bottomBar) {
                    deleteButton
                }
            }
        }
    }


    private var editButton: some View {
        Button(isEditing ? "Done" : "Edit") {
            isEditing.toggle()
            if !isEditing {
                patientIDsToDelete.removeAll()
            }
        }
    }

    private var deleteButton: some View {
        Button("Delete", role: .destructive) {
            showConfirmationModal = true
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }
}

// MARK: - Delete Confirmation
extension PatientListView {
    private var deleteConfirmationDialog: some View {
        Group {
            Button("Delete", role: .destructive) {
                for patientID in patientIDsToDelete {
                    viewModel.deletePatient(patientID: patientID)
                }
                patientIDsToDelete.removeAll()
                isEditing = false
            }
            Button("Cancel", role: .cancel) {
                   patientIDsToDelete.removeAll()
               }
        }
    }
}

// MARK: - Helper Methods
extension PatientListView {
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
            patientIDsToDelete.append(patient.id)
            showConfirmationModal = true
        }

    }
}

#Preview {
    PatientListView()
        .environmentObject(SelectedDataManager())
}
