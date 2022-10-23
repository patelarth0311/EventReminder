//
//  ContentView.swift
//  DynamicPractice
//
//  Created by Arth Patel on 10/16/22.
//

import SwiftUI
import ActivityKit



@available(iOS 16.1, *)
struct ContentView: View {
    
    @StateObject var accesser =  CalenderAccesser()

    
    var body: some View {
        NavigationView {
            
            List {
                if let fetchedEvents =  accesser.events {
                    ForEach(fetchedEvents) {
                        event in
                        EventView(accesser: accesser, eventName: event.eventName, startDate: event.startDate, locationName: event.location, address: event.address)
                        
                    }
                    
                }
                
            }
            
                .navigationTitle("Events")
            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    
                        Button {
                            accesser.fetchCurrentEvents()
                           
                            
                        } label: {
                            HStack {
                                Image(systemName: "plus")
                                    .font(.system(.title3))
                                    .foregroundColor(.yellow)
                                    
                            }
                            
                            
                        }
                    
                    
                }
            }
            
        }
        .refreshable {
            accesser.fetchCurrentEvents()
           
        }
        }
        
       
}


@available(iOS 16.1, *)
struct EventView: View {
    
    @State private var activateActivity = false
    
    var accesser: CalenderAccesser
    
    var eventName: String
    var startDate: Date
    var locationName: String
    var address: String
    @State private var activities = Activity<EventTrackerAttributes>.activities
    
    var body: some View {
        
        HStack {
            Text(eventName)
                .font(.system(.title3, design: .default))
            Toggle("", isOn: $activateActivity )
                .onTapGesture {
                    
                    if !activateActivity {
                        accesser.startActivity(name: eventName, startTime: startDate, eventLocation: locationName,
                                               address: address)
                      
                    } else {
                        
                        if let index = Activity<EventTrackerAttributes>.activities.firstIndex(where: {$0.contentState.eventName == eventName}) {
                          
                            accesser.endActivity(event: eventName, activities: Activity<EventTrackerAttributes>.activities[index])
                        }
                        
                        
                    }
                   

                }
                     
        }
        
        
    }
    
    
    
}

