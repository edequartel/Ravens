//
//  TimeManager.swift
//  Ravens
//
//  Created by Eric de Quartel on 18/10/2024.
//
import SwiftUI
import Combine

class TimerManager: ObservableObject {
    // Use EnvironmentObject to access NotificationsManager

    private var timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Listen for timer events and handle task scheduling
        timer
            .sink { [weak self] _ in
                self?.startYourTask()
            }
            .store(in: &cancellables)
    }

    func startYourTask() {
        // Code to run every 15 seconds
        print("Task executed at \(Date())")
        // Access notificationsManager to schedule notifications
        //this not clear how to work with this
        //want to get the latest observation and check if there is a new in de list if so
        //notify the user
    }

    deinit {
        cancellables.removeAll()
    }
}
