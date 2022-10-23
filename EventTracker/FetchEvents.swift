import UIKit
import ActivityKit
import EventKit
import EventKitUI





struct EventTrackerAttributes: ActivityAttributes {
    public typealias EventAttributesStatus = ContentState
    
    public struct ContentState: Codable, Hashable {
         
        var eventName: String
     }
    
    var startTime: Date
    var eventAddress: String
    var eventLocation: String
    var timerSize: Int
    var eventTimer: Date
    
    
}



@available(iOS 16.1, *)
class CalenderAccesser: NSObject, ObservableObject {
    
    var store: EKEventStore!
    
    @Published var events: [EventInfo] = []
    
    
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
        
        var calendar = Calendar.current
        let dateFrom = Date.now
        
        
        let startOfDay = calendar.startOfDay(for: Date.now) // Current date at 12:00 am
        
        var dateComponents = DateComponents()
        dateComponents.day = 1
        dateComponents.second = -1
        
        let endOfDay = calendar.date(byAdding: dateComponents, to: startOfDay)
        
    
        var predicate: NSPredicate? = nil
        
        if let end = endOfDay {
       
            predicate = self.store.predicateForEvents(withStart: dateFrom, end: end, calendars: nil)
        }
        
        var events: [EKEvent]? = nil
        if let aPredicate = predicate {
            events = self.store.events(matching: aPredicate)
        }
        return events
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
    func endActivity(event: String, activities: Activity<EventTrackerAttributes>) {
        
        
        
        let activityToEnd = EventTrackerAttributes.EventAttributesStatus(eventName: event)
        
        Task {
            await activities.end(using: activityToEnd, dismissalPolicy: .immediate)
        }
        
        
    }
    
    func parseCollectedEvents(events: [EKEvent]) -> [EventInfo] {
        
        var eventNames: [EventInfo] = []
        for event in events {
        
            eventNames.append(EventInfo(eventName: event.title, startDate: event.startDate, location: event.structuredLocation?.title ?? "",
                                        address: event.location?.replacingOccurrences(of: (event.structuredLocation?.title ?? "`") + "\n" ?? "", with: "") ?? "" ,allDay: event.isAllDay))
        }
        
        
        return eventNames
        
    }
    
    func startActivity(name: String, startTime: Date, eventLocation: String, address: String) {
        let calendar = Calendar.current
      
    
        let currentTime = Date.now
 
        let secondsUntil = startTime.timeIntervalSince(currentTime)
    
        
        let event = EventTrackerAttributes(startTime: startTime, eventAddress: address, eventLocation: eventLocation, timerSize: Int(secondsUntil) , eventTimer: .now +  secondsUntil)
        let initialContentState =  EventTrackerAttributes.ContentState( eventName: name)
     
        

        do {
            let deliveryActivity = try Activity.request(
                attributes: event,
                contentState: initialContentState,
                pushType: nil)
            print("Requested a event Live Activity \(deliveryActivity.id)")
        } catch (let error) {
            print(error)
            print("Error requesting event Live Activity \(error.localizedDescription)")
        }
    }
    
  


}


struct EventInfo: Identifiable {
    
    var id = UUID()
    var eventName: String
    var startDate: Date
    var location: String
    var address: String
    var allDay: Bool
    
    
}
