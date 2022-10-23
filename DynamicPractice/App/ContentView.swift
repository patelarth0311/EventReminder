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
    
    var idk =  CalenderAccesser()
    
    
    var body: some View {
        VStack {
            
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        Button {
           
            idk.startActivity()
            
        } label: {
            VStack {
                Text("Click Me")
            }
            .foregroundColor(.green)
            .padding()
            
            
            
        }
        .padding()
    }
}



