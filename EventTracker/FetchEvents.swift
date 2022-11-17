import UIKit
import SwiftUI

import ActivityKit
import EventKit
import EventKitUI



struct EventInfo: Identifiable, Codable  {

    
    var id = UUID()
    
    var event: Event
    var active: Bool
    
  
    init(id: UUID = UUID(), event: Event, active: Bool) {
        self.id = id
        self.event = event
        self.active = active
    }
    

}

struct Event: Codable {
    
    var eventName: String
    var eventAddress: String
    var eventLocation: String
    var startDate: Date
    var endDate: Date;
    var eventIdentifier: String
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?

    
    
   
    
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
    
    func updateActivity(activity: Activity<EventTrackerAttributes>, event: Event) {
        
        Task {
            let alertConfiguration = AlertConfiguration(title: "Event Modification", body: "Event information has been updated.", sound: .default)
            
                    
           
                let currentTime = Date.now
                
                var secondsUntil = event.startDate.timeIntervalSince(currentTime)
                
    
                
                if currentTime >= event.startDate {
                secondsUntil = event.endDate.timeIntervalSince(currentTime)
                }
            
         
           
                
            let activityToUpdate = EventTrackerAttributes.EventAttributesStatus(eventName: event.eventName, eventAddress: event.eventAddress, eventLocation: event.eventLocation, startDate: event.startDate, endDate: event.endDate, timerSize: Int(secondsUntil) , eventTimer:  .now +  secondsUntil)
                
                await activity.update(using: activityToUpdate, alertConfiguration: alertConfiguration)
          
            
            
            
        }
        
        
    }
    
    func parseCollectedEvents(events: [EKEvent]) -> [EventInfo] {
        
        var eventsFetched: [EventInfo] = []
        
        for event in events {
          
          
            if event.isAllDay == false {
           
               
                var address = event.location?.replacingOccurrences(of: (event.structuredLocation?.title ?? "") , with: "") ?? ""
                address = address.replacingOccurrences(of: "\n", with: "")
                
             
                
                
                let event = Event(eventName: event.title, eventAddress: address, eventLocation: event.structuredLocation?.title ?? "", startDate:  event.startDate, endDate:  event.endDate, eventIdentifier: event.eventIdentifier, latitude: event.structuredLocation?.geoLocation?.coordinate.latitude, longitude: event.structuredLocation?.geoLocation?.coordinate.longitude )
                
                let active = Activity<EventTrackerAttributes>.activities.contains(where: {$0.attributes.eventID == event.eventIdentifier})
                
                eventsFetched.append(EventInfo(event: event, active: active))
            }
                
            
         
                              
        }
       
        
        
        return eventsFetched
        
    }
    
    func startActivity(eventInfo: EventInfo) {
        let currentTime = Date.now
        
        var secondsUntil = eventInfo.event.startDate.timeIntervalSince(currentTime)
        
       
        
        let eventAttributes = EventTrackerAttributes(eventID: eventInfo.event.eventIdentifier)
        
 
        if currentTime >= eventInfo.event.startDate {
            secondsUntil = eventInfo.event.endDate.timeIntervalSince(currentTime)
        }
 
        let initialContentState =  EventTrackerAttributes.ContentState( eventName: eventInfo.event.eventName, eventAddress: eventInfo.event.eventAddress, eventLocation:  eventInfo.event.eventLocation, startDate: eventInfo.event.startDate, endDate: eventInfo.event.endDate, timerSize:  Int(secondsUntil) , eventTimer: .now +  secondsUntil)
        
        
        
        do {
            let eventActivity = try Activity.request(
                attributes: eventAttributes,
                contentState: initialContentState,
                pushType: nil)
            print("Requested a event Live Activity \(eventActivity.id)")
        } catch (let error) {
           
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
    
    
    private static func fileURL() throws -> URL {
         try FileManager.default.url(for: .documentDirectory,
                                        in: .userDomainMask,
                                        appropriateFor: nil,
                                        create: false)
         .appendingPathComponent("events.data", conformingTo: .data)
            
 
     }
    
    static func load(completion: @escaping (Result<[EventInfo], Error>)->Void) {
            DispatchQueue.global(qos: .background).async {
                do {
                    let fileURL = try fileURL()
                    guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                        DispatchQueue.main.async {
                            completion(.success([]))
                        }
                        return
                    }
                    let events = try JSONDecoder().decode([EventInfo].self, from: file.availableData)
                    DispatchQueue.main.async {
                        completion(.success(events))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }
    
    static func save(events: [EventInfo], completion: @escaping (Result<Int, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(events)
                let outfile = try fileURL()
                try data.write(to: outfile)
                DispatchQueue.main.async {
                    completion(.success(events.count))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
}


