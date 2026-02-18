//
//  NonUVCAdvancedView.swift
//  CamCunt
//
//  Copyright © 2025 dweebzxx. All rights reserved.
//  Originally CameraController by Itay Brenner
//

import SwiftUI

struct NonUVCAdvancedView: View {
    @ObservedObject var captureDevice: CaptureDevice

    var body: some View {
        VStack {
            // Disabled UVC controls
            GroupBox(label: Text("Powerline Frequency")) {
                HStack {
                    Spacer()
                    Picker(selection: .constant(0), label: EmptyView()) {
                        Text("Disabled").frame(width: 100).tag(0)
                        Text("50 Hz").frame(width: 100).tag(1)
                        Text("60 Hz").frame(width: 100).tag(2)
                        Text("Auto").frame(width: 100).tag(3)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    Spacer()
                }
            }
            .disabled(true)

            GroupBox(label: Text("Backlight Compensation")) {
                HStack {
                    Spacer()
                    Picker(selection: .constant(0), label: EmptyView()) {
                        Text("Off").tag(0)
                        Text("On").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 300, height: 20.0)
                }
            }
            .disabled(true)

            GroupBox(label: Text("Zoom/Pan/Tilt")) {
                VStack(spacing: 3.0) {
                    disabledSlider("Zoom:")
                    disabledSlider("Tilt:")
                    disabledSlider("Pan:")
                }
            }
            .disabled(true)

            // Functional crop controls
            GroupBox(label: Text("Crop")) {
                VStack(spacing: 3.0) {
                    HStack {
                        Toggle(isOn: $captureDevice.cropSettings.enabled) {
                            Text("Enable Crop")
                        }
                    }

                    HStack {
                        Text("Top:")
                        Spacer()
                        Slider(value: $captureDevice.cropSettings.top, in: 0...0.5)
                            .frame(width: 300, height: 15.0)
                            .disabled(!captureDevice.cropSettings.enabled)
                    }

                    HStack {
                        Text("Bottom:")
                        Spacer()
                        Slider(value: $captureDevice.cropSettings.bottom, in: 0...0.5)
                            .frame(width: 300, height: 15.0)
                            .disabled(!captureDevice.cropSettings.enabled)
                    }

                    HStack {
                        Text("Left:")
                        Spacer()
                        Slider(value: $captureDevice.cropSettings.left, in: 0...0.5)
                            .frame(width: 300, height: 15.0)
                            .disabled(!captureDevice.cropSettings.enabled)
                    }

                    HStack {
                        Text("Right:")
                        Spacer()
                        Slider(value: $captureDevice.cropSettings.right, in: 0...0.5)
                            .frame(width: 300, height: 15.0)
                            .disabled(!captureDevice.cropSettings.enabled)
                    }

                    HStack {
                        Button("Reset Crop") {
                            captureDevice.cropSettings.reset()
                        }
                        .disabled(!captureDevice.cropSettings.enabled &&
                                  captureDevice.cropSettings.top == 0 &&
                                  captureDevice.cropSettings.bottom == 0 &&
                                  captureDevice.cropSettings.left == 0 &&
                                  captureDevice.cropSettings.right == 0)
                    }
                }
            }

            GroupBox(label: Text("Focus")) {
                HStack {
                    Toggle(isOn: .constant(false)) {
                        Text("Auto")
                    }

                    Spacer()
                    Slider(value: .constant(0.0), in: 0...1).frame(width: 300, height: 15.0)
                }
            }
            .disabled(true)
        }
    }

    func disabledSlider(_ name: String) -> some View {
        HStack {
            Text(name)
            Spacer()
            Slider(value: .constant(0.0), in: 0...1).frame(width: 300, height: 15.0)
        }
    }
}
