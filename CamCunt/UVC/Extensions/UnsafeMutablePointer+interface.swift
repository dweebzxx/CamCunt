//
//  UnsafeMutablePointer+interface.swift
//  CamCunt
//
//  Created by Itay Brenner on 7/20/20.
//  Copyright © 2025 dweebzxx. All rights reserved.
//  Originally CameraController by Itay Brenner
//

import Foundation

extension UnsafeMutablePointer where Pointee == UnsafeMutablePointer<IOCFPlugInInterface> {
    func getInterface<T>(uuid: CFUUID) throws -> UnsafeMutablePointer<T> {
        var ref: LPVOID?
        guard pointee.pointee.QueryInterface(self, CFUUIDGetUUIDBytes(uuid), &ref) == kIOReturnSuccess,
            let result: UnsafeMutablePointer<T> = ref?.assumingMemoryBound(to: T.self) else {
                throw NSError(domain: #function, code: #line, userInfo: nil)
        }

        return result
    }
}

extension UnsafeMutablePointer where Pointee == UnsafeMutablePointer<IOUSBDeviceInterface> {
    func iterate(interfaceRequest: IOUSBFindInterfaceRequest,
                 handle: (UnsafeMutablePointer<UnsafeMutablePointer<IOCFPlugInInterface>>) throws -> Void) rethrows {
        var iterator: io_iterator_t = 0
        // CRITICAL FIX: Use withUnsafeMutablePointer to ensure the request stays in memory
        var mutableRequest = interfaceRequest
        try withUnsafeMutablePointer(to: &mutableRequest) { mutatingPointer in
            guard pointee.pointee.CreateInterfaceIterator(self, mutatingPointer, &iterator) == kIOReturnSuccess else {
                DebugLogger.shared.log("   ❌ CreateInterfaceIterator failed")
                return
            }
            DebugLogger.shared.log("   ✅ CreateInterfaceIterator succeeded, iterator=\(iterator)")
            
            defer {
                let code: kern_return_t = IOObjectRelease(iterator)
                assert( code == kIOReturnSuccess )
            }
            
            var interfaceCount = 0
            while true {
                let object: io_service_t = IOIteratorNext(iterator)
                defer {
                    let code: kern_return_t = IOObjectRelease(object)
                    assert( code == kIOReturnSuccess )
                }
                guard 0 < object else {
                    DebugLogger.shared.log("   📋 Iterator exhausted after \(interfaceCount) interfaces")
                    break
                }
                interfaceCount += 1
                DebugLogger.shared.log("   🔍 Found interface #\(interfaceCount): service=\(object)")
                
                try object.ioCreatePluginInterfaceFor(service: kIOUSBInterfaceUserClientTypeID,
                                                      handle: handle)
            }
            
            if interfaceCount == 0 {
                DebugLogger.shared.log("   ⚠️ No interfaces found in iterator!")
            }
        }
    }
}

private let kIOUSBInterfaceUserClientTypeID: CFUUID = CFUUIDGetConstantUUIDWithBytes(kCFAllocatorDefault,
                                                                                     0x2d, 0x97, 0x86, 0xc6,
                                                                                     0x9e, 0xf3, 0x11, 0xD4,
                                                                                     0xad, 0x51, 0x00, 0x0a,
                                                                                     0x27, 0x05, 0x28, 0x61)
