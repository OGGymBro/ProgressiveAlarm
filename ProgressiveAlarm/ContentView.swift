//
//  ContentView.swift
//  ProgressiveAlarm
//
//  Created by Joaquim Menezes on 27/03/24.
//


import SwiftUI
import UserNotifications

struct ContentView: View {
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var currentSleepTime = Date()
    @State private var currentWakeTime = Date()
    @State private var desiredSleepTime = Date()
    @State private var desiredWakeTime = Date()
    @State private var showAlert = false
    @State private var showTimeErrorAlert = false
    @State private var dailySleepTimes: [Date] = []
    @State private var dailyWakeTimes: [Date] = []
    @State private var notificationDates: [Date] = []

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Program Details")) {
                        DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                        DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                    }
                    
                    Section(header: Text("Current Sleep & Wake Time")) {
                        DatePicker("Current Sleep Time", selection: $currentSleepTime, displayedComponents: .hourAndMinute)
                        DatePicker("Current Wake Time", selection: $currentWakeTime, displayedComponents: .hourAndMinute)
                    }
                    
                    Section(header: Text("Desired Sleep & Wake Time")) {
                        DatePicker("Desired Sleep Time", selection: $desiredSleepTime, displayedComponents: .hourAndMinute)
                        DatePicker("Desired Wake Time", selection: $desiredWakeTime, displayedComponents: .hourAndMinute)
                    }
                    
                    Button(action: {
                        // Handle done button action
                        if checkDays() && checkTimeDifference() {
                            scheduleNotifications()
                        }
                    }) {
                        Text("Done")
                    }
                }
                
                NavigationLink(destination: SleepWakeTimesView(dailySleepTimes: $dailySleepTimes, dailyWakeTimes: $dailyWakeTimes, notificationDates: $notificationDates)) {
                    Text("Sleep & Wake Times")
                }

            }
            .navigationBarTitle("Progressive Alarm")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text("The number of days between the start and end dates must be greater than or equal to 112."), dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $showTimeErrorAlert) {
                Alert(title: Text("Error"), message: Text("The desired sleep and wake times must be at least 6 hours apart."), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    // Function to check if the number of days is >= 112
    private func checkDays() -> Bool {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        guard days >= 2 else {
            showAlert = true
            return false
        }
        return true
    }
    
    // Function to check if desired sleep and wake times are at least 6 hours apart
    
    
    //
    private func checkTimeDifference() -> Bool {
//        let calendar = Calendar.current
//        let components = calendar.dateComponents([.minute], from: desiredSleepTime, to: desiredWakeTime)
//        
//        guard let minutesApart = components.minute, minutesApart >= 360 else {
//            showTimeErrorAlert = true
//            return false
//        }
        
        return true
    }
//

    
    // Function to schedule notifications...
    // Function to schedule notifications
    // Function to schedule notifications and append scheduled dates to dailySleepTimes and dailyWakeTimes arrays
    private func scheduleNotifications() {
            let calendar = Calendar.current
            
            // Calculate the number of days between start and end dates
            let days = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
            
            // Calculate the incremental changes for sleep and wake times
            let sleepTimeIncrement = calculateTimeIncrement(from: currentSleepTime, to: desiredSleepTime, days: days)
            let wakeTimeIncrement = calculateTimeIncrement(from: currentWakeTime, to: desiredWakeTime, days: days)
            
            // Clear existing notification requests
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            // Schedule notifications for each day of the program
            for i in 0...days {
                let notificationDate = calendar.date(byAdding: .day, value: i, to: startDate)!
                let sleepTime = calendar.date(byAdding: .minute, value: sleepTimeIncrement * i, to: currentSleepTime)!
                let wakeTime = calendar.date(byAdding: .minute, value: wakeTimeIncrement * i, to: currentWakeTime)!
                
                scheduleNotification(title: "Sleep Time", body: "Time to sleep!", date: sleepTime)
                scheduleNotification(title: "Wake Time", body: "Wake up!", date: wakeTime)
                
                // Append scheduled sleep and wake times to dailySleepTimes and dailyWakeTimes arrays
                dailySleepTimes.append(sleepTime)
                dailyWakeTimes.append(wakeTime)
                
                // Append notification dates
                notificationDates.append(notificationDate)
            }
        }

    // Function to calculate time increment per day
    private func calculateTimeIncrement(from: Date, to: Date, days: Int) -> Int {
        let calendar = Calendar.current
        let totalMinutes = calendar.dateComponents([.minute], from: from, to: to).minute ?? 0
        return totalMinutes / days
    }

    // Function to schedule a single notification
    private func scheduleNotification(title: String, body: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }

}

struct SleepWakeTimesView: View {
    @Binding var dailySleepTimes: [Date]
    @Binding var dailyWakeTimes: [Date]
    @Binding var notificationDates: [Date]

    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Sleep Times")) {
                        ForEach(dailySleepTimes.indices, id: \.self) { index in
                            SleepWakeItemView(date: dailySleepTimes[index], label: "Sleep Time", notificationDate: notificationDates[index])
                        }
                    }

                    Section(header: Text("Wake Times")) {
                        ForEach(dailyWakeTimes.indices, id: \.self) { index in
                            SleepWakeItemView(date: dailyWakeTimes[index], label: "Wake Time", notificationDate: notificationDates[index])
                        }
                    }
                }
                .listStyle(GroupedListStyle())
            }
            .navigationBarTitle("Sleep & Wake Times")
        }
    }
    
    struct SleepWakeItemView: View {
            var date: Date
            var label: String
            var notificationDate: Date

            var body: some View {
                VStack(alignment: .leading) {
                    Text(label)
                        .font(.headline)
                    HStack {
                        Text(timeFormatter.string(from: date))
                            .font(.subheadline)
                        Spacer()
                        Text(dateFormatter.string(from: notificationDate))
                            .font(.subheadline)
                    }
                }
            }

            private let timeFormatter: DateFormatter = {
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                return formatter
            }()

            private let dateFormatter: DateFormatter = {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                return formatter
            }()
        }
    
}




#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
