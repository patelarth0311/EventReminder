//
//  DynamicPracticeApp.swift
//  DynamicPractice
//
//  Created by Arth Patel on 10/16/22.
//

import SwiftUI

@main

struct DynamicPracticeApp: App {

    var body: some Scene {
        WindowGroup {
            if #available(iOS 16.1, *) {
                ContentView()
            } else {
                // Fallback on earlier versions
            }
        }
    }
}
