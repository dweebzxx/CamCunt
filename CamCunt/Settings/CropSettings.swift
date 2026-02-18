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

    // Normalized edge-inset crop values (0.0–0.5 each side)
    @Published var enabled: Bool
    @Published var top: Double
    @Published var bottom: Double
    @Published var left: Double
    @Published var right: Double

    // Backward compatibility for VideoRenderer
    var isEnabled: Bool { enabled }

    // Normalized crop window derived from edge insets
    var cropRect: CGRect {
        CGRect(x: left, y: top,
               width: max(0, 1 - left - right),
               height: max(0, 1 - top - bottom))
    }

    private init() {
        enabled = UserDefaults.standard.bool(forKey: "cropEnabled")
        top = UserDefaults.standard.double(forKey: "cropTop")
        bottom = UserDefaults.standard.double(forKey: "cropBottom")
        left = UserDefaults.standard.double(forKey: "cropLeft")
        right = UserDefaults.standard.double(forKey: "cropRight")
    }

    func reset() {
        enabled = false
        top = 0; bottom = 0; left = 0; right = 0
    }

    // Apply crop to a given rectangle (converts normalized to actual coordinates)
    func applyCrop(to rect: CGRect) -> CGRect {
        guard isEnabled else { return rect }
        return CGRect(
            x: rect.origin.x + rect.size.width * CGFloat(left),
            y: rect.origin.y + rect.size.height * CGFloat(top),
            width: rect.size.width * CGFloat(max(0, 1 - left - right)),
            height: rect.size.height * CGFloat(max(0, 1 - top - bottom))
        )
    }
}
