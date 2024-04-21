//
//  AlarmData.swift
//  ProgressiveAlarm
//
//  Created by Joaquim Menezes on 21/04/24.
//
import SwiftUI

struct AlarmData: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let sleepTime: Date
    let wakeTime: Date
}
