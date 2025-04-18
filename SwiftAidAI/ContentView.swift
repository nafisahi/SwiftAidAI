//
//  ContentView.swift
//  SwiftAidAI
//
//  Created by Nafisah Islam on 12/03/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        Group {
            if viewModel.userSession != nil {
                FirstAidHomeView()
            } else if viewModel.isVerificationRequired {
                VerificationCodeView(email: viewModel.tempUser?.email ?? "") {
                    // Verification complete callback
                }
            } else {
                LoginView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
