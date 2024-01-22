//
//  ActivityApp.swift
//  Activity
//
//  Created by TimurSmoev on 12/24/23.
//

import SwiftUI
import SwiftData

@main
struct ActivityApp: App {
    
    let container: ModelContainer = {
        let schema = Schema([
            Project.self,
            Settings.self,
        ])
        //let config = ModelConfiguration(groupContainer: <#T##ModelConfiguration.GroupContainer#>, cloudKitDatabase: <#T##ModelConfiguration.CloudKitDatabase#>)
        let container = try! ModelContainer(for: schema, configurations: [])
        return container
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
