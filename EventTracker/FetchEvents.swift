import UIKit
import ActivityKit
import EventKit
import EventKitUI



@available(iOS 16.1, *)
class CalenderAccesser: NSObject {
    
    var store: EKEventStore!
    
    var eventNames: [String] = []
    
    
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
        let dateFrom = calendar.startOfDay(for: Date())
        let dateTo = calendar.date(byAdding: .day, value: 1, to: dateFrom)

        var predicate: NSPredicate? = nil
        
        if let end = dateTo {
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
            eventNames = parseCollectedEvents(events: existedEvents)
        }
        
    }
    
    
    func parseCollectedEvents(events: [EKEvent]) -> [String] {
        
        var eventNames: [String] = []
        for event in events {
            eventNames.append(event.title)
        }
        
        
        return eventNames
        
    }
    
    func startActivity() {
        let event = EventAttributes(eventName: "Event")

        var calendar = Calendar.current
        let dateFrom = calendar.startOfDay(for: Date())
        let dateTo = calendar.date(byAdding: .day, value: 1, to: dateFrom) ?? Date()
        
        let date = dateFrom...dateTo
        let initialContentState =  EventAttributes.ContentState(eventLocation: "TIM 👨🏻‍🍳", eventTimer: date)

        do {
            let deliveryActivity = try Activity<EventAttributes>.request(
                attributes: event,
                contentState: initialContentState,
                pushType: nil)
            print("Requested a pizza delivery Live Activity \(deliveryActivity.id)")
        } catch (let error) {
            print("Error requesting pizza delivery Live Activity \(error.localizedDescription)")
        }
    }


}


