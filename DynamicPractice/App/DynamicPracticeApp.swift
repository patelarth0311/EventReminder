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
            
            ContentView().environmentObject(accesser)
               
               
          
        }
        
        
        .onChange(of: phase) { newPhase in
            switch newPhase {
            case .background:
                scheduleAppRefresh()
               
            default: break;
            }
            
        }
        
        
        .backgroundTask(.appRefresh("TASK")) {
           
            await accesser.endAllActivities()
        
            
        }
        
        
    }
        
}



func scheduleAppRefresh()   {

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




