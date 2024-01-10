//
//  ContentView.swift
//  Activity
//
//  Created by TimurSmoev on 12/24/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
        TabView {
            
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            
            CalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
			
			ProjectsView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Projects")
                }
            
            ActivityListView()
                .tabItem {
                    Image(systemName: "figure.highintensity.intervaltraining")
                    Text("Activity List")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
            
            
        }
        
        .accentColor(.red)
        // .environment(\.colorScheme, .dark)
        
    }
}



#Preview {
    ContentView()
}
