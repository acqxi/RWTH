//
//  AccoutView.swift
//  Activity
//
//  Created by TimurSmoev on 12/24/23.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query var settingsList: [Settings]
    var settings: Settings? { settingsList.first }
    
    var body: some View {
        let title = settings?.firstName.map { String(format: NSLocalizedString("WelcomeWithName", comment: ""), $0) } ?? NSLocalizedString("Welcome", comment: "")
        
        NavigationStack{
            VStack {
                if settings == nil {
                    Group {
                        HStack {
                            Image(systemName: "info.circle.fill")
                            VStack(alignment: .leading) {
                                Text("Hint".localized)
                                    .multilineTextAlignment(.leading)
                                    .font(.title2)
                                Text("Consider going to the Settings tab to customize the application, set your name or enable notifications".localized)
                            }
                        }.padding()
                    }
                    .background(Color.accentColor.opacity(0.4))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .inset(by: 1)
                            .stroke(Color.accentColor.opacity(0.6), lineWidth: 1)
                    )
                    .padding()
                }
                
                Text("Today").font(.title)
            
                TaskDetailView(date:Date())
            }
            .navigationTitle(title)
        }
    }
}

// Preview provider for visualizing the HomeView in Xcode's canvas.
#Preview {
    HomeView()
}
