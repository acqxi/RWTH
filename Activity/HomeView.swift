//
//  AccoutView.swift
//  Activity
//
//  Created by TimurSmoev on 12/24/23.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        // Navigation stack for the Home screen, providing navigation capabilities.
        NavigationStack {
            // Displaying the main text for the Home screen.
            Text("Home")
                .navigationTitle("Home")
        }
    }
}

// Preview provider for visualizing the HomeView in Xcode's canvas.
#Preview {
    HomeView()
}
