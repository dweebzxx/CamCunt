//
//  CameraPrreviewInternal.swift
//  CamCunt
//
//  Created by Itay Brenner on 7/21/20.
//  Copyright © 2025 dweebzxx. All rights reserved.
//  Originally CameraController by Itay Brenner
//

import Foundation
import Cocoa
import AVFoundation

class CameraPreviewInternal: NSView {
    var captureDevice: AVCaptureDevice?
    private var captureSession: AVCaptureSession
    private var videoOutput: AVCaptureVideoDataOutput!
    private var captureInput: AVCaptureInput?
    private var videoRenderer: VideoRenderer!
    private let videoQueue = DispatchQueue(label: "com.dweebzxx.camcunt.videoQueue")

    init(frame frameRect: NSRect, device: AVCaptureDevice?) {
        captureDevice = device
        captureSession = AVCaptureSession()

        super.init(frame: frameRect)

        configureDevice(device)
        setupVideoOutput(captureSession)
        captureSession.startRunning()
    }

    private func setupVideoOutput(_ captureSession: AVCaptureSession) {
        videoOutput = AVCaptureVideoDataOutput()
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
        videoOutput.alwaysDiscardsLateVideoFrames = true
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        videoRenderer = VideoRenderer()
        videoRenderer.layer.frame = CGRect(x: 0, y: 0, width: 400, height: 225)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        super.layout()
        videoRenderer.layer.frame = bounds
        if videoRenderer.layer.superlayer == nil {
            layer?.addSublayer(videoRenderer.layer)
        }
    }

    func stopRunning() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
        videoRenderer.flush()
    }

    func updateCamera(_ cam: AVCaptureDevice?) {
        if captureDevice != cam {
            captureSession.stopRunning()
            configureDevice(cam)
            captureSession.startRunning()
        }
    }

    private func configureDevice(_ aDevice: AVCaptureDevice?) {
        guard let device = aDevice else {
            captureDevice = aDevice
            return
        }

        if let input = captureInput {
            captureSession.removeInput(input)
        }

        do {
            captureInput = try AVCaptureDeviceInput(device: device)
        } catch {
            return
        }

        if let input = captureInput,
            captureSession.canAddInput(input) {
            captureSession.addInput(input)
        } else {
            return
        }
        captureDevice = device
    }
}

extension CameraPreviewInternal: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        videoRenderer.render(sampleBuffer: sampleBuffer)
    }
}
