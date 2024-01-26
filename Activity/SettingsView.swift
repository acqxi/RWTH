//
//  SettingsView.swift
//  Activity
//
//  Created by TimurSmoev on 12/24/23.
//

import SwiftUI
import SwiftData

let kDailyNotificationId = "DAILY_NOTIFICATION"

struct SettingsView: View {
    @Environment(\.modelContext) var modelContext
    @Query var settingsList: [Settings]
    var settings: Settings? { settingsList.first }
    
    @State private var notificationPermission = UNAuthorizationStatus.notDetermined
    
    func updateSettings(callback: (_: Settings) -> Void) {
        if let settings = settings {
            callback(settings)
        } else {
            let settings = Settings()
            modelContext.insert(settings)
            callback(settings)
        }
    }
    
    func removeDailyNotification(updatingDatabase: Bool = true) {
        UNUserNotificationCenter
            .current()
            .removePendingNotificationRequests(withIdentifiers: [kDailyNotificationId])
        if updatingDatabase {
            updateSettings {
                $0.notificationTime = nil
            }
        }
    }
    
    func scheduleDailyNotification(for dateComponents: DateComponents) {
        removeDailyNotification(updatingDatabase: false)
        
        let content = UNMutableNotificationContent()
        content.title = "Lets Check What You've Got For Today!"
        content.subtitle = "Motivation is what gets you started. Habit is what keeps you going"
        content.sound = UNNotificationSound.default
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        
        // choose a random identifier
        let request = UNNotificationRequest(
            identifier: kDailyNotificationId,
            content: content,
            trigger: trigger
        )
        
        // add our notification request
        UNUserNotificationCenter.current().add(request)
        
        updateSettings {
            $0.notificationTime = HourAndMinute(
                hour: dateComponents.hour!,
                minute: dateComponents.minute ?? 0
            )
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                
                Section(header: Text("Personal Information")){
                    
                    TextField("First Name", text: Binding(
                        get: { settings?.firstName ?? "" },
                        set: { newValue in
                            updateSettings {
                                $0.firstName = newValue
                            }
                        }
                    ))
                    TextField("Last Name", text: Binding(
                        get: { settings?.lastName ?? "" },
                        set: { newValue in
                            updateSettings {
                                $0.lastName = newValue
                            }
                        }
                    ))
                    TextField("Email", text: Binding(
                        get: { settings?.email ?? "" },
                        set: { newValue in
                            updateSettings {
                                $0.email = newValue
                            }
                        }
                    ))
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled(true)
                    DatePicker("Birthday", selection: Binding(
                        get: { settings?.birthday ?? Date() },
                        set: { newValue in
                            updateSettings {
                                $0.birthday = newValue
                            }
                        }
                    ), displayedComponents: .date)
                }
                
                Section(header: Text("Visual Settings")){
                    Picker("Accent Color", selection: Binding(
                        get: { settings?.accentColor ?? .red },
                        set: { newValue in
                            updateSettings {
                                $0.accentColor = newValue
                            }
                        }
                    )) {
                        Text("Red").tag(AccentColor.red)
                        Text("Green").tag(AccentColor.green)
                        Text("Blue").tag(AccentColor.blue)
                    }
                }
                
                
                
                Section(header: Text("Notification Settings")){
                    switch (notificationPermission) {
                    case .authorized, .provisional, .ephemeral:
//                        Text("Notification Permission Granted")
                        
                        Toggle(isOn: Binding(
                            get: { settings?.notificationTime != nil },
                            set: { newValue in
                                if newValue {
                                    // Schedule notification
                                    scheduleDailyNotification(
                                        for: DateComponents(
                                            calendar: Calendar.current,
                                            hour: 8,
                                            minute: 0
                                        )
                                    )
                                } else {
                                    removeDailyNotification()
                                }
                            }
                        ), label: {
                            Text("Daily Reminder")
                        })

                        if let notificationTime = settings?.notificationTime {
                            DatePicker(
                                selection: Binding(
                                    get: {
                                        Calendar.current.date(
                                            bySettingHour: notificationTime.hour,
                                            minute: notificationTime.minute,
                                            second: 0,
                                            of: Date()
                                        )!
                                    },
                                    set: { newValue in
                                        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                                        scheduleDailyNotification(for: dateComponents)
                                    }
                                ),
                                displayedComponents: .hourAndMinute
                            ) {
                                Text("Notification Time")
                            }
                        }
                    case .denied:
                        Text("Notification Permission Denied")
                        Button("Enable in Settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                if UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                }
                            }
                        }
                    case .notDetermined:
                        Button("Enable Reminders") {
                            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                                if success {
                                    print("Permission Received!")
                                    scheduleDailyNotification(for: DateComponents(
                                        calendar: Calendar.current,
                                        hour: 8,
                                        minute: 0
                                    ))
                                } else if let error = error {
                                    print(error.localizedDescription)
                                }
                                UNUserNotificationCenter.current().getNotificationSettings { settings in
                                    notificationPermission = settings.authorizationStatus
                                }
                            }
                            
                        }
                        .onAppear {
                            UNUserNotificationCenter.current().getNotificationSettings { settings in
                                notificationPermission = settings.authorizationStatus
                                switch notificationPermission {
                                case .notDetermined, .denied:
                                    updateSettings {
                                        $0.notificationTime = nil
                                    }
                                default: break // Do nothing
                                }
                            }
                        }
                    @unknown default:
                        Text("Notification Permission Unknown")
                    }
                    
                    if notificationPermission == .authorized || notificationPermission == .ephemeral {
                        
//                        
//                        //                        Button("Everyday Morning Notification") {
//                        //
//                        //                            let content = UNMutableNotificationContent()
//                        //                            content.title = "Lets Check What You've Got For Today!"
//                        //                            content.subtitle = "Motivation is what gets you started. Habit is what keeps you going"
//                        //                            content.sound = UNNotificationSound.default
//                        //
//                        //                            // show this notification 12 hours in seconds from now
//                        //                            var dateComponents = DateComponents()
//                        //                            dateComponents.hour = 15
//                        //                            dateComponents.minute = 57
//                        //
//                        //                            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
//                        //
//                        //                            // choose a random identifier
//                        //                            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
//                        //
//                        //                            // add our notification request
//                        //                            UNUserNotificationCenter.current().add(request)
//                        //
//                        //                        }
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
