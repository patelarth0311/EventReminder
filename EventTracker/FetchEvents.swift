import UIKit
import SwiftUI

import ActivityKit
import EventKit
import EventKitUI



struct EventInfo: Identifiable,  Hashable  {

    var id = UUID()
    
    var event: EKEvent
    var active: Bool
  
    
    
    
}



struct EventTrackerAttributes: ActivityAttributes {
    public typealias EventAttributesStatus = ContentState
    
    public struct ContentState: Codable, Hashable {
        
        var eventName: String
        var eventAddress: String
        var eventLocation: String
        var startDate: Date
        var endDate: Date;
        var timerSize: Int
        var eventTimer: Date

        
  
    }
    
    var eventID : String
  
 
   
    
    
}



@available(iOS 16.1, *)
class CalenderAccesser: NSObject, ObservableObject {
    
    var store: EKEventStore!
    
    @Published var events: [EventInfo] = []
    
    @Published var kEvents: [EKEvent] = []
    
 

    
    override init() {
        store  = EKEventStore()
    }
    
    
    private func getAuthorizationStatus() -> EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: EKEntityType.event)
    }
    
    
    private func request(completion: @escaping EKEventStoreRequestAccessCompletionHandler) {
        store.requestAccess(to: EKEntityType.event) { (accessGranted, error) in
            completion(accessGranted, error)
        }
    }
    
    func findCurrentEvents(name: String) -> [EKEvent]? {
        
        let calendar = Calendar.current
        _ = Date.now
        
        
        let startOfDay = calendar.startOfDay(for: Date.now) // Current date at 12:00 am
        
        var dateComponents = DateComponents()
        dateComponents.day = 1
        dateComponents.second = -1
        
        let endOfDay = calendar.date(byAdding: dateComponents, to: startOfDay)
        
        
        var predicate: NSPredicate? = nil
        
        if let end = endOfDay {
            
            predicate = self.store.predicateForEvents(withStart: Date.now , end: end, calendars: nil)
        }
        
        if let aPredicate = predicate {
            kEvents = self.store.events(matching: aPredicate)
        }
        return kEvents
    }
    
    
    
    func fetchCurrentEvents() {
        let authStatus = getAuthorizationStatus()
        var events: [EKEvent]?
        switch authStatus {
        case .notDetermined:
            store.requestAccess(to: EKEntityType.event) { (_, _) in
                events = self.findCurrentEvents(name: "Calender")
            }
        case .authorized:
            events = self.findCurrentEvents(name: "Calender")!
        case .denied: print("Access denied")
        default: break
        }
        
        if let existedEvents = events {
            self.events = parseCollectedEvents(events: existedEvents)
            
        }
        
    }
    
    
    
    @available(iOS 16.1, *)
    func endActivity(activities: Activity<EventTrackerAttributes>) {
        
        Task {
            await activities.end(dismissalPolicy: .immediate)
        }
        
        
    }
    
    func endAllActivities() {
        for activity in Activity<EventTrackerAttributes>.activities {
            endActivity( activities: activity)
        }
    }
    
    func updateActivity(activity: Activity<EventTrackerAttributes>, event: EKEvent) {
        
        Task {
            let alertConfiguration = AlertConfiguration(title: "Event Modification", body: "Event information has been updated.", sound: .default)
            
                    
           
                let currentTime = Date.now
                
                var secondsUntil = event.startDate.timeIntervalSince(currentTime)
                
                var address = event.location?.replacingOccurrences(of: (event.structuredLocation?.title ?? "") + "\n" , with: "") ?? ""
                address = address.replacingOccurrences(of: "\n", with: "")
                
                if currentTime >= event.startDate {
                secondsUntil = event.endDate.timeIntervalSince(currentTime)
                }
            
         
           
                
                let activityToUpdate = EventTrackerAttributes.EventAttributesStatus(eventName: event.title, eventAddress: address, eventLocation: event.structuredLocation?.title ?? "", startDate: event.startDate, endDate: event.endDate, timerSize: event.isAllDay ? -1 * Int(secondsUntil) : Int(secondsUntil) , eventTimer:  .now +  secondsUntil)
                
                await activity.update(using: activityToUpdate, alertConfiguration: alertConfiguration)
          
            
            
            
        }
        
        
    }
    
    func parseCollectedEvents(events: [EKEvent]) -> [EventInfo] {
        
        var eventsFetched: [EventInfo] = []
        
        for event in events {
          
           
            if event.isAllDay == false {
           
               
                let active = Activity<EventTrackerAttributes>.activities.contains(where: {$0.attributes.eventID == event.eventIdentifier})
                
                eventsFetched.append(EventInfo(event: event, active: active))
            }
                
            
         
                              
        }
        
        
        
        return eventsFetched
        
    }
    
    func startActivity(eventInfo: EventInfo) {
        let currentTime = Date.now
        
        var secondsUntil = eventInfo.event.startDate.timeIntervalSince(currentTime)
        
        var address = eventInfo.event.location?.replacingOccurrences(of: (eventInfo.event.structuredLocation?.title ?? "")  , with: "") ?? ""
        address = address.replacingOccurrences(of: "\n", with: "")

       
        
        let eventAttributes = EventTrackerAttributes(eventID: eventInfo.event.eventIdentifier)
        
 
        if currentTime >= eventInfo.event.startDate {
            secondsUntil = eventInfo.event.endDate.timeIntervalSince(currentTime)
        }
 
        print(secondsUntil)
        let initialContentState =  EventTrackerAttributes.ContentState( eventName: eventInfo.event.title,eventAddress: address, eventLocation:  eventInfo.event.structuredLocation?.title ?? "", startDate: eventInfo.event.startDate, endDate: eventInfo.event.endDate, timerSize: eventInfo.event.isAllDay ? -1 * Int(secondsUntil) : Int(secondsUntil) , eventTimer: .now +  secondsUntil)
        
        
        
        do {
            let deliveryActivity = try Activity.request(
                attributes: eventAttributes,
                contentState: initialContentState,
                pushType: nil)
            print("Requested a event Live Activity \(deliveryActivity.id)")
        } catch (let error) {
            print(error)
            print("Error requesting event Live Activity \(error.localizedDescription)")
        }
    }
    

    func updateCurrentEvents() -> Bool {
        
        
        if (Activity<EventTrackerAttributes>.activities.count == 1) {
            let couldExist = events.firstIndex(where: {$0.event.eventIdentifier == Activity<EventTrackerAttributes>.activities[0].attributes.eventID})
            
            if let exist = couldExist {
                if (events[exist].event.endDate > .now) {
                    updateActivity(activity: Activity<EventTrackerAttributes>.activities[0], event: events[exist].event)
                    events[exist].active = true;
                } else {
                    endActivity(activities: Activity<EventTrackerAttributes>.activities[0])
                   
                }
            } else {
                endActivity(activities: Activity<EventTrackerAttributes>.activities[0])
            }
            
        }
       
        
        return true
    }
    
    
}


