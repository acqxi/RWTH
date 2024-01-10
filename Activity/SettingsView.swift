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
    @State private var DarkOn = false
    
    var body: some View {
        
        NavigationView{
            Form{
                
                Section(header: Text("Personal Information")){
                    
                    TextField("First Name", text: $firstname)
                    TextField("Last Name", text: $lastname)
                    TextField("Email", text: $justmail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
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
                }
                
            }
            .navigationTitle("Settings")
        }
        
            
        
        
    }
}
    


#Preview {
    SettingsView()
}
