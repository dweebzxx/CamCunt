//
//  UCDevice.swift
//  CamCunt
//
//  Created by Itay Brenner on 7/19/20.
//  Copyright © 2025 dweebzxx. All rights reserved.
//  Originally CameraController by Itay Brenner
//

import Foundation
import AVFoundation

typealias USBInterfacePointer = UnsafeMutablePointer<UnsafeMutablePointer<IOUSBInterfaceInterface190>>

class UVCDevice {
    let interface: USBInterfacePointer
    let processingUnitID: Int
    let cameraTerminalID: Int
    let properties: UVCDeviceProperties

    init(device: AVCaptureDevice) throws {
        let deviceInfo = try device.usbDevice()

        interface = deviceInfo.interface
        processingUnitID = deviceInfo.descriptor.processingUnitID
        cameraTerminalID = deviceInfo.descriptor.cameraTerminalID
        properties = UVCDeviceProperties(deviceInfo)
    }

    deinit { _ = interface.pointee.pointee.Release(interface) }
}
