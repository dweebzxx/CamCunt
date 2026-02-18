//
//  DeviceSettings.swift
//  CamCunt
//
//  Created by Itay Brenner on 8/7/20.
//  Copyright © 2025 dweebzxx. All rights reserved.
//  Originally CameraController by Itay Brenner
//

import Foundation

struct DeviceSettings: Codable {
    let exposureMode: Int
    let exposureTime: Float
    let gain: Float
    let brightness: Float
    let contrast: Float
    let saturation: Float
    let sharpness: Float
    let whiteBalanceAuto: Bool
    let whiteBalance: Float
    let powerline: Float
    let backlightCompensation: Float
    let zoom: Float
    let pan: Float
    let tilt: Float
    let focusAuto: Bool
    let focus: Float
}
