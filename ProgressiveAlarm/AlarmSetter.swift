//
//  ContentView.swift
//  ProgressiveAlarm
//
//  Created by Joaquim Menezes on 27/03/24.
//


import SwiftUI
import UserNotifications

struct ContentView: View {
    // Properties to store user inputs
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var currentSleepTime = Date()
    @State private var desiredSleepTime = Date()
    @State private var currentWakeTime = Date()
    @State private var desiredWakeTime = Date()
    
    var body: some View {
        VStack {
            // Date pickers for start and end dates
            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                .padding()
            
            DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                .padding()
            
            // Time pickers for current and desired sleep times
            DatePicker("Current Sleep Time", selection: $currentSleepTime, displayedComponents: .hourAndMinute)
                .padding()
            
            DatePicker("Desired Sleep Time", selection: $desiredSleepTime, displayedComponents: .hourAndMinute)
                .padding()
            
            // Time pickers for current and desired wake times
            DatePicker("Current Wake Time", selection: $currentWakeTime, displayedComponents: .hourAndMinute)
                .padding()
            
            DatePicker("Desired Wake Time", selection: $desiredWakeTime, displayedComponents: .hourAndMinute)
                .padding()
            
            // Button to set progressive alarms
            Button(action: {
                setProgressiveAlarms()
            }) {
                Text("Set Progressive Alarms")
            }
            .padding()
            
            // Button to grant notification permission
            Button(action: {
                requestNotificationPermission()
            }) {
                Text("Grant Permission for Notifications")
            }
            .padding()
        }
    }
    
    // Function to set progressive alarms
    private func setProgressiveAlarms() {
        let calendar = Calendar.current
        
        // Calculate number of days in program
        let numberOfDays = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        
        // Calculate sleep time and wake time increments
        let sleepTimeIncrement = calculateIncrement(from: currentSleepTime, to: desiredSleepTime, numberOfDays: numberOfDays)
        let wakeTimeIncrement = calculateIncrement(from: currentWakeTime, to: desiredWakeTime, numberOfDays: numberOfDays)
        
        // Clear existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Schedule notifications for each day
        var currentDate = startDate
        for _ in 0..<numberOfDays {
            scheduleNotification(for: currentDate, sleepTime: currentSleepTime, wakeTime: currentWakeTime)
            
            // Increment date and times
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? Date()
            currentSleepTime = calendar.date(byAdding: .minute, value: sleepTimeIncrement, to: currentSleepTime) ?? Date()
            currentWakeTime = calendar.date(byAdding: .minute, value: wakeTimeIncrement, to: currentWakeTime) ?? Date()
        }
    }
    
    // Helper function to calculate time increment
    private func calculateIncrement(from startTime: Date, to endTime: Date, numberOfDays: Int) -> Int {
        let totalMinutes = Calendar.current.dateComponents([.minute], from: startTime, to: endTime).minute ?? 0
        return totalMinutes / numberOfDays
    }
    
    // Function to schedule notification for a specific date
    // Function to schedule notification for a specific date
    private func scheduleNotification(for date: Date, sleepTime: Date, wakeTime: Date) {
        let calendar = Calendar.current
        
        // Set notification content for sleep time
        let sleepContent = UNMutableNotificationContent()
        sleepContent.title = "Time to sleep!"
        sleepContent.body = "It's time to go to bed."
        sleepContent.sound = UNNotificationSound.default
        
        // Set notification content for wake time
        let wakeContent = UNMutableNotificationContent()
        wakeContent.title = "Time to wake up!"
        wakeContent.body = "It's time to start your day."
        wakeContent.sound = UNNotificationSound.default
        
        // Calculate notification fire date for sleep time
        let sleepComponents = calendar.dateComponents([.hour, .minute], from: sleepTime)
        var sleepNotificationDate = calendar.date(bySettingHour: sleepComponents.hour ?? 0, minute: sleepComponents.minute ?? 0, second: 0, of: date) ?? date
        if sleepNotificationDate < Date() {
            sleepNotificationDate = calendar.date(byAdding: .day, value: 1, to: sleepNotificationDate) ?? Date()
        }
        
        // Calculate notification fire date for wake time
        let wakeComponents = calendar.dateComponents([.hour, .minute], from: wakeTime)
        let wakeNotificationDate = calendar.date(bySettingHour: wakeComponents.hour ?? 0, minute: wakeComponents.minute ?? 0, second: 0, of: date) ?? date
        
        // Create notification trigger for sleep time
        let sleepTrigger = UNCalendarNotificationTrigger(dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: sleepNotificationDate), repeats: false)
        
        // Create notification trigger for wake time
        let wakeTrigger = UNCalendarNotificationTrigger(dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: wakeNotificationDate), repeats: false)
        
        // Create notification request for sleep time
        let sleepRequest = UNNotificationRequest(identifier: UUID().uuidString, content: sleepContent, trigger: sleepTrigger)
        
        // Create notification request for wake time
        let wakeRequest = UNNotificationRequest(identifier: UUID().uuidString, content: wakeContent, trigger: wakeTrigger)
        
        // Add notification requests to notification center
        // Add notification requests to notification center
        UNUserNotificationCenter.current().add(sleepRequest) { error in
            if let error = error {
                print("Error scheduling sleep time notification: \(error.localizedDescription)")
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d, yyyy - HH:mm"
                let formattedDate = formatter.string(from: sleepNotificationDate)
                print("Successfully scheduled sleep time notification for \(formattedDate)")
                print("\n")
            }
        }
        UNUserNotificationCenter.current().add(wakeRequest) { error in
            if let error = error {
                print("Error scheduling wake time notification: \(error.localizedDescription)")
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d, yyyy - HH:mm"
                let formattedDate = formatter.string(from: wakeNotificationDate)
                print("Successfully scheduled wake time notification for \(formattedDate)")
            }
        }

    }

    
    // Function to request notification permission
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
