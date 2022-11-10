//
//  ContentView.swift
//  DynamicPractice
//
//  Created by Arth Patel on 10/16/22.
//

import SwiftUI
import ActivityKit
import EventKit
import Combine


@available(iOS 16.1, *)
struct ContentView: View {
    
    @State private var searchText = ""
   
    @EnvironmentObject var accesser: CalenderAccesser
    @State private var bgColor = Color("Color")
 
    
    var body: some View {
        NavigationView {
            
            List {
                Section{
                    EventView( color: $bgColor).environmentObject(accesser)

                } header: {
                    Text("\(Date.now.formatted(.dateTime.weekday().day().month()))")
                }
                
            }
           
           
            
            .navigationTitle("Events")
            
            
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                  
                    Button("\(Image(systemName: "calendar.badge.plus"))") {
                        accesser.fetchCurrentEvents()
                       
                    }
                    .font(.system(.title3, design: .default))
                    .foregroundColor(Color("Color"))
            
                  
  
                        
                         
                                    
                                   }
            }
            
        }
        .refreshable {
            
         
            accesser.fetchCurrentEvents()
            bgColor = Color("Color")
        }

        
        .onReceive(NotificationCenter.default.publisher(for: .EKEventStoreChanged, object:  accesser.store)) {
            (output) in
            accesser.fetchCurrentEvents()
            accesser.updateCurrentEvents()
        }
       
     
    }
    
    
}


@available(iOS 16.1, *)
struct EventView: View {
    
    @State private var searchText = ""
    
    @EnvironmentObject var accesser :  CalenderAccesser
    
    @Binding var color: Color

   
    var body: some View {
        
        ForEach(Array(zip(accesser.events.indices, accesser.events)), id: \.0) { index, item in
            VStack {
               
                    HStack {
                        VStack  (alignment: .leading, spacing: 10){
                            Text( accesser.events[index].event.title)
                                .font(.system(.headline, design: .monospaced))
                            
                            VStack (alignment: .leading) {
                             
                                Text( accesser.events[index].event.location ?? "")
                        
                                    .font(.system(.footnote, design: .monospaced))
                                Text("From \(accesser.events[index].event.startDate.formatted(.dateTime.hour().minute())) to \(accesser.events[index].event.endDate.formatted(.dateTime.hour().minute()))")
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(color)
                                
                                
                                
                                Toggle (isOn: $accesser.events[index].active ) {
                                    
                                    if accesser.events[index].active {
                                        HStack {
                                            Text(accesser.events[index].event.startDate >= .now ? "Starting in"  : "Ending in" )
                                                .font(.system(.caption, design: .monospaced))
                                            Text(Activity<EventTrackerAttributes>.activities[0].contentState.eventTimer, style: .timer)
                                                .foregroundColor(color)
                                                .font(.system(.title3, design: .monospaced))
                                                .fontWeight(.bold)
                                            
                                        }
                                      
                                    } else {
                                        VStack (alignment: .leading){
                                            Text("Start a Live Activity for:")
                                            Text("\( accesser.events[index].event.title)")
                                                .foregroundColor(.white)
                                        }
                                        .font(.system(.caption, design: .monospaced))
                                       
                                        
                                    }
                                  
                                    
                                }
                                    .tint( color )
                                   
                                    .foregroundColor(.secondary)
                                    
                                    .onTapGesture
                                {
                                    
                                    for (index, _) in accesser.events.enumerated() {
                                       
                                            accesser.events[index].active = false
                                        

                                    }
                                    
                                    accesser.endAllActivities()
                                    
                                    if !accesser.events[index].active {
                                        accesser.startActivity(eventInfo: item);
                                        
                                        
                                        
                                    }
                                }
                            }
                        }
                        
                  
                        
                       
                        
                      
                       
                      
                        
                        
                        
                        
                    
                }}
         
            
        }
        
    
    
        
        
    }
    
    
    
}

