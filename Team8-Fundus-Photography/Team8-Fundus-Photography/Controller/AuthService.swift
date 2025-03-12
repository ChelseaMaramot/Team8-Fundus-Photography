//
//  AuthService.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-02-12.
//

import SwiftUI
import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore


class AuthService: ObservableObject {
    
    @Published var signedIn:Bool = false
    @Published var userID: String?
    private let db = Firestore.firestore()
    
    init() {
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user != nil {
                self.signedIn = true
                self.userID = user?.uid
                print("Auth state changed, is signed in: \(self.userID ?? "no user")")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                 NotificationCenter.default.post(name: NSNotification.Name("UserLoggedIn"), object: nil)
                             }

            } else {
                self.signedIn = false
                self.userID = nil
                print("Auth state changed, is signed out")
            }
        }
    }
    
    // MARK: - Password Account
    func regularCreateAccount(email: String, password: String, firstName: String, lastName: String, completion: @escaping (Error?) -> Void) {
        
        print("signing in...")
         Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
             if let error = error {
                 print("Error creating user: \(error.localizedDescription)")
                 completion(error)
                 return
             }
             
             guard let user = authResult?.user else { return }
             
             let userData: [String: Any] = [
                 "uid": user.uid,
                 "firstName": firstName,
                 "lastName": lastName,
                 "email": email
             ]
             
             self.db.collection("users").document(user.uid).setData(userData) { error in
                 if let error = error {
                     print("Error saving user data: \(error.localizedDescription)")
                     completion(error)
                 } else {
                     print("Successfully created user and stored in Firestore")
                     completion(nil)
                 }
             }
         }
     }
    //MARK: - Traditional sign in
    // Traditional sign in with password and email
    func regularSignIn(email:String, password:String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) {  authResult, error in
            if let e = error {
                completion(e)
            } else {
                print("Login success")
                completion(nil)
            }
        }
    }
    
    // Regular password acount sign out.
    // Closure has whether sign out was successful or not
    func regularSignOut(completion: @escaping (Error?) -> Void) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            completion(nil)
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
          completion(signOutError)
        }
    }
    
}
