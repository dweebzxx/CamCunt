//
//  USBDevice.swift
//  CamCunt
//
//  Created by Itay Brenner on 7/19/20.
//  Copyright © 2025 dweebzxx. All rights reserved.
//  Originally CameraController by Itay Brenner
//

import Foundation
import IOKit.usb

struct USBDevice {
    let interface: UnsafeMutablePointer<UnsafeMutablePointer<IOUSBInterfaceInterface190>>
    let descriptor: UVCDescriptor
}
