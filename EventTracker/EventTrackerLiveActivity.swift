//
//  EventTrackerLiveActivity.swift
//  EventTracker
//
//  Created by Arth Patel on 10/16/22.
//

import ActivityKit
import WidgetKit
import SwiftUI



struct EventTrackerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: EventTrackerAttributes.self) { context in
       
            LockScreenView(context: context)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    VStack  (spacing: 5){
                        
                        HStack {
                            
                            Image(systemName: "calendar")
                                .foregroundColor(.yellow)
                                .font(.system(.title2, design: .rounded))
                         
                    
                           
                        }
                        
            
                    }
                   
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack {
                        Text(context.attributes.eventTimer, style: .timer)
                            .multilineTextAlignment(.center)
                            .font(.system(.title2, design: .rounded))
                            .monospacedDigit()
                            .foregroundColor(.yellow)
                        
                        
                    
                    }
                }
                DynamicIslandExpandedRegion(.bottom, priority: 1) {
                    VStack (alignment: .center){
               
                         
                        Text("\(context.state.eventName)")
                            .font(.system(.headline, design: .rounded))
                            .multilineTextAlignment(.center)
                            .offset(y:-10)
                          
                           
                        Text("\(context.attributes.eventLocation)")
                            .font(.system(.subheadline, design: .rounded))
                            .fixedSize(horizontal: true, vertical: false)
                           
                        Text("\(context.attributes.eventAddress)")
                            .font(.system(.subheadline, design: .rounded))
                            .fixedSize(horizontal: true, vertical: false)
                        Text(context.attributes.startTime.formatted(.dateTime.weekday().day().month().hour().minute()))
                            .multilineTextAlignment(.leading)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.secondary)
                    
            
                    
                    }
                  

      
                    
              

                    
                   
             
                    
                   
                    

                }
                
                DynamicIslandExpandedRegion(.center) {
                  
                 

                       
                }
              
                
                
            
            } compactLeading: {
               
                    Image(systemName: "calendar")
                    .foregroundColor(.yellow)
                        .font(.system(.title2, design: .rounded))
                   
   
                
                    
            } compactTrailing: {
                Text(context.attributes.eventTimer, style: .timer)
                    .multilineTextAlignment(.center)
                    .monospacedDigit()
                    .font(.system(.callout, design: .rounded))
                    .foregroundColor(.yellow)
                    .frame(width: context.attributes.timerSize <= 3599 ? 51 : 70)
            } minimal: {
            
                Image(systemName: "clock")
                    .foregroundColor(.yellow)
                    .font(.system(.title2, design: .rounded))
            }
        
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.yellow)
        }
        
    }
}

struct LockScreenView: View {
    var context: ActivityViewContext<EventTrackerAttributes>
    
    var body: some View {
        
        VStack  (alignment: .leading, spacing: 10){
      
                HStack {
           
                        Image(systemName: "calendar")
                            .foregroundColor(.yellow)
                            .font(.system(.title2, design: .rounded))
                    
                   
                 
                    Spacer()
                        Text(context.attributes.eventTimer, style: .timer)
                            .multilineTextAlignment(.trailing)
                            .font(.system(.title3, design: .rounded))
                            .monospacedDigit()
                            .foregroundColor(.yellow)
                           
                   
                }
            
            
            VStack (alignment: .leading){
            Text("\(context.state.eventName)")
                .font(.system(.headline, design: .rounded))
                .multilineTextAlignment(.leading)
                .offset(y:-5)

                Text("\(context.attributes.eventLocation)")
                    .font(.system(.subheadline, design: .rounded))
                    .fixedSize(horizontal: true, vertical: false)
                Text("\(context.attributes.eventAddress)")
                    .font(.system(.subheadline, design: .rounded))
                    .fixedSize(horizontal: true, vertical: false)
                
                Text(context.attributes.startTime.formatted(.dateTime.weekday().day().month().hour().minute()))
                    .multilineTextAlignment(.leading)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.secondary)
            
            }
           

        
                
       
        
            
            
               }
        .padding()
        
        
    }

    
    
}
