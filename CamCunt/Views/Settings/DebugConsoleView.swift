//
//  DebugConsoleView.swift
//  CamCunt
//
//  Created by GitHub Copilot on 2/20/26.
//  Copyright © 2025 dweebzxx. All rights reserved.
//

import SwiftUI

class DebugLogger: ObservableObject {
    static let shared = DebugLogger()
    
    @Published var logs: [String] = []
    
    private init() {
        logs.append("[\(timestamp())] Debug Console initialized")
    }
    
    func log(_ message: String) {
        DispatchQueue.main.async {
            self.logs.append("[\(self.timestamp())] \(message)")
            // Keep only last 500 lines to prevent memory issues
            if self.logs.count > 500 {
                self.logs.removeFirst(self.logs.count - 500)
            }
        }
        print("[DebugLogger] \(message)")
    }
    
    func clear() {
        logs.removeAll()
        logs.append("[\(timestamp())] Console cleared")
    }
    
    private func timestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: Date())
    }
}

struct DebugConsoleView: View {
    @Binding var captureDevice: CaptureDevice?
    @ObservedObject var logger = DebugLogger.shared
    @State private var autoScroll = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with controls
            HStack {
                Text("Debug Console")
                    .font(.headline)
                Spacer()
                Toggle("Auto-scroll", isOn: $autoScroll)
                    .toggleStyle(.checkbox)
                Button("Refresh Device Info") {
                    refreshDeviceInfo()
                }
                Button("Clear") {
                    logger.clear()
                }
            }
            
            // Device status summary
            if let device = captureDevice {
                deviceStatusView(device)
            } else {
                Text("No device selected")
                    .foregroundColor(.secondary)
                    .padding(.vertical, 4)
            }
            
            Divider()
            
            // Log output
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 2) {
                        ForEach(Array(logger.logs.enumerated()), id: \.offset) { index, line in
                            Text(line)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(colorForLine(line))
                                .textSelection(.enabled)
                                .id(index)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(4)
                }
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(4)
                .onChange(of: logger.logs.count) { _ in
                    if autoScroll {
                        withAnimation {
                            proxy.scrollTo(logger.logs.count - 1, anchor: .bottom)
                        }
                    }
                }
            }
        }
        .padding(8)
        .frame(minHeight: 200)
    }
    
    private func deviceStatusView(_ device: CaptureDevice) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Device:").bold()
                Text(device.name)
                Spacer()
                if device.uvcDevice != nil {
                    Label("UVC", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                } else {
                    Label("No UVC", systemImage: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            
            if let controller = device.controller {
                HStack(spacing: 16) {
                    controlStatusBadge("Brightness", controller.brightness.isCapable)
                    controlStatusBadge("Contrast", controller.contrast.isCapable)
                    controlStatusBadge("Exposure", controller.exposureTime.isCapable)
                    controlStatusBadge("Zoom", controller.zoomAbsolute.isCapable)
                    controlStatusBadge("Focus", controller.focusAbsolute.isCapable)
                }
                .font(.caption2)
            }
        }
        .padding(8)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(6)
    }
    
    private func controlStatusBadge(_ name: String, _ capable: Bool) -> some View {
        HStack(spacing: 2) {
            Circle()
                .fill(capable ? Color.green : Color.red)
                .frame(width: 6, height: 6)
            Text(name)
                .foregroundColor(capable ? .primary : .secondary)
        }
    }
    
    private func colorForLine(_ line: String) -> Color {
        if line.contains("✅") {
            return .green
        } else if line.contains("❌") {
            return .red
        } else if line.contains("⚠️") {
            return .orange
        } else if line.contains("Error") || line.contains("FAILED") {
            return .red
        } else {
            return .primary
        }
    }
    
    private func refreshDeviceInfo() {
        guard let device = captureDevice else {
            logger.log("No device selected")
            return
        }
        
        logger.log("=== Device Info Refresh ===")
        logger.log("Device: \(device.name)")
        
        if let avDevice = device.avDevice {
            logger.log("Model ID: \(avDevice.modelID)")
            logger.log("Unique ID: \(avDevice.uniqueID)")
            logger.log("Manufacturer: \(avDevice.manufacturer)")
        }
        
        if let uvc = device.uvcDevice {
            logger.log("✅ UVC Device present")
            logger.log("   Processing Unit ID: \(uvc.processingUnitID)")
            logger.log("   Camera Terminal ID: \(uvc.cameraTerminalID)")
        } else {
            logger.log("❌ UVC Device: nil")
        }
        
        if let controller = device.controller {
            logger.log("✅ Controller present")
            logControlStatus("brightness", controller.brightness)
            logControlStatus("contrast", controller.contrast)
            logControlStatus("saturation", controller.saturation)
            logControlStatus("sharpness", controller.sharpness)
            logControlStatus("exposureTime", controller.exposureTime)
            logControlStatus("gain", controller.gain)
            logControlStatus("whiteBalance", controller.whiteBalance)
            logControlStatus("zoomAbsolute", controller.zoomAbsolute)
            logControlStatus("powerLineFrequency", controller.powerLineFrequency)
            logControlStatus("backlightCompensation", controller.backlightCompensation)
            logControlStatus("focusAbsolute", controller.focusAbsolute)
        } else {
            logger.log("❌ Controller: nil (no UVC properties)")
        }
        
        // Also dump the stored diagnostic log from initialization
        logger.log("--- Initialization Log ---")
        for line in device.diagnosticLog {
            logger.log(line)
        }
    }
    
    private func logControlStatus(_ name: String, _ prop: NumberCaptureDeviceProperty) {
        let status = prop.isCapable ? "✅" : "❌"
        logger.log("   \(status) \(name): capable=\(prop.isCapable) min=\(prop.minimum) max=\(prop.maximum) val=\(prop.sliderValue)")
    }
}
