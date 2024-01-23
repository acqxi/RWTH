//
//  SettingsView.swift
//  Activity
//
//  Created by TimurSmoev on 12/24/23.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) var modelContext
    @Query var settingsList: [Settings]
    var settings: Settings? { settingsList.first }
    
    @State private var firstname = ""
    @State private var lastname = ""
    @State private var justmail = ""
    @State private var birthday = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                
                Section(header: Text("Personal Information")){
                    
                    TextField("First Name", text: $firstname)
                    TextField("Last Name", text: $lastname)
                    TextField("Email", text: $justmail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled(true)
                    DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
                    
                    Button{
                        print("Save")
                    } label: {
                        Text("Save Changes")
                    }
                    
                }
                
                Section(header: Text("Visual Settings")){
                    Picker("Accent Color", selection: Binding(
                        get: { settings?.accentColor ?? .red },
                        set: { newValue in
                            if let settings = settings {
                                settings.accentColor = newValue
                            } else {
                                let settings = Settings()
                                settings.accentColor = newValue
                                modelContext.insert(settings)
                            }
                        }
                    )) {
                        Text("Red").tag(AccentColor.red)
                        Text("Green").tag(AccentColor.green)
                        Text("Blue").tag(AccentColor.blue)
                    }
                }
                
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
