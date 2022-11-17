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

import MapKit

@available(iOS 16.1, *)
struct ContentView: View {
    
    @State private var searchText = ""

    @EnvironmentObject var accesser: CalenderAccesser
    

    
    var body: some View {
        
       
            NavigationView {
                
                List {
                    Section{
                        EventView()
                            .environmentObject(accesser)
                            
                        
                        
                    } header: {
                        Text("\(Date.now.formatted(date: .complete, time: .omitted))")
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
            .environmentObject(accesser)
            
            .refreshable {
                
                
                accesser.fetchCurrentEvents()
                accesser.updateCurrentEvents()
                
                
            }
            
            
            .onReceive(NotificationCenter.default.publisher(for: .EKEventStoreChanged, object:  accesser.store)) {
                (output) in
                accesser.fetchCurrentEvents()
                accesser.updateCurrentEvents()
            }
            .onAppear {
                CalenderAccesser.load { result in
                    switch result {
                    case .success(let events):
                        print(events)
                    case .failure(let fail):
                        fatalError(fail.localizedDescription)
                    }
                }
            }
            
            
        
        
    }
      
    
    
}


@available(iOS 16.1, *)
struct EventView: View {
    
    @State private var searchText = ""
    
    @EnvironmentObject var accesser :  CalenderAccesser
    
    
    var body: some View {
       
            ForEach(Array(zip(accesser.events.indices, accesser.events)), id: \.0) { index, item in
            
                VStack {
                    
                    Spacer()
                    HStack {
                        VStack  (alignment: .leading, spacing: 10){
                            Text( accesser.events[index].event.eventName)
                                .font(.system(.headline, design: .monospaced))
                            
                            VStack (alignment: .leading) {
                                
                                Text( accesser.events[index].event.eventLocation)
                                
                                    .font(.system(.footnote, design: .monospaced))
                                
                                Text( accesser.events[index].event.eventAddress)
                                    .font(.system(.footnote, design: .monospaced))
                                Text("From \(accesser.events[index].event.startDate.formatted(.dateTime.hour().minute())) to \(accesser.events[index].event.endDate.formatted(.dateTime.hour().minute()))")
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(Color("Color"))
                                
                               
                                if let latitude = accesser.events[index].event.latitude,  let longitude = accesser.events[index].event.longitude {
                                    let markers = [IdentifiablePlace(lat: latitude, long: longitude)]
                                    
                                    
                                    
                                    let region: MKCoordinateRegion = MKCoordinateRegion(center:  CLLocationCoordinate2D(latitude: accesser.events[index].event.latitude!, longitude: accesser.events[index].event.longitude!), latitudinalMeters: 500, longitudinalMeters: 500)
                                    
                                    
                                  
                                    
                                    let check_url = URL(string: "maps://?q=\(accesser.events[index].event.eventLocation.filter { !$0.isWhitespace }+accesser.events[index].event.eventAddress.filter { !$0.isWhitespace })")
                                   
                                    EventLocationView(markers: markers, region: region, openMaps: {
                                        if let url = check_url {
                                           
                                            if UIApplication.shared.canOpenURL(url) {
                                                  UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                            }
                                        }
                                       
                                    })
                                    
                                        .frame(height:200)
                                    Spacer()
                                    
                                    
                                    
                                   
                                       
                                    
                                }
                                
                              
                                ToggleItem(  item: $accesser.events[index], index: index)
                                        .environmentObject(accesser)
                                    
                                
                                
                               
                                Spacer()
                                
                            }
                        }
                    }
                }
            
            
        }
            .environmentObject(accesser)
        }

        
    
    
        
        
    }


@available(iOS 16.1, *)
struct ToggleItem: View {
    
    @EnvironmentObject var accesser :  CalenderAccesser
    @Binding var item: EventInfo
    var index: Int

    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        
        VStack {
         
                Toggle (isOn: Binding (get: {item.active},
                                       set: { value in
                                           withAnimation {
                                               
                                           
                                               for (i, _) in accesser.events.enumerated() {
                                                   
                                                   if (i != index) {
                                                       accesser.events[i].active = false
                                                      
                                                   } else {
                                                       
                                                       if ( accesser.events[index].active) {
                                                           accesser.events[index].active = false
                                                       } else {
                                                           accesser.events[index].active = true
                                                       }
                                                       
                                                       
                                                      
                                                       
                                                   }
                                               }
                                               
                                           }
                                       }) ) {
                    
         if (item.active && Activity<EventTrackerAttributes>.activities.count > 0 ) {
                        HStack {
                            Text(item.event.startDate > .now ? "Starting in"  : "Ending in" )
                                .font(.system(.caption, design: .monospaced))
                     
                                Text(Activity<EventTrackerAttributes>.activities[0].contentState.eventTimer, style: .timer)
                                    .foregroundColor(Color("Color"))
                                    .font(.system(.title3, design: .monospaced))
                                    .fontWeight(.bold)
                                    
                                    
                            
                            
                                   
                            
                         
                            
                        }
                      
                    } else {
                        VStack (alignment: .leading){
                            Text("Start a Live Activity for:")
                            Text("\( item.event.eventName)")
                                .bold()
                               
                        }
                        .font(.system(.caption, design: .monospaced))
                       
                        
                    }
                  
                    
                }
                        
                    .tint(Color("Color") )
                   
                    .foregroundColor(.secondary)
                    
                    .onTapGesture
                {
                    
                    
                    accesser.endAllActivities()
                  
                    if !item.active{
                        accesser.startActivity(eventInfo: item);
                        
                    }
              
                  
                
                
            }
        }
       
    
        
        
    }
    
    
    
}


struct EventLocationView: View {
    
 
    var markers: [IdentifiablePlace]
    var region: MKCoordinateRegion
  
    let openMaps: ()->Void
  

    var body: some View {
        
        Map(coordinateRegion: .constant(region), showsUserLocation: true, userTrackingMode: .constant(.follow), annotationItems: markers) { marker in
           
            MapAnnotation(coordinate: marker.location) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.pink)
                    .tint(.white)
                    .font(.title2)
                    
                   
            }
            }
        
            .onTapGesture {
               openMaps()
            }
            
                .cornerRadius(10)

        
    }
}

struct IdentifiablePlace: Identifiable {
    let id: UUID
    let location: CLLocationCoordinate2D
    init(id: UUID = UUID(), lat: Double, long: Double) {
        self.id = id
        self.location = CLLocationCoordinate2D(
            latitude: lat,
            longitude: long)
    }
}

class EventLocation: ObservableObject {
    
    @Published var coordinates = [CLLocationCoordinate2D]()
    
    
}
