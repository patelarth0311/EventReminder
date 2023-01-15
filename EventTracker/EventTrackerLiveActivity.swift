//
//  EventTrackerLiveActivity.swift
//  EventTracker
//
//  Created by Arth Patel on 10/16/22.
//

import ActivityKit
import WidgetKit
import SwiftUI
import EventKit
import _MapKit_SwiftUI



struct EventTrackerLiveActivity: Widget {
    
    @State var now = Date()
    
    let eventStore = EKEventStore()
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: EventTrackerAttributes.self) { context in
            
            LockScreenView(context: context)
            
        } dynamicIsland: { context in
            
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading, priority: 1) {
                 
                        HStack {
                            Image(systemName: context.state.startDate > .now ? "calendar" : "calendar.badge.clock")
                                .foregroundColor(Color("Color"))
                                .font(.system(.title2, design: .monospaced))
                                
                        }
                }
                
                DynamicIslandExpandedRegion(.trailing,  priority: 1) {
                    VStack {
                        Text(context.state.eventTimer, style: .timer)
                            .multilineTextAlignment(.center)
                            .font(.system(.title2, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(Color("Color"))
                    }
                    
                }
                
                DynamicIslandExpandedRegion(.bottom, priority: 1) {
                    VStack (alignment: .center, spacing: 3){
                       
                        Text("\(context.state.eventName)")
                            .font(.system(.subheadline, design: .monospaced))
                            .fontWeight(.bold)
                        
                       
                            .foregroundColor(.white)
                        
                        
                       Spacer()
                        VStack (alignment: .leading){
                            
                            if (!context.state.eventLocation.isEmpty) {
                                Text("\(context.state.eventLocation)")
                                    .font(.system(.footnote, design: .monospaced))
                                
                            }
                            if (!context.state.eventAddress.isEmpty) {
                                Text("\(context.state.eventAddress)")
                                    .font(.system(.footnote, design: .monospaced))
                            }
                            Text( context.state.startDate > .now ? "Today \(context.state.startDate.formatted(.dateTime.weekday().day().month().hour().minute())) until \(context.state.endDate.formatted(.dateTime.hour().minute()))" : "Ends at \(context.state.endDate.formatted(.dateTime.hour().minute()))" )
                            
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(Color("Color"))
                        }
                        .foregroundColor(.secondary)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    
                }
                
                DynamicIslandExpandedRegion(.center,  priority: 1) {
                    
                }
            } compactLeading: {
                
                Image(systemName: context.state.startDate > .now ? "calendar" : "calendar.badge.clock")
                    .foregroundColor(Color("Color"))
                    .font(.system(.title2, design: .monospaced))
            } compactTrailing: {
                Text(context.state.eventTimer, style: .timer)
                    .multilineTextAlignment(.center)
                    .font(.system(.subheadline, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundColor(Color("Color"))
                    .frame(width: context.state.timerSize <= 3599 ? 51 : context.state.timerSize < 36000 ? 66 : 79)
            } minimal: {
                
                Image(systemName: context.state.startDate > .now ? "calendar" : "calendar.badge.clock")
                    .foregroundColor(Color("Color"))
                    .font(.system(.title2, design: .monospaced))
            }
            .keylineTint(Color("Color"))
            
        }
        
        
    }
    
}


struct LockScreenView: View {
    var context: ActivityViewContext<EventTrackerAttributes>
    var body: some View {
        VStack  (alignment: .leading, spacing: 10){
            HStack {
                Image(systemName: context.state.startDate > .now ? "calendar" : "calendar.badge.clock")
                    .foregroundColor(Color("Color"))
                    .font(.system(.title, design: .monospaced))
                Spacer()
                Text(context.state.eventTimer, style: .timer)
                    .multilineTextAlignment(.trailing)
                    .font(.system(.title, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundColor(Color("Color"))
            }
            
            VStack (alignment: .leading, spacing: 5){
               
                Text("\(context.state.eventName)")
                    .font(.system(.subheadline, design: .monospaced))
                    .fontWeight(.bold)
                Spacer()
                VStack(alignment: .leading)  {
                    
                    if (!context.state.eventLocation.isEmpty) {
                        Text("\(context.state.eventLocation)")
                            .font(.system(.footnote, design: .monospaced))
                        
                    }
                    if (!context.state.eventAddress.isEmpty) {
                        Text("\(context.state.eventAddress)")
                            .font(.system(.footnote, design: .monospaced))
                        
                    }
                    Text( context.state.startDate > .now ? "Today \(context.state.startDate.formatted(.dateTime.weekday().day().month().hour().minute())) until \(context.state.endDate.formatted(.dateTime.hour().minute()))" : "Ends at \(context.state.endDate.formatted(.dateTime.hour().minute()))" )
                        .multilineTextAlignment(.leading)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(Color("Color"))
                    Spacer()
                       
                }
                .foregroundColor(.secondary)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        
        
        
    }
    
    
    
}
