//
//  VideoFactoryApp.swift
//  VideoFactory
//
//  Created by Jie Chen on 2024/11/29.
//

import SwiftUI

@main
struct VideoFactoryApp: App {
    var body: some Scene {
        WindowGroup {
            MainWindowView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 1280, height: 720)
    }
}
