//
//  CropSettingsTests.swift
//  CamCuntTests
//
//  Created by GitHub Copilot on 2/18/26.
//  Copyright © 2025 dweebzxx. All rights reserved.
//

import XCTest
import CoreGraphics
@testable import CamCunt

class CropSettingsTests: XCTestCase {

    override func setUpWithError() throws {
        // Reset to defaults before each test
        CropSettings.shared.reset()
    }

    func testDefaultCropRect() throws {
        let cropSettings = CropSettings.shared
        
        // Default should be full frame (no crop)
        XCTAssertEqual(cropSettings.cropRect, CGRect(x: 0, y: 0, width: 1, height: 1))
        XCTAssertFalse(cropSettings.isEnabled)
    }

    func testSetCropRect() throws {
        let cropSettings = CropSettings.shared
        
        // Set a custom crop rect (normalized coordinates)
        let newRect = CGRect(x: 0.1, y: 0.1, width: 0.8, height: 0.8)
        cropSettings.cropRect = newRect
        
        XCTAssertEqual(cropSettings.cropRect, newRect)
    }

    func testApplyCropDisabled() throws {
        let cropSettings = CropSettings.shared
        cropSettings.isEnabled = false
        
        // Set a crop rect but disable it
        cropSettings.cropRect = CGRect(x: 0.25, y: 0.25, width: 0.5, height: 0.5)
        
        let sourceRect = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let result = cropSettings.applyCrop(to: sourceRect)
        
        // Should return original rect when disabled
        XCTAssertEqual(result, sourceRect)
    }

    func testApplyCropEnabled() throws {
        let cropSettings = CropSettings.shared
        cropSettings.isEnabled = true
        
        // Center crop: 50% width and height
        cropSettings.cropRect = CGRect(x: 0.25, y: 0.25, width: 0.5, height: 0.5)
        
        let sourceRect = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let result = cropSettings.applyCrop(to: sourceRect)
        
        // Expected: x=480, y=270, width=960, height=540
        let expected = CGRect(x: 480, y: 270, width: 960, height: 540)
        XCTAssertEqual(result, expected)
    }

    func testApplyCropTopLeft() throws {
        let cropSettings = CropSettings.shared
        cropSettings.isEnabled = true
        
        // Top-left corner crop: 25% width and height
        cropSettings.cropRect = CGRect(x: 0, y: 0, width: 0.25, height: 0.25)
        
        let sourceRect = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let result = cropSettings.applyCrop(to: sourceRect)
        
        // Expected: x=0, y=0, width=480, height=270
        let expected = CGRect(x: 0, y: 0, width: 480, height: 270)
        XCTAssertEqual(result, expected)
    }

    func testApplyCropBottomRight() throws {
        let cropSettings = CropSettings.shared
        cropSettings.isEnabled = true
        
        // Bottom-right corner crop: 25% width and height
        cropSettings.cropRect = CGRect(x: 0.75, y: 0.75, width: 0.25, height: 0.25)
        
        let sourceRect = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let result = cropSettings.applyCrop(to: sourceRect)
        
        // Expected: x=1440, y=810, width=480, height=270
        let expected = CGRect(x: 1440, y: 810, width: 480, height: 270)
        XCTAssertEqual(result, expected)
    }

    func testReset() throws {
        let cropSettings = CropSettings.shared
        
        // Set custom values
        cropSettings.isEnabled = true
        cropSettings.cropRect = CGRect(x: 0.2, y: 0.3, width: 0.4, height: 0.5)
        
        // Reset
        cropSettings.reset()
        
        // Should be back to defaults
        XCTAssertEqual(cropSettings.cropRect, CGRect(x: 0, y: 0, width: 1, height: 1))
        XCTAssertFalse(cropSettings.isEnabled)
    }

    func testPersistence() throws {
        let cropSettings = CropSettings.shared
        
        // Set custom values
        let testRect = CGRect(x: 0.15, y: 0.25, width: 0.6, height: 0.7)
        cropSettings.cropRect = testRect
        cropSettings.isEnabled = true
        
        // Verify values were saved to UserDefaults
        let savedX = UserDefaults.standard.double(forKey: "cropRectX")
        let savedY = UserDefaults.standard.double(forKey: "cropRectY")
        let savedWidth = UserDefaults.standard.double(forKey: "cropRectWidth")
        let savedHeight = UserDefaults.standard.double(forKey: "cropRectHeight")
        let savedEnabled = UserDefaults.standard.bool(forKey: "cropEnabled")
        
        XCTAssertEqual(savedX, 0.15, accuracy: 0.001)
        XCTAssertEqual(savedY, 0.25, accuracy: 0.001)
        XCTAssertEqual(savedWidth, 0.6, accuracy: 0.001)
        XCTAssertEqual(savedHeight, 0.7, accuracy: 0.001)
        XCTAssertTrue(savedEnabled)
    }
}
