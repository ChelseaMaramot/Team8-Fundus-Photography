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

    static var previews: some View {
        if authService.signedIn {
            PatientListView()
        } else {
            registerView()
        }
    }
}
