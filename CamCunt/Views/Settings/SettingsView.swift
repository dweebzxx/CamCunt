//
//  AVCaptureDevice+USB.swift
//  CamCunt
//
//  Created by Itay Brenner on 7/19/20.
//  Copyright © 2025 dweebzxx. All rights reserved.
//  Originally CameraController by Itay Brenner
//

import Foundation
import AVFoundation
import IOKit.usb

private let kIOUSBDeviceUserClientTypeID: CFUUID = CFUUIDGetConstantUUIDWithBytes(kCFAllocatorDefault,
                                                                                  0x9d, 0xc7, 0xb7, 0x80,
                                                                                  0x9e, 0xc0, 0x11, 0xD4,
                                                                                  0xa5, 0x4f, 0x00, 0x0a,
                                                                                  0x27, 0x05, 0x28, 0x61)
private let kIOUSBDeviceInterfaceID: CFUUID =  CFUUIDGetConstantUUIDWithBytes(kCFAllocatorDefault,
                                                                              0x5c, 0x81, 0x87, 0xd0,
                                                                              0x9e, 0xf3, 0x11, 0xD4,
                                                                              0x8b, 0x45, 0x00, 0x0a,
                                                                              0x27, 0x05, 0x28, 0x61)
private let kIOUSBInterfaceInterfaceID: CFUUID =  CFUUIDGetConstantUUIDWithBytes(kCFAllocatorDefault,
                                                                                 0x73, 0xc9, 0x7a, 0xe8,
                                                                                 0x9e, 0xf3, 0x11, 0xD4,
                                                                                 0xb1, 0xd0, 0x00, 0x0a,
                                                                                 0x27, 0x05, 0x28, 0x61)

typealias DeviceInterfacePointer = UnsafeMutablePointer<UnsafeMutablePointer<IOUSBDeviceInterface>>

extension AVCaptureDevice {

    private func getIOService() throws -> io_service_t {
        var camera: io_service_t = 0
        let cameraInformation = try self.modelID.extractCameraInformation()
        let dictionary: NSMutableDictionary = IOServiceMatching("IOUSBDevice") as NSMutableDictionary
        dictionary["idVendor"] = cameraInformation.vendorId
        dictionary["idProduct"] = cameraInformation.productId

        DebugLogger.shared.log("🔍 Looking for USB device: vendor=\(cameraInformation.vendorId), product=\(cameraInformation.productId)")
        DebugLogger.shared.log("   Device uniqueID: \(self.uniqueID)")

        var iter: io_iterator_t = 0
        // Use kIOMainPortDefault (modern) - falls back gracefully on older systems
        if IOServiceGetMatchingServices(kIOMainPortDefault, dictionary, &iter) == kIOReturnSuccess {
            var cameraCandidate: io_service_t
            cameraCandidate = IOIteratorNext(iter)
            while cameraCandidate != 0 {
                var propsRef: Unmanaged<CFMutableDictionary>?

                if IORegistryEntryCreateCFProperties(
                    cameraCandidate,
                    &propsRef,
                    kCFAllocatorDefault,
                    0) == kIOReturnSuccess {
                    var found: Bool = false
                    if let properties = propsRef?.takeRetainedValue() {
                        
                        // PRIMARY MATCH: Use locationID matching (same as original CameraController)
                        // uniqueID starts with hex version of locationID
                        if let locationID = (properties as NSDictionary)["locationID"] as? Int {
                            let locationIDHex = "0x" + String(locationID, radix: 16)
                            DebugLogger.shared.log("   Candidate locationID: \(locationIDHex)")
                            if self.uniqueID.hasPrefix(locationIDHex) {
                                camera = cameraCandidate
                                found = true
                                DebugLogger.shared.log("   ✅ Matched by locationID!")
                            }
                        }
                        
                        // FALLBACK MATCH: Try name-based matching if locationID didn't work
                        if !found {
                            let keysToTry: [String] = [
                                "kUSBProductString",
                                "kUSBVendorString",
                                "USB Product Name",
                                "USB Vendor Name"
                            ]
                            
                            for key in keysToTry {
                                if let cameraName = (properties as NSDictionary)[key] as? String {
                                    if cameraName == self.localizedName {
                                        camera = cameraCandidate
                                        found = true
                                        DebugLogger.shared.log("   ✅ Matched by name (\(key))!")
                                        break
                                    }
                                }
                            }
                        }
                        
                        if found {
                            break
                        }
                    }
                }
                cameraCandidate = IOIteratorNext(iter)
            }
            IOObjectRelease(iter)
        } else {
            DebugLogger.shared.log("   ❌ IOServiceGetMatchingServices failed")
        }

        // Fallback on GetMatchingService method
        if camera == 0 {
            DebugLogger.shared.log("   ⚠️ No match found via iterator, trying IOServiceGetMatchingService fallback")
            // Need to recreate dictionary as it was consumed
            let fallbackDict: NSMutableDictionary = IOServiceMatching("IOUSBDevice") as NSMutableDictionary
            fallbackDict["idVendor"] = cameraInformation.vendorId
            fallbackDict["idProduct"] = cameraInformation.productId
            camera = IOServiceGetMatchingService(kIOMainPortDefault, fallbackDict)
            if camera != 0 {
                DebugLogger.shared.log("   ✅ Fallback found a device")
            }
        }

        if camera == 0 {
            DebugLogger.shared.log("   ❌ No USB device found!")
            throw NSError(domain: #function, code: #line, userInfo: ["reason": "No matching USB device found"])
        }
        
        DebugLogger.shared.log("   ✅ Found USB device: \(camera)")
        return camera
    }

    func usbDevice() throws -> USBDevice {

        let camera = try self.getIOService()
        defer {
            let code: kern_return_t = IOObjectRelease(camera)
            assert( code == kIOReturnSuccess )
        }
        var interfaceRef: UnsafeMutablePointer<UnsafeMutablePointer<IOUSBInterfaceInterface190>>?
        var configDesc: IOUSBConfigurationDescriptorPtr?
        
        DebugLogger.shared.log("🔌 Creating plugin interface for USB device...")
        
        try camera.ioCreatePluginInterfaceFor(service: kIOUSBDeviceUserClientTypeID) {
            let deviceInterface: DeviceInterfacePointer = try $0.getInterface(uuid: kIOUSBDeviceInterfaceID)
            defer { _ = deviceInterface.pointee.pointee.Release(deviceInterface) }
            
            DebugLogger.shared.log("   Got device interface, looking for UVC video control interface...")
            
            let interfaceRequest = IOUSBFindInterfaceRequest(bInterfaceClass: UVCConstants.classVideo,
                                                             bInterfaceSubClass: UVCConstants.subclassVideoControl,
                                                             bInterfaceProtocol: UInt16(kIOUSBFindInterfaceDontCare),
                                                             bAlternateSetting: UInt16(kIOUSBFindInterfaceDontCare))
            try deviceInterface.iterate(interfaceRequest: interfaceRequest) {
                interfaceRef = try $0.getInterface(uuid: kIOUSBInterfaceInterfaceID)
                DebugLogger.shared.log("   ✅ Got UVC interface reference")
            }

            var returnCode: Int32 = 0
            var numConfig: UInt8 = 0
            returnCode = deviceInterface.pointee.pointee.GetNumberOfConfigurations(deviceInterface, &numConfig)
            if returnCode != kIOReturnSuccess {
                DebugLogger.shared.log("   ❌ Unable to get number of configurations (code: \(returnCode))")
                print("unable to get number of configurations")
                return
            }
            DebugLogger.shared.log("   Number of configurations: \(numConfig)")

            returnCode = deviceInterface.pointee.pointee.GetConfigurationDescriptorPtr(deviceInterface, 0, &configDesc)
            if returnCode != kIOReturnSuccess {
                DebugLogger.shared.log("   ❌ Unable to get config descriptor (code: \(returnCode))")
                print("unable to get config description for config 0 (index)")
                return
            }
            DebugLogger.shared.log("   ✅ Got configuration descriptor")
        }
        
        guard interfaceRef != nil else {
            DebugLogger.shared.log("❌ interfaceRef is nil - UVC interface not found")
            throw NSError(domain: #function, code: #line, userInfo: ["reason": "UVC interface not found"])
        }

        let descriptor = configDesc!.proccessDescriptor()
        DebugLogger.shared.log("✅ USB device ready - processingUnitID: \(descriptor.processingUnitID), cameraTerminalID: \(descriptor.cameraTerminalID)")

        return USBDevice(interface: interfaceRef.unsafelyUnwrapped,
                         descriptor: descriptor)
    }
}
