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

struct DynamicPracticeApp: App {
    
    
    
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
                scheduleActivityEnd()
                scheduleActivityUpdate()
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
            
            await accesser.endAllActivities()
            
            
        }
        .backgroundTask(.appRefresh("TASKTWO")) {
            
            await accesser.updateCurrentEvents()
            
            
        }
        
        
    }
    
}



func scheduleActivityEnd()   {
    
    let request = BGAppRefreshTaskRequest(identifier: "TASK")
    var endTime = Date.now
    
    if #available(iOS 16.1, *) {
        if Activity<EventTrackerAttributes>.activities.count > 0 && Activity<EventTrackerAttributes>.activities[0].contentState.endDate > Date.now {
            endTime = Activity<EventTrackerAttributes>.activities[0].contentState.endDate
        }
    }
    request.earliestBeginDate =  endTime
    do {
        try BGTaskScheduler.shared.submit(request)
        print("Scheduled")
        
    } catch {
        print("Could not schedule app refresh: \(error)")
    }
}


func scheduleActivityUpdate()   {
    
    let request = BGAppRefreshTaskRequest(identifier: "TASKTWO")
    var startTime = Date.now
    
    if #available(iOS 16.1, *) {
        if Activity<EventTrackerAttributes>.activities.count > 0 && Activity<EventTrackerAttributes>.activities[0].contentState.startDate > Date.now {
            startTime = Activity<EventTrackerAttributes>.activities[0].contentState.startDate
        }
    }
  
    request.earliestBeginDate =  startTime
    
    do {
        try BGTaskScheduler.shared.submit(request)
        print("Scheduled")
        
    } catch {
        print("Could not schedule app refresh: \(error)")
    }
    
    
}



