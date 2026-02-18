//
//  UserSettings.swift
//  CamCunt
//
//  Created by Itay Brenner on 7/25/20.
//  Copyright © 2025 dweebzxx. All rights reserved.
//  Originally CameraController by Itay Brenner
//

import Foundation
import Combine
import ServiceManagement

class UserSettings: ObservableObject {
    static let shared = UserSettings()

    @Published var openAtLogin: Bool {
        didSet {
            if #available(macOS 13.0, *) {
                do {
                    if openAtLogin {
                        try SMAppService.mainApp.register()
                    } else {
                        try SMAppService.mainApp.unregister()
                    }
                    UserDefaults.standard.set(openAtLogin, forKey: "login")
                } catch {
                    print("Failed to \(openAtLogin ? "enable" : "disable") login item: \(error)")
                }
            } else {
                let success = SMLoginItemSetEnabled("com.dweebzxx.CamCunt.Helper" as CFString, openAtLogin)
                if success {
                    UserDefaults.standard.set(openAtLogin, forKey: "login")
                }
            }
        }
    }

    @Published var readRate: RefreshSettingsRate {
        didSet {
            UserDefaults.standard.set(readRate.rawValue, forKey: "readRate")
        }
    }

    @Published var writeRate: RefreshSettingsRate {
        didSet {
            UserDefaults.standard.set(writeRate.rawValue, forKey: "writeRate")
        }
    }

    @Published var lastSelectedDevice: String? {
        didSet {
            UserDefaults.standard.set(lastSelectedDevice, forKey: "lastDevice")
        }
    }

    private init() {
        openAtLogin = UserDefaults.standard.bool(forKey: "login")
        readRate = RefreshSettingsRate(rawValue: UserDefaults.standard.double(forKey: "readRate")) ?? .disabled
        writeRate = RefreshSettingsRate(rawValue: UserDefaults.standard.double(forKey: "writeRate")) ?? .disabled
        lastSelectedDevice = UserDefaults.standard.string(forKey: "lastDevice")
    }
}
