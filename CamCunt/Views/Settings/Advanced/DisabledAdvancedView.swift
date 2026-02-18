//
//  DisabledAdvancedView.swift
//  CamCunt
//
//  Created by Itay Brenner on 8/7/20.
//  Copyright © 2025 dweebzxx. All rights reserved.
//  Originally CameraController by Itay Brenner
//

import SwiftUI

struct DisabledAdvancedView: View {
    /// When non-nil, the crop section is shown as fully functional.
    var cropSettings: CropSettings? = nil

    var body: some View {
        VStack {
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
            }.disabled(true)

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
            }.disabled(true)

            GroupBox(label: Text("Zoom/Pan/Tilt")) {
                VStack(spacing: 3.0) {
                    slider("Zoom:")
                    slider("Tilt:")
                    slider("Pan:")
                }
            }.disabled(true)

            if let cs = cropSettings {
                CropView(cropSettings: cs)
            } else {
                GroupBox(label: Text("Crop")) {
                    VStack(spacing: 3.0) {
                        Toggle(isOn: .constant(false)) { Text("Enable Crop") }
                        slider("Top:")
                        slider("Bottom:")
                        slider("Left:")
                        slider("Right:")
                        HStack {
                            Spacer()
                            Button("Reset Crop") {}
                        }
                    }
                }.disabled(true)
            }

            GroupBox(label: Text("Focus")) {
                HStack {
                    Toggle(isOn: .constant(false)) {
                        Text("Auto")
                    }

                    Spacer()
                    Slider(value: .constant(0.0), in: 0...1).frame(width: 300, height: 15.0)
                }
            }.disabled(true)
        }
    }

    func slider(_ name: String) -> some View {
        HStack {
            Text(name)
            Spacer()
            Slider(value: .constant(0.0), in: 0...1).frame(width: 300, height: 15.0)
        }
    }
}

struct DisabledAdvancedView_Previews: PreviewProvider {
    static var previews: some View {
        DisabledAdvancedView()
    }
}
