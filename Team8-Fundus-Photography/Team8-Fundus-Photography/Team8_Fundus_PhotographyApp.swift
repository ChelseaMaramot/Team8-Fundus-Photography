//
//  Team8_Fundus_PhotographyApp.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2024-11-03.
//

import SwiftUI
import FirebaseCore

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()

        if let firebaseApp = FirebaseApp.app() {
            print("Firebase configured successfully: \(firebaseApp.name)")
        } else {
            print("Failed to configure Firebase.")
        }
        
        return true
    }
}

@main
struct Team8_Fundus_PhotographyApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
            //CameraView()
        }
    }
}
