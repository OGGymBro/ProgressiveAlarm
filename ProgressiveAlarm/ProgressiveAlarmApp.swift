//
//  ProgressiveAlarmApp.swift
//  ProgressiveAlarm
//
//  Created by Joaquim Menezes on 27/03/24.
//

import SwiftUI
import SwiftData

@main
struct ProgressiveAlarmApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            AlarmSetter()
        }
        .modelContainer(sharedModelContainer)
    }
}
