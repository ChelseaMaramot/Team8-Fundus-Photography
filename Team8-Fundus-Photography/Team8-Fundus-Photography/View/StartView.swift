//
//  StartView.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-02-12.
//

import SwiftUI
import FirebaseAuth

struct StartView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var selectedDataManager: SelectedDataManager
    @EnvironmentObject var firebaseManager: FirebaseManager
    
    var body: some View {
        if authService.signedIn {
            PatientListView()
        } else {
            registerView()
        }
    }
}

struct StartView_Previews: PreviewProvider {
    @StateObject static var authService = AuthService()
    @StateObject var selectedDataManager = SelectedDataManager()

    static var previews: some View {
        if authService.signedIn {
            PatientListView()
        } else {
            registerView()
        }
    }
}
