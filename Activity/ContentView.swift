//
//  ContentView.swift
//  Activity
//
//  Created by TimurSmoev on 12/24/23.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query var settingsList: [Settings]
    var settings: Settings? { settingsList.first }
    
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
                    Text("Summary")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
            
            
        }
        .accentColor(settings?.accentColor.swiftuiAccentColor ?? .red)
    }
}



#Preview {
    ContentView()
}
