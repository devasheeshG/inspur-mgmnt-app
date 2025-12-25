//
//  inspur_mgmnt_appApp.swift
//  inspur-mgmnt-app
//
//  Created by Devasheesh Mishra on 25/12/25.
//

import SwiftUI

@main
struct inspur_mgmnt_appApp: App {
    @StateObject private var viewModel = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if viewModel.isAuthenticated {
                    ContentView()
                        .environmentObject(viewModel)
                } else {
                    LoginView()
                        .environmentObject(viewModel)
                }
            }
        }
    }
}
