//
//  AlarmsView.swift
//  ProgressiveAlarm
//
//  Created by Joaquim Menezes on 21/04/24.
//

import SwiftUI

struct AlarmsView: View {
    let alarms: [AlarmData]
    
    var body: some View {
        NavigationView {
            List(alarms, id: \.self) { alarm in
                VStack(alignment: .leading) {
                    Text("Date: \(formattedDate(alarm.date))")
                    Text("Sleep Time: \(formattedTime(alarm.sleepTime))")
                    Text("Wake Time: \(formattedTime(alarm.wakeTime))")
                }
            }
            .navigationBarTitle("Alarms")
        }
    }
    
    // Helper function to format date
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
    
    // Helper function to format time
    private func formattedTime(_ time: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
}

struct AlarmsView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmsView(alarms: [])
    }
}
