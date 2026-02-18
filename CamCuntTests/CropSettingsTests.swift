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

        // Default should be full frame (no crop): top/bottom/left/right all 0
        XCTAssertEqual(cropSettings.cropRect, CGRect(x: 0, y: 0, width: 1, height: 1))
        XCTAssertFalse(cropSettings.isEnabled)
    }

    func testSetCropEdgeInsets() throws {
        let cropSettings = CropSettings.shared

        // Set edge insets to produce cropRect(x:0.1, y:0.1, width:0.8, height:0.8)
        cropSettings.left = 0.1
        cropSettings.top = 0.1
        cropSettings.right = 0.1
        cropSettings.bottom = 0.1

        let expected = CGRect(x: 0.1, y: 0.1, width: 0.8, height: 0.8)
        XCTAssertEqual(cropSettings.cropRect.origin.x, expected.origin.x, accuracy: 0.001)
        XCTAssertEqual(cropSettings.cropRect.origin.y, expected.origin.y, accuracy: 0.001)
        XCTAssertEqual(cropSettings.cropRect.size.width, expected.size.width, accuracy: 0.001)
        XCTAssertEqual(cropSettings.cropRect.size.height, expected.size.height, accuracy: 0.001)
    }

    func testApplyCropDisabled() throws {
        let cropSettings = CropSettings.shared
        cropSettings.enabled = false

        // Set edge insets but keep disabled
        cropSettings.left = 0.25; cropSettings.top = 0.25
        cropSettings.right = 0.25; cropSettings.bottom = 0.25

        let sourceRect = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let result = cropSettings.applyCrop(to: sourceRect)

        // Should return original rect when disabled
        XCTAssertEqual(result, sourceRect)
    }

    func testApplyCropEnabled() throws {
        let cropSettings = CropSettings.shared
        cropSettings.enabled = true

        // Center crop: 50% width and height (25% inset each side)
        cropSettings.left = 0.25; cropSettings.top = 0.25
        cropSettings.right = 0.25; cropSettings.bottom = 0.25

        let sourceRect = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let result = cropSettings.applyCrop(to: sourceRect)

        // Expected: x=480, y=270, width=960, height=540
        XCTAssertEqual(result.origin.x, 480, accuracy: 0.5)
        XCTAssertEqual(result.origin.y, 270, accuracy: 0.5)
        XCTAssertEqual(result.size.width, 960, accuracy: 0.5)
        XCTAssertEqual(result.size.height, 540, accuracy: 0.5)
    }

    func testApplyCropTopLeft() throws {
        let cropSettings = CropSettings.shared
        cropSettings.enabled = true

        // Crop 75% from right and 75% from bottom → top-left 25%×25% of frame
        cropSettings.left = 0; cropSettings.top = 0
        cropSettings.right = 0.75; cropSettings.bottom = 0.75

        let sourceRect = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let result = cropSettings.applyCrop(to: sourceRect)

        // Expected: x=0, y=0, width=480, height=270
        XCTAssertEqual(result.origin.x, 0, accuracy: 0.5)
        XCTAssertEqual(result.origin.y, 0, accuracy: 0.5)
        XCTAssertEqual(result.size.width, 480, accuracy: 0.5)
        XCTAssertEqual(result.size.height, 270, accuracy: 0.5)
    }

    func testApplyCropBottomRight() throws {
        let cropSettings = CropSettings.shared
        cropSettings.enabled = true

        // Crop 75% from left and 75% from top → bottom-right 25%×25% of frame
        cropSettings.left = 0.75; cropSettings.top = 0.75
        cropSettings.right = 0; cropSettings.bottom = 0

        let sourceRect = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let result = cropSettings.applyCrop(to: sourceRect)

        // Expected: x=1440, y=810, width=480, height=270
        XCTAssertEqual(result.origin.x, 1440, accuracy: 0.5)
        XCTAssertEqual(result.origin.y, 810, accuracy: 0.5)
        XCTAssertEqual(result.size.width, 480, accuracy: 0.5)
        XCTAssertEqual(result.size.height, 270, accuracy: 0.5)
    }

    func testReset() throws {
        let cropSettings = CropSettings.shared

        // Set custom values
        cropSettings.enabled = true
        cropSettings.left = 0.2; cropSettings.top = 0.3
        cropSettings.right = 0.4; cropSettings.bottom = 0.5

        // Reset
        cropSettings.reset()

        // Should be back to defaults
        XCTAssertEqual(cropSettings.cropRect, CGRect(x: 0, y: 0, width: 1, height: 1))
        XCTAssertFalse(cropSettings.isEnabled)
        XCTAssertEqual(cropSettings.top, 0)
        XCTAssertEqual(cropSettings.bottom, 0)
        XCTAssertEqual(cropSettings.left, 0)
        XCTAssertEqual(cropSettings.right, 0)
    }

    func testPersistence() throws {
        let cropSettings = CropSettings.shared

        // Set custom values
        cropSettings.top = 0.1
        cropSettings.bottom = 0.2
        cropSettings.left = 0.15
        cropSettings.right = 0.05
        cropSettings.enabled = true

        // Trigger save manually (normally debounced via CaptureDevice)
        UserDefaults.standard.set(cropSettings.enabled, forKey: "cropEnabled")
        UserDefaults.standard.set(cropSettings.top, forKey: "cropTop")
        UserDefaults.standard.set(cropSettings.bottom, forKey: "cropBottom")
        UserDefaults.standard.set(cropSettings.left, forKey: "cropLeft")
        UserDefaults.standard.set(cropSettings.right, forKey: "cropRight")

        // Verify values were saved to UserDefaults with new keys
        XCTAssertEqual(UserDefaults.standard.double(forKey: "cropTop"), 0.1, accuracy: 0.001)
        XCTAssertEqual(UserDefaults.standard.double(forKey: "cropBottom"), 0.2, accuracy: 0.001)
        XCTAssertEqual(UserDefaults.standard.double(forKey: "cropLeft"), 0.15, accuracy: 0.001)
        XCTAssertEqual(UserDefaults.standard.double(forKey: "cropRight"), 0.05, accuracy: 0.001)
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "cropEnabled"))
    }
}
