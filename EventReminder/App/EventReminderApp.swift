//
//  DynamicPracticeApp.swift
//  DynamicPractice
//
//  Created by Arth Patel on 10/16/22.
//

import SwiftUI
import BackgroundTasks
import Combine
import EventKit
import ActivityKit
@available(iOS 16.1, *)
@main

struct EventReminderApp: App {
    
    
    
    @StateObject var accesser =  CalenderAccesser()
    
    
    @Environment(\.scenePhase) private var phase
    
    var body: some Scene {
        WindowGroup {
            
            ContentView(
            ).environmentObject(accesser)
            
            
        }
        
        
        
        .onChange(of: phase) { newPhase in
            switch newPhase {
            case .active:
                accesser.fetchCurrentEvents()
                accesser.updateCurrentEvents()
            case .background:
                
                if Activity<EventTrackerAttributes>.activities.count > 0 && Activity<EventTrackerAttributes>.activities[0].contentState.startDate >= Date.now {
                    let request = BGAppRefreshTaskRequest(identifier: "TASK")
                    
                    let startTime = Activity<EventTrackerAttributes>.activities[0].contentState.startDate
                    makeRequest(request: request, time: startTime)
                } else if Activity<EventTrackerAttributes>.activities.count > 0 && Activity<EventTrackerAttributes>.activities[0].contentState.endDate >= Date.now {
                   
                    let request = BGAppRefreshTaskRequest(identifier: "TASKTWO")
                    let endTime = Activity<EventTrackerAttributes>.activities[0].contentState.endDate
                    makeRequest(request: request, time: endTime)
                } else if Activity<EventTrackerAttributes>.activities.count > 0 {
                    let request = BGAppRefreshTaskRequest(identifier: "TASKTWO")
                    makeRequest(request: request, time: Date.now)
                }
                
            case .inactive:
                CalenderAccesser.save(events: accesser.events) { result in
                    switch result {
                    case .failure(let error):
                        fatalError(error.localizedDescription)
                    case .success(let events):
                        print(events)
                    }
                }
            default: break;
            }
            
        }
        
        
        .backgroundTask(.appRefresh("TASK")) {
            
            await accesser.updateCurrentEvents()
        
        }
        .backgroundTask(.appRefresh("TASKTWO")) {
            
            await accesser.endAllActivities()
            
            
        }
        
        
    }
    
}


func makeRequest(request: BGAppRefreshTaskRequest, time: Date) {
    
    request.earliestBeginDate =  time
    
    do {
        try BGTaskScheduler.shared.submit(request)
        print("Task scheduled")
        print(time.formatted())
        
    } catch {
        print("Could not schedule app refresh: \(error)")
    }
    
}


