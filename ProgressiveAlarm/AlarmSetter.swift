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
    
    @State private var showAlert = false
    
    
    // State to track navigation
        @State private var isShowingAlarms = false
        @State private var alarms: [AlarmData] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                // Date pickers for start and end dates
                VStack {
                    
                    
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                        .padding()
                        .foregroundStyle(.cyan)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                        .padding()
                        .foregroundStyle(.cyan)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    // Time pickers for current and desired sleep times
                    DatePicker("Current Sleep Time", selection: $currentSleepTime, displayedComponents: .hourAndMinute)
                        .padding()
                        .foregroundStyle(.orange)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    DatePicker("Desired Sleep Time", selection: $desiredSleepTime, displayedComponents: .hourAndMinute)
                        .padding()
                        .foregroundStyle(.green)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    // Time pickers for current and desired wake times
                    DatePicker("Current Wake Time", selection: $currentWakeTime, displayedComponents: .hourAndMinute)
                        .padding()
                        .foregroundStyle(.orange)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    DatePicker("Desired Wake Time", selection: $desiredWakeTime, displayedComponents: .hourAndMinute)
                        .padding()
                        .foregroundStyle(.green)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                }
                
                // Button to set progressive alarms
                Button(action: {
                    alarms.removeAll()
                    setProgressiveAlarms()
                    isShowingAlarms = true 
                }) {
                    Text("Set Progressive Alarms")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.green]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(10)
                .shadow(color: .gray, radius: 3, x: 0, y: 3)
                .padding(.horizontal)
                
                ///
                ///
                ///
                
                // Button to grant notification permission
                Button(action: {
                    requestNotificationPermission()
                }) {
                    Text("Grant Permission for Notifications")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.green]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(10)
                .shadow(color: .gray, radius: 3, x: 0, y: 3)
                .padding(.horizontal)
                
                
                // Button to navigate to AlarmsView
                NavigationLink(destination: AlarmsView(alarms: alarms),
                               isActive: $isShowingAlarms) {
                    EmptyView()
                }
                
                ///
                ///
                ///
                ///
                
                
                ///
                ///
                ///
                Button("Clear All Current Alarms") {
                    showAlert = true
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(10)
                .shadow(color: .gray, radius: 3, x: 0, y: 3)
                .foregroundStyle(.red)
                .padding(.horizontal)
                .padding(.top,10)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Alert"), message: Text("All of your current alarms will be cleared"), primaryButton: .default(Text("OK"), action: {
                        alarms.removeAll()
                        // Code to execute when "OK" is pressed
                        print("OK button pressed")
                    }), secondaryButton: .cancel(Text("Cancel")))
                }
                ///
                ///
                ///
                ///
                
            }.navigationTitle("Progressive Alarm")
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
        while currentDate <= endDate {
            scheduleNotification(for: currentDate, sleepTime: currentSleepTime, wakeTime: currentWakeTime)
            
            // Increment date and times
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? Date()
            currentSleepTime = calendar.date(byAdding: .minute, value: sleepTimeIncrement, to: currentSleepTime) ?? Date()
            currentWakeTime = calendar.date(byAdding: .minute, value: wakeTimeIncrement, to: currentWakeTime) ?? Date()
            
            // Example code to append alarm data
            alarms.append(AlarmData(date: currentDate,
                                    sleepTime: currentSleepTime,
                                    wakeTime: currentWakeTime))
            
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




#Preview {
    ContentView()
        
}
