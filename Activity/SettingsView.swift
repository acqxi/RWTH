//
//  SettingsView.swift
//  Activity
//
//  Created by TimurSmoev on 12/24/23.
//  Refactored and commented on by Yu-Ting on 27.01.24.
//

import SwiftUI
import SwiftData

// Constants for reuse and easy modification
private enum Constants {
    static let dailyNotificationId = "DAILY_NOTIFICATION"
    static let notificationTitle = "Let's Check What You've Got For Today!"
    static let notificationSubtitle = "Motivation is what gets you started. Habit is what keeps you going."
    static let defaultHour = 8
    static let defaultMinute = 0
}

struct SettingsView: View {
    @Environment(\.modelContext) var modelContext
    @Query var settingsList: [Settings]
    var settings: Settings? { settingsList.first }

    @State private var notificationPermission = UNAuthorizationStatus.notDetermined

    // Function to update settings, creating new settings if none exist.
    private func updateSettings(_ updateBlock: (_ settings: Settings) -> Void) {
        let currentSettings = settings ?? createNewSettings()
        updateBlock(currentSettings)
    }

    private func createNewSettings() -> Settings {
        let newSettings = Settings()
        modelContext.insert(newSettings)
        return newSettings
    }

    // Function to remove daily notifications, with an option to update the database.
    private func removeDailyNotification(updatingDatabase: Bool = true) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [Constants.dailyNotificationId])
        if updatingDatabase {
            updateSettings { $0.notificationTime = nil }
        }
    }

    // Function to schedule daily notifications.
    private func scheduleDailyNotification(for dateComponents: DateComponents) {
        removeDailyNotification(updatingDatabase: false)
        let content = createNotificationContent()
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: Constants.dailyNotificationId,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
        updateSettings { $0.notificationTime = HourAndMinute(hour: dateComponents.hour ?? Constants.defaultHour, minute: dateComponents.minute ?? Constants.defaultMinute) }
    }

    // Creating notification content to reduce complexity in scheduleDailyNotification
    private func createNotificationContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = Constants.notificationTitle
        content.subtitle = Constants.notificationSubtitle
        content.sound = UNNotificationSound.default
        return content
    }

    var body: some View {
        NavigationStack {
            Form {
                // Section for font size adjustment
                Section(header: Text("Font Size")) {
                    Slider(
                        value: Binding(
                            get: { self.settings?.dynamicFontSize ?? 14 },
                            set: { newValue in
                                if var settings = self.settings {
                                    settings.dynamicFontSize = newValue
                                }
                            }
                        ),
                        in: 12...24, // Range for font size
                        step: 1
                    )
                    Text("Font size: \(Int(settings?.dynamicFontSize ?? 14))")
                }
                
                personalInfoSection()
                visualSettingsSection()
                notificationSettingsSection()
            }
            .navigationTitle("Settings")
            .font(.system(size: settings?.dynamicFontSize ?? 14))
        }
    }

    // Personal Information Section
    private func personalInfoSection() -> some View {
        Section(header: Text("Personal Information")) {
            // Use the dynamic font size for TextFields and Labels
            TextField("First Name", text: textFieldBinding(for: \.firstName))
            TextField("Last Name", text: textFieldBinding(for: \.lastName))
            TextField("Email", text: textFieldBinding(for: \.email))
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .autocorrectionDisabled(true)
            DatePicker("Birthday", selection: datePickerBinding(for: \.birthday), displayedComponents: .date)
        }
        .font(.system(size: settings?.dynamicFontSize ?? 14))
    }

    // Visual Settings Section
    private func visualSettingsSection() -> some View {
        Section(header: Text("Visual Settings")) {
            Picker("Accent Color", selection: pickerBinding(for: \.accentColor, defaultValue: AccentColor.yellow)) {
                Text("Yellow").tag(AccentColor.yellow)
                Text("Green").tag(AccentColor.green)
                Text("Blue").tag(AccentColor.blue)
                Text("Purple").tag(AccentColor.purple)
            }
        }
    }

    // Notification Settings Section
    private func notificationSettingsSection() -> some View {
        Section(header: Text("Notification Settings")) {
            switch notificationPermission {
            case .authorized, .provisional, .ephemeral:
                dailyReminderToggle()
                notificationTimePicker()
            case .denied:
                notificationPermissionDeniedView()
            case .notDetermined:
                enableRemindersButton()
            @unknown default:
                Text("Notification Permission Unknown")
            }
        }
        .font(.system(size: settings?.dynamicFontSize ?? 14))
    }

    // Extracting smaller view components
    private func dailyReminderToggle() -> some View {
        Toggle(isOn: toggleBinding(), label: { Text("Daily Reminder")})
            .font(.system(size: settings?.dynamicFontSize ?? 14))
    }

    private func notificationTimePicker() -> some View {
        Group {  // Using Group instead of AnyView for better performance and simplicity
            if let notificationTime = settings?.notificationTime {
                DatePicker(
                    selection: datePickerBinding(forNotificationTime: notificationTime),
                    displayedComponents: .hourAndMinute
                ) {
                    Text("Notification Time")
                }
            } else {
                EmptyView()
            }
        }
    }

    private func notificationPermissionDeniedView() -> some View {
        VStack {
            Text("Notification Permission Denied")
            Button("Enable in Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }

    private func enableRemindersButton() -> some View {
        Button("Enable Reminders") {
            requestNotificationPermission()
        }
        .onAppear {
            checkAndHandleNotificationPermission()
        }
    }

    // Binding helper functions
    private func textFieldBinding(for keyPath: WritableKeyPath<Settings, String?>) -> Binding<String> {
        Binding(
            get: { self.settings?[keyPath: keyPath] ?? "" },
            set: { newValue in
                self.updateSettings { settings in
                    var mutableSettings = settings
                    mutableSettings[keyPath: keyPath] = newValue
                }
            }
        )
    }

    private func datePickerBinding(for keyPath: WritableKeyPath<Settings, Date?>) -> Binding<Date> {
        Binding(
            get: { self.settings?[keyPath: keyPath] ?? Date() }, // Default to current date if nil
            set: { newValue in
                self.updateSettings { settings in
                    var mutableSettings = settings
                    mutableSettings[keyPath: keyPath] = newValue
                }
            }
        )
    }
    
    private func fontSizeBinding(for keyPath: WritableKeyPath<Settings, CGFloat?>) -> Binding<CGFloat> {
        Binding(
            get: { self.settings?[keyPath: keyPath] ?? 14 },
            set: { newValue in
                self.updateSettings { settings in
                    var mutableSettings = settings
                    mutableSettings[keyPath: keyPath] = newValue
                }
            }
        )
    }
    
    private func pickerBinding<T>(for keyPath: WritableKeyPath<Settings, T>, defaultValue: T) -> Binding<T> {
        Binding(
            get: { self.settings?[keyPath: keyPath] ?? defaultValue },
            set: { newValue in
                self.updateSettings { settings in
                    var mutableSettings = settings
                    mutableSettings[keyPath: keyPath] = newValue
                }
            }
        )
    }

    private func toggleBinding() -> Binding<Bool> {
        Binding(
            get: { self.settings?.notificationTime != nil },
            set: { newValue in
                if newValue {
                    scheduleDailyNotification(for: DateComponents(calendar: Calendar.current, hour: Constants.defaultHour, minute: Constants.defaultMinute))
                } else {
                    removeDailyNotification()
                }
            }
        )
    }

    private func datePickerBinding(forNotificationTime notificationTime: HourAndMinute) -> Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(bySettingHour: notificationTime.hour, minute: notificationTime.minute, second: 0, of: Date()) ?? Date()
            },
            set: { newValue in
                let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                scheduleDailyNotification(for: dateComponents)
            }
        )
    }

    // Functions for notification permission handling
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, _ in
            if success {
                scheduleDailyNotification(for: DateComponents(calendar: Calendar.current, hour: Constants.defaultHour, minute: Constants.defaultMinute))
            }
            refreshNotificationPermissionStatus()
        }
    }

    private func checkAndHandleNotificationPermission() {
        refreshNotificationPermissionStatus()
        if notificationPermission == .notDetermined || notificationPermission == .denied {
            updateSettings { $0.notificationTime = nil }
        }
    }

    private func refreshNotificationPermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            notificationPermission = settings.authorizationStatus
        }
    }
}
    
#Preview{
    SettingsView()
}
