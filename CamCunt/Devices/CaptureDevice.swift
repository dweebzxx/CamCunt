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

    init(avDevice: AVCaptureDevice) {
        self.avDevice = avDevice
        self.name = avDevice.localizedName
        self.uvcDevice = try? UVCDevice(device: avDevice)
        self.controller = DeviceController(properties: uvcDevice?.properties)

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
