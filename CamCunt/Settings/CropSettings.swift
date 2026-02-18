//
//  CropSettings.swift
//  CamCunt
//
//  Copyright © 2025 dweebzxx. All rights reserved.
//  Originally CameraController by Itay Brenner
//

import Foundation
import CoreGraphics
import Combine

class CropSettings: ObservableObject {
    static let shared = CropSettings()

    // Individual crop properties for UI binding (normalized 0.0 to 1.0)
    @Published var enabled: Bool = false
    @Published var top: Double = 0.0
    @Published var bottom: Double = 0.0
    @Published var left: Double = 0.0
    @Published var right: Double = 0.0

    // Computed normalized crop rectangle for preview pipeline
    // This allows crop to be independent of actual video resolution
    var cropRect: CGRect {
        guard enabled else { return CGRect(x: 0, y: 0, width: 1, height: 1) }
        let x = left
        let y = top
        let width = 1.0 - left - right
        let height = 1.0 - top - bottom
        return CGRect(x: x, y: y, width: width, height: height)
    }

    // For backwards compatibility
    var isEnabled: Bool {
        get { enabled }
        set { enabled = newValue }
    }

    private init() {
        // Load saved crop settings
        enabled = UserDefaults.standard.bool(forKey: "cropEnabled")
        top = UserDefaults.standard.double(forKey: "cropTop")
        bottom = UserDefaults.standard.double(forKey: "cropBottom")
        left = UserDefaults.standard.double(forKey: "cropLeft")
        right = UserDefaults.standard.double(forKey: "cropRight")
    }

    func saveCropSettings() {
        UserDefaults.standard.set(enabled, forKey: "cropEnabled")
        UserDefaults.standard.set(top, forKey: "cropTop")
        UserDefaults.standard.set(bottom, forKey: "cropBottom")
        UserDefaults.standard.set(left, forKey: "cropLeft")
        UserDefaults.standard.set(right, forKey: "cropRight")
    }

    // Reset crop to no crop
    func reset() {
        enabled = false
        top = 0.0
        bottom = 0.0
        left = 0.0
        right = 0.0
        saveCropSettings()
    }

    // Apply crop to a given rectangle (converts normalized to actual coordinates)
    func applyCrop(to rect: CGRect) -> CGRect {
        guard enabled else { return rect }

        let croppedX = rect.origin.x + (rect.size.width * cropRect.origin.x)
        let croppedY = rect.origin.y + (rect.size.height * cropRect.origin.y)
        let croppedWidth = rect.size.width * cropRect.size.width
        let croppedHeight = rect.size.height * cropRect.size.height

        return CGRect(x: croppedX, y: croppedY, width: croppedWidth, height: croppedHeight)
    }
}
