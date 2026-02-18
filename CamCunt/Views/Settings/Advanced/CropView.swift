//
//  CropView.swift
//  CamCunt
//
//  Copyright © 2025 dweebzxx. All rights reserved.
//  Originally CameraController by Itay Brenner
//

import SwiftUI

struct CropView: View {
    @ObservedObject var controller: DeviceController

    var body: some View {
        GroupBox(label: Text("Crop")) {
            VStack(spacing: 3.0) {
                HStack {
                    Toggle(isOn: $controller.cropSettings.enabled) {
                        Text("Enable Crop")
                    }
                }

                HStack {
                    Text("Top:")
                    Spacer()
                    Slider(value: $controller.cropSettings.top, in: 0...0.5)
                        .frame(width: 300, height: 15.0)
                        .disabled(!controller.cropSettings.enabled)
                }

                HStack {
                    Text("Bottom:")
                    Spacer()
                    Slider(value: $controller.cropSettings.bottom, in: 0...0.5)
                        .frame(width: 300, height: 15.0)
                        .disabled(!controller.cropSettings.enabled)
                }

                HStack {
                    Text("Left:")
                    Spacer()
                    Slider(value: $controller.cropSettings.left, in: 0...0.5)
                        .frame(width: 300, height: 15.0)
                        .disabled(!controller.cropSettings.enabled)
                }

                HStack {
                    Text("Right:")
                    Spacer()
                    Slider(value: $controller.cropSettings.right, in: 0...0.5)
                        .frame(width: 300, height: 15.0)
                        .disabled(!controller.cropSettings.enabled)
                }

                HStack {
                    Button("Reset Crop") {
                        controller.cropSettings.reset()
                    }
                    .disabled(!controller.cropSettings.enabled &&
                              controller.cropSettings.top == 0 &&
                              controller.cropSettings.bottom == 0 &&
                              controller.cropSettings.left == 0 &&
                              controller.cropSettings.right == 0)
                }
            }
        }
    }
}
