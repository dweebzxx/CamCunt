//
//  VideoRenderer.swift
//  CamCunt
//
//  Created by GitHub Copilot on 2/18/26.
//  Copyright © 2025 dweebzxx. All rights reserved.
//

import Foundation
import AVFoundation
import Combine
import Cocoa

class VideoRenderer: NSObject {
    private let sampleBufferDisplayLayer: AVSampleBufferDisplayLayer
    private var cropSettings: CropSettings
    private var cancellables = Set<AnyCancellable>()

    var layer: CALayer {
        return sampleBufferDisplayLayer
    }

    init(cropSettings: CropSettings = .shared) {
        self.sampleBufferDisplayLayer = AVSampleBufferDisplayLayer()
        self.cropSettings = cropSettings
        super.init()

        sampleBufferDisplayLayer.videoGravity = .resizeAspect
        updateContentsRect()

        cropSettings.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateContentsRect()
            }
            .store(in: &cancellables)
    }

    private func updateContentsRect() {
        if cropSettings.isEnabled {
            sampleBufferDisplayLayer.contentsRect = cropSettings.cropRect
        } else {
            sampleBufferDisplayLayer.contentsRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        }
    }

    func render(sampleBuffer: CMSampleBuffer) {
        enqueueSampleBuffer(sampleBuffer)
    }

    private func enqueueSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        if sampleBufferDisplayLayer.status == .failed {
            sampleBufferDisplayLayer.flush()
        }

        sampleBufferDisplayLayer.enqueue(sampleBuffer)
    }

    func flush() {
        sampleBufferDisplayLayer.flush()
    }
}
