//
//  AccoutView.swift
//  Activity
//
//  Created by TimurSmoev on 12/24/23.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack{
            TaskDetailView(date:Date())
        }
    }
}

// Preview provider for visualizing the HomeView in Xcode's canvas.
#Preview {
    HomeView()
}
