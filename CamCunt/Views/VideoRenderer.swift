//
//  VideoRenderer.swift
//  CamCunt
//
//  Created by GitHub Copilot on 2/18/26.
//  Copyright © 2025 dweebzxx. All rights reserved.
//

import Foundation
import AVFoundation
import CoreVideo
import Cocoa

class VideoRenderer: NSObject {
    private let sampleBufferDisplayLayer: AVSampleBufferDisplayLayer
    private var cropSettings: CropSettings
    private let ciContext: CIContext
    
    var layer: CALayer {
        return sampleBufferDisplayLayer
    }
    
    init(cropSettings: CropSettings = .shared) {
        self.sampleBufferDisplayLayer = AVSampleBufferDisplayLayer()
        self.cropSettings = cropSettings
        self.ciContext = CIContext()
        super.init()
        
        sampleBufferDisplayLayer.videoGravity = .resizeAspect
    }
    
    func render(sampleBuffer: CMSampleBuffer) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        // If crop is enabled, we need to apply the crop transformation
        if cropSettings.isEnabled {
            // Create a cropped sample buffer
            if let croppedBuffer = applyCrop(to: sampleBuffer, imageBuffer: imageBuffer) {
                enqueueSampleBuffer(croppedBuffer)
            }
        } else {
            // No crop, just display the buffer directly
            enqueueSampleBuffer(sampleBuffer)
        }
    }
    
    private func enqueueSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        if sampleBufferDisplayLayer.status == .failed {
            sampleBufferDisplayLayer.flush()
        }
        
        sampleBufferDisplayLayer.enqueue(sampleBuffer)
    }
    
    private func applyCrop(to sampleBuffer: CMSampleBuffer, imageBuffer: CVImageBuffer) -> CMSampleBuffer? {
        // Get the dimensions of the image buffer
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        
        // Convert normalized crop rect to pixel coordinates
        let sourceRect = CGRect(x: 0, y: 0, width: width, height: height)
        let cropRect = cropSettings.applyCrop(to: sourceRect)
        
        // For now, we'll use Core Image to crop the buffer
        // In a production app, you might want to use Metal for better performance
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        let croppedImage = ciImage.cropped(to: cropRect)
        
        // Create a new pixel buffer with the cropped dimensions
        var croppedPixelBuffer: CVPixelBuffer?
        let options = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ] as CFDictionary
        
        let croppedWidth = Int(cropRect.width)
        let croppedHeight = Int(cropRect.height)
        
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            croppedWidth,
            croppedHeight,
            kCVPixelFormatType_32BGRA,
            options,
            &croppedPixelBuffer
        )
        
        guard status == kCVReturnSuccess, let outputBuffer = croppedPixelBuffer else {
            return nil
        }
        
        // Render the cropped image to the new pixel buffer
        ciContext.render(croppedImage, to: outputBuffer)
        
        // Create a new sample buffer with the cropped pixel buffer
        var sampleBufferOut: CMSampleBuffer?
        var timingInfo = CMSampleTimingInfo()
        timingInfo.presentationTimeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        timingInfo.duration = CMSampleBufferGetDuration(sampleBuffer)
        timingInfo.decodeTimeStamp = CMSampleBufferGetDecodeTimeStamp(sampleBuffer)
        
        var formatDescription: CMFormatDescription?
        CMVideoFormatDescriptionCreateForImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: outputBuffer,
            formatDescriptionOut: &formatDescription
        )
        
        guard let format = formatDescription else {
            return nil
        }
        
        CMSampleBufferCreateReadyWithImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: outputBuffer,
            formatDescription: format,
            sampleTiming: &timingInfo,
            sampleBufferOut: &sampleBufferOut
        )
        
        return sampleBufferOut
    }
    
    func flush() {
        sampleBufferDisplayLayer.flush()
    }
}
