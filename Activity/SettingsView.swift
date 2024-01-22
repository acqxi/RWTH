//
//  SettingsView.swift
//  Activity
//
//  Created by TimurSmoev on 12/24/23.
//

import SwiftUI

struct SettingsView: View {
    
    @State private var firstname = ""
    @State private var lastname = ""
    @State private var justmail = ""
    @State private var birthday = Date()
    @State private var DarkOn = UserDefaults.standard.bool(forKey: "forceDarkMode")
    @State private var color = "Red"
    
    var body: some View {
        NavigationStack {
            Form{
                
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
                    Toggle("Dark Mode", isOn: $DarkOn)
                        .toggleStyle(SwitchToggleStyle(tint: .red))
                        .onChange(of: DarkOn) {
                            UserDefaults.standard.set(DarkOn, forKey: "forceDarkMode")
                        }
                    
                    Picker("Accent Color", selection: $color) {
                        Text("Red").tag("Red")
                        Text("Green").tag("Green")
                        Text("Blue").tag("Blue")
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
