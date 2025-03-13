import SwiftUI

struct PatientListView: View {
    
    @StateObject var viewModel: PatientListViewModel
    @EnvironmentObject var selectedDataManager: SelectedDataManager
    @EnvironmentObject var authService: AuthService
    
    @State private var showConfirmationModal = false
    @State private var patientIDsToDelete: [String] = []
    @State private var isEditing = false
    @State private var searchQuery = ""
    @State private var sortAscending = true
    
    var colors = cardColors()
    
    init() {
        _viewModel = StateObject(wrappedValue: PatientListViewModel(authService: AuthService()))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerView
        
                        
                patientListView
                
                
                if !isEditing {
                    addPatientButton
                }
            }
            .onAppear {
                viewModel.fetchPatients()
            }
            .sheet(isPresented: $viewModel.isShowingAddPatientSheet, content: addPatientSheet)
//            .toolbar { toolbarContent() }
            .confirmationDialog(
                "Are you sure you want to delete these patients?",
                isPresented: $showConfirmationModal,
                titleVisibility: .visible
            ) {
                deleteConfirmationDialog
            }
            .padding(.top, 0)
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
    }
}



// MARK: - UI Components
extension PatientListView {
    private var logoutButton: some View {
        Button(action: {
            authService.regularSignOut { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }) {
            HStack {
                Image(systemName: "power")
                    .foregroundColor(.white)
                Text("Log out")
                    .foregroundColor(.white)
                    .fontWeight(.regular)
            }
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
        }
    }
    
    private var headerView: some View {
        VStack{
            HStack {
                Spacer()
                logoutButton
            }
            VStack{
                searchField
            }
            
            HStack{
                filters
                Spacer()
                editButton
            }
        }
        .padding(.top, 0)
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .background(Color.blue)
    }
        

    private var patientListView: some View {
        VStack {
            if viewModel.isLoading {
                loadingIndicator
            } else {
                if !viewModel.patientList.isEmpty {
                    List {
                        ForEach(sortedPatients) { patient in
                            patientRow(for: patient)
                        }
                        .onDelete(perform: swipeToDelete)
                    }
                    .frame(maxWidth: .infinity)
                    .listStyle(PlainListStyle())
                } else {
                    Spacer()
                    Text("No Person found.")
                    Spacer()
                }
            }
        }
        .padding(.top)
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

// MARK: - Search and Sort View
extension PatientListView {


    private var searchField: some View {
        VStack {
            Text("SmartScope")
                .fontWeight(.bold)
                .foregroundColor(.white)
                .font(.system(size: 24))
            
            TextField("Search Patients", text: $searchQuery)
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(13)
                .padding(.horizontal)
                .onChange(of: searchQuery) { _ in
                    viewModel.searchPatients(query: searchQuery)
                }
        }
        .padding(15)
        .background(Color.blue)
    }
    
    
    private var filters: some View {
        HStack{
            Text("Sort By")
                .fontWeight(.semibold)
                .font(.system(size: 12))
                .foregroundColor(.white)
            
            Button(action: {
                sortAscending.toggle()
            }) {
                Text(sortAscending ? "A->Z" : "Z->A")
                    .fontWeight(.medium)
                    .font(.system(size: 12))
                    .padding(5)
                    .background(colors.cardBackground)
                    .foregroundColor(colors.cardMainText)
                    .cornerRadius(13)
            }
        }
        .padding(.leading, 30)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    

    private var sortedPatients: [Patient] {
        return sortAscending ?
        viewModel.patientList.sorted { $0.firstName < $1.firstName } :
        viewModel.patientList.sorted { $0.firstName > $1.firstName }
    }
}

// MARK: - Toolbar
extension PatientListView {
//    private func toolbarContent() -> some ToolbarContent {
//        Group {
//            ToolbarItemGroup(placement: .navigationBarTrailing) {
//                editButton
//            }
//
//            if isEditing && !patientIDsToDelete.isEmpty {
//                ToolbarItem(placement: .bottomBar) {
//                    deleteButton
//                }
//            }
//        }
//    }

    private var editButton: some View {
        Button(isEditing ? "Done" : "Edit") {
            isEditing.toggle()
            if !isEditing {
                patientIDsToDelete.removeAll()
            }
        }
        .foregroundColor(.white)
        .padding()
        .background(Color.blue)
        .cornerRadius(10)
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

// MARK: - Loading Indicator
extension PatientListView {
    private var loadingIndicator: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: Color.blue)) // Blue color for the loading spinner
            .scaleEffect(1.5) // Adjusted size for better fit
            .padding(40)
            .background(Color.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 15)) // Semi-transparent background with rounded corners
            .shadow(radius: 10) // Adds a subtle shadow for depth
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Centers the loading indicator
    }
}
    


#Preview {
    PatientListView()
        .environmentObject(SelectedDataManager())
}
