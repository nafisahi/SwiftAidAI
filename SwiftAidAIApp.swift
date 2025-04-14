//
//  SwiftAidAIApp.swift
//  SwiftAidAI
//
//  Created by Nafisah Islam on 12/03/2025.
//

import SwiftUI
import Firebase

@main
struct SwiftAidAIApp: App {
    @StateObject var authViewModel = AuthViewModel()
    
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}
