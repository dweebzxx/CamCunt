//
//  AppDelegate.swift
//  CamCunt
//
//  Created by Itay Brenner on 7/25/20.
//  Copyright © 2025 dweebzxx. All rights reserved.
//  Originally CameraController by Itay Brenner (itaybre)
//

import Cocoa
import SwiftUI

enum HelperConstants {
    static let BundleIdentifier = "com.dweebzxx.CamCunt"
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = runningApps.contains {
            $0.bundleIdentifier == HelperConstants.BundleIdentifier
        }

        if !isRunning {
            var path = Bundle.main.bundlePath as NSString
            for _ in 1...4 {
                path = path.deletingLastPathComponent as NSString
            }
            NSWorkspace.shared.launchApplication(path as String)
        }
    }
}
