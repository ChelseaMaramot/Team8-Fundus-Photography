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

    @State private var showConsent = true

    var body: some View {
        Group {
            if authService.signedIn {
                PatientListView()
            } else {
                registerView()
                    .sheet(isPresented: $showConsent) {
                        ConsentSheet {
                            showConsent = false
                        }
                    }
            }
        }
    }
}

struct ConsentSheet: View {
    var onAgree: () -> Void
    @State private var showExitAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Doctor Consent Agreement")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("By using this app, you agree to:")
                        .font(.headline)
                        .padding(.bottom, 5)

                    Group {
                        ConsentBullet(text: "Only use this app as a licensed medical professional.")
                        ConsentBullet(text: "Obtain informed consent from your patients before image capture.")
                        ConsentBullet(text: "Inform your patients of any risks associated with using the app or storing their medical images.")
                        ConsentBullet(text: "Comply with all applicable health information privacy laws and ethical standards.")
                    }
                }
                .padding(.horizontal)
            }

            Spacer()

            VStack(spacing: 12) {
                Button(action: onAgree) {
                    Text("I Agree")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button("I Do Not Agree") {
                    showExitAlert = true
                }
                .foregroundColor(.red)
                .alert("Consent Required", isPresented: $showExitAlert) {
                    Button("Exit App", role: .destructive) {
                        exit(0)
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("You must agree to the terms in order to use the app.")
                }
            }
        }
        .padding()
    }
}

struct ConsentBullet: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.system(size: 20))
                .padding(.top, 2)
            Text(text)
                .font(.body)
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
