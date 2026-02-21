//
//  CaptureDevice.swift
//  CamCunt
//
//  Created by Itay Brenner on 7/21/20.
//  Copyright © 2025 dweebzxx. All rights reserved.
//  Originally CameraController by Itay Brenner
//

import Foundation
import AVFoundation
import Combine

class CaptureDevice: Hashable, ObservableObject {
    let name: String
    let avDevice: AVCaptureDevice?
    let uvcDevice: UVCDevice?
    var controller: DeviceController?
    private var cropCancellable: AnyCancellable?
    
    /// Diagnostic info captured during initialization
    var diagnosticLog: [String] = []

    init(avDevice: AVCaptureDevice) {
        self.avDevice = avDevice
        self.name = avDevice.localizedName
        
        // DIAGNOSTIC: Capture UVC initialization details
        diagnosticLog.append("[\(Date())] Initializing device: \(avDevice.localizedName)")
        diagnosticLog.append("  Model ID: \(avDevice.modelID)")
        diagnosticLog.append("  Unique ID: \(avDevice.uniqueID)")
        
        do {
            self.uvcDevice = try UVCDevice(device: avDevice)
            diagnosticLog.append("✅ UVC device created successfully")
            diagnosticLog.append("   Processing Unit ID: \(self.uvcDevice!.processingUnitID)")
            diagnosticLog.append("   Camera Terminal ID: \(self.uvcDevice!.cameraTerminalID)")
            print("✅ UVC device created for: \(avDevice.localizedName)")
            print("   Processing Unit ID: \(self.uvcDevice!.processingUnitID)")
            print("   Camera Terminal ID: \(self.uvcDevice!.cameraTerminalID)")
        } catch {
            self.uvcDevice = nil
            diagnosticLog.append("❌ UVC device creation FAILED")
            diagnosticLog.append("   Error: \(error)")
            diagnosticLog.append("   Error Domain: \((error as NSError).domain)")
            diagnosticLog.append("   Error Code: \((error as NSError).code)")
            print("❌ UVC device FAILED for: \(avDevice.localizedName)")
            print("   Error: \(error)")
        }
        
        self.controller = DeviceController(properties: uvcDevice?.properties)
        
        // DIAGNOSTIC: Check what controls are capable
        if let ctrl = controller {
            diagnosticLog.append("📊 Control capabilities:")
            
            let controls: [(String, NumberCaptureDeviceProperty)] = [
                ("brightness", ctrl.brightness),
                ("contrast", ctrl.contrast),
                ("saturation", ctrl.saturation),
                ("sharpness", ctrl.sharpness),
                ("exposureTime", ctrl.exposureTime),
                ("gain", ctrl.gain),
                ("whiteBalance", ctrl.whiteBalance),
                ("zoomAbsolute", ctrl.zoomAbsolute),
                ("powerLineFrequency", ctrl.powerLineFrequency),
                ("backlightCompensation", ctrl.backlightCompensation),
                ("focusAbsolute", ctrl.focusAbsolute)
            ]
            
            for (name, prop) in controls {
                let status = prop.isCapable ? "✅" : "❌"
                diagnosticLog.append("   \(status) \(name): capable=\(prop.isCapable), min=\(prop.minimum), max=\(prop.maximum), current=\(prop.sliderValue)")
                print("   \(status) \(name): capable=\(prop.isCapable), min=\(prop.minimum), max=\(prop.maximum), current=\(prop.sliderValue)")
            }
            
            // Check bool controls
            diagnosticLog.append("   Bool controls:")
            diagnosticLog.append("      exposureMode: \(ctrl.exposureMode.isCapable ? "✅" : "❌") capable=\(ctrl.exposureMode.isCapable)")
            diagnosticLog.append("      whiteBalanceAuto: \(ctrl.whiteBalanceAuto.isCapable ? "✅" : "❌") capable=\(ctrl.whiteBalanceAuto.isCapable)")
            diagnosticLog.append("      focusAuto: \(ctrl.focusAuto.isCapable ? "✅" : "❌") capable=\(ctrl.focusAuto.isCapable)")
            
            // Pan/Tilt
            diagnosticLog.append("   panTiltAbsolute: \(ctrl.panTiltAbsolute.isCapable ? "✅" : "❌") capable=\(ctrl.panTiltAbsolute.isCapable)")
            
            print("📊 Diagnostics captured for \(avDevice.localizedName)")
        } else {
            diagnosticLog.append("⚠️ No controller created - uvcDevice.properties was nil")
            print("⚠️ No controller created for \(avDevice.localizedName)")
        }

        cropCancellable = CropSettings.shared.objectWillChange
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] _ in self?.saveCropSettings() }
    }

    static func == (lhs: CaptureDevice, rhs: CaptureDevice) -> Bool {
        return lhs.avDevice == rhs.avDevice
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(avDevice)
    }

    func isConfigurable() -> Bool {
        return uvcDevice != nil
    }

    func isDefaultDevice() -> Bool {
        return false
    }

    func readValuesFromDevice() {
        if let controller = controller {
            controller.exposureTime.update()
            controller.whiteBalance.update()
            controller.focusAbsolute.update()
            controller.objectWillChange.send()
        }
    }

    func writeValuesToDevice() {
        if let controller = controller {
            controller.writeValues()
        }
    }

    private func saveCropSettings() {
        let cs = CropSettings.shared
        UserDefaults.standard.set(cs.enabled, forKey: "cropEnabled")
        UserDefaults.standard.set(cs.top, forKey: "cropTop")
        UserDefaults.standard.set(cs.bottom, forKey: "cropBottom")
        UserDefaults.standard.set(cs.left, forKey: "cropLeft")
        UserDefaults.standard.set(cs.right, forKey: "cropRight")
    }
}
