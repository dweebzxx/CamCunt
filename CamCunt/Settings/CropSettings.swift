//
//  CropSettings.swift
//  CamCunt
//
//  Created by GitHub Copilot on 2/18/26.
//  Copyright © 2025 dweebzxx. All rights reserved.
//

import Foundation
import CoreGraphics
import Combine

class CropSettings: ObservableObject {
    static let shared = CropSettings()
    
    // Normalized crop rectangle (0.0 to 1.0 for x, y, width, height)
    // This allows crop to be independent of actual video resolution
    @Published var cropRect: CGRect {
        didSet {
            saveCropRect()
        }
    }
    
    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "cropEnabled")
        }
    }
    
    private init() {
        // Load saved crop rect or default to full frame (no crop)
        let x = UserDefaults.standard.double(forKey: "cropRectX")
        let y = UserDefaults.standard.double(forKey: "cropRectY")
        let width = UserDefaults.standard.double(forKey: "cropRectWidth")
        let height = UserDefaults.standard.double(forKey: "cropRectHeight")
        
        // If no saved values, default to full frame
        if width == 0 || height == 0 {
            cropRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        } else {
            cropRect = CGRect(x: x, y: y, width: width, height: height)
        }
        
        isEnabled = UserDefaults.standard.bool(forKey: "cropEnabled")
    }
    
    private func saveCropRect() {
        UserDefaults.standard.set(cropRect.origin.x, forKey: "cropRectX")
        UserDefaults.standard.set(cropRect.origin.y, forKey: "cropRectY")
        UserDefaults.standard.set(cropRect.size.width, forKey: "cropRectWidth")
        UserDefaults.standard.set(cropRect.size.height, forKey: "cropRectHeight")
    }
    
    // Reset crop to full frame
    func reset() {
        cropRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        isEnabled = false
    }
    
    // Apply crop to a given rectangle (converts normalized to actual coordinates)
    func applyCrop(to rect: CGRect) -> CGRect {
        guard isEnabled else { return rect }
        
        let croppedX = rect.origin.x + (rect.size.width * cropRect.origin.x)
        let croppedY = rect.origin.y + (rect.size.height * cropRect.origin.y)
        let croppedWidth = rect.size.width * cropRect.size.width
        let croppedHeight = rect.size.height * cropRect.size.height
        
        return CGRect(x: croppedX, y: croppedY, width: croppedWidth, height: croppedHeight)
    }
}
