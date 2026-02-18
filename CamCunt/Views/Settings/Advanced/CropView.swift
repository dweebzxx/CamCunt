//
//  CropView.swift
//  CamCunt
//
//  Copyright © 2025 dweebzxx. All rights reserved.
//  Originally CameraController by Itay Brenner
//

import SwiftUI

struct CropView: View {
    @ObservedObject var cropSettings: CropSettings

    private var isAllZero: Bool {
        cropSettings.top == 0 && cropSettings.bottom == 0 &&
        cropSettings.left == 0 && cropSettings.right == 0
    }

    var body: some View {
        GroupBox(label: Text("Crop")) {
            VStack(spacing: 3.0) {
                Toggle(isOn: $cropSettings.enabled) {
                    Text("Enable Crop")
                }

                HStack {
                    Text("Top:")
                    Spacer()
                    Slider(value: $cropSettings.top, in: 0...0.5).frame(width: 300, height: 15.0)
                }.disabled(!cropSettings.enabled)

                HStack {
                    Text("Bottom:")
                    Spacer()
                    Slider(value: $cropSettings.bottom, in: 0...0.5).frame(width: 300, height: 15.0)
                }.disabled(!cropSettings.enabled)

                HStack {
                    Text("Left:")
                    Spacer()
                    Slider(value: $cropSettings.left, in: 0...0.5).frame(width: 300, height: 15.0)
                }.disabled(!cropSettings.enabled)

                HStack {
                    Text("Right:")
                    Spacer()
                    Slider(value: $cropSettings.right, in: 0...0.5).frame(width: 300, height: 15.0)
                }.disabled(!cropSettings.enabled)

                HStack {
                    Spacer()
                    Button("Reset Crop") {
                        cropSettings.reset()
                    }.disabled(!cropSettings.enabled && isAllZero)
                }
            }
        }
    }
}
