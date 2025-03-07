// CameraManager.swift
// Team8-Fundus-Photography
// Created by Chelsea Maramot on 2024-11-04.

import Foundation
import AVFoundation
import UIKit

class CameraManager: NSObject, ObservableObject {
    
    enum Status {
        case configured
        case unconfigured
        case unauthorized
        case failed
    }
    
    private var captureSession: AVCaptureSession
    private var videoDevice: AVCaptureDevice?
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var permissionGranted: Bool
    private var photoCaptureDelegate: PhotoCaptureDelegate?
    private var videoCaptureDelegate: VideoCaptureDelegate?
    private var photoOutput: AVCapturePhotoOutput?
    private var movieOutput: AVCaptureMovieFileOutput?
    private var photoSettings: AVCapturePhotoSettings?
    private let sessionQueue = DispatchQueue(label: "com.demo.sessionQueue")
    private var dispatchGroup = DispatchGroup()

    private var isRecording = false
    private var isCameraReady: Bool = false

    @Published var status = Status.unconfigured
    @Published var zoomFactor: CGFloat = 3.0

    override init() {
        self.captureSession = AVCaptureSession()
        self.permissionGranted = false
        super.init()
        
        self.checkPermission()
        self.configureSession {}
    }
    
    var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            var isAuthorized = status == .authorized
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }
            return isAuthorized
        }
    }
    
    func getSession() -> AVCaptureSession {
        return self.captureSession
    }

    func setVideoInput() {
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Unable to access back camera")
            status = .failed
            captureSession.commitConfiguration()
            return
        }

        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice), captureSession.canAddInput(videoDeviceInput) else {
            print("Unable to add device input to capture session")
            status = .unconfigured
            captureSession.commitConfiguration()
            return
        }
        
        captureSession.addInput(videoDeviceInput)
        self.videoDeviceInput = videoDeviceInput
        DispatchQueue.main.async {
            self.status = .configured
            print("done setting video input")
        }
    }
    
    func setVideoOutput() {
        let movieOutput = AVCaptureMovieFileOutput()

        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
            self.movieOutput = movieOutput
            print("Video output configured")
        } else {
            print("Failed to add video output")
        }
    }

    func setPhotoOutput() {
        let photoOutput = AVCapturePhotoOutput()
    
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
            self.photoOutput = photoOutput
            DispatchQueue.main.async {
                self.status = .configured
                print("done setting photo output")
            }
        } else {
            print("Unable to add device output to capture session")
            status = .failed
            captureSession.commitConfiguration()
        }
    }
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.permissionGranted = true
        case .notDetermined:
            self.requestPermission()
        default:
            self.permissionGranted = false
        }
    }
    
    func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                self?.permissionGranted = granted
                if granted {
                    self?.configureSession {}
                } else {
                    self?.status = .unauthorized
                }
            }
        }
    }
    
    func configureSession(completion: @escaping () -> Void) {
        print("Configuring camera session")
        
        dispatchGroup.enter()
        
        sessionQueue.async { [weak self] in
            guard let self = self, self.status == .unconfigured else { return }
            guard self.permissionGranted else { return }

            self.captureSession.beginConfiguration()
            self.setVideoInput()
            self.setPhotoOutput()
            self.setVideoOutput()
            self.captureSession.commitConfiguration()
            self.setZoomScale(factor: 3.0)
            
            DispatchQueue.main.async {
                self.isCameraReady = true
                self.dispatchGroup.leave()
                completion()
            }
        }
    }
    
    func startSession(completion: @escaping () -> Void) {
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.captureSession.startRunning()
            print("Camera session started successfully.")
        }
    }

    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        sessionQueue.async {
            if !self.captureSession.isRunning {
                print("Session not running, attempting to start session.")
                self.startSession {
                    self.capturePhotoInternal(completion: completion)
                }
            } else {
                self.capturePhotoInternal(completion: completion)
            }
        }
    }
    
    private func capturePhotoInternal(completion: @escaping (UIImage?) -> Void) {
        let photoSettings = AVCapturePhotoSettings()
        let photoCaptureDelegate = PhotoCaptureDelegate(completion: completion)
        self.photoCaptureDelegate = photoCaptureDelegate

        guard let photoOutput = self.photoOutput else {
            print("No photo output available")
            DispatchQueue.main.async { completion(nil) }
            return
        }

        photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureDelegate)
    }

    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func startRecording() {
        guard let movieOutput = self.movieOutput, !isRecording else {
            print("Recording already in progress or no movie output available.")
            return
        }
        
        if !captureSession.isRunning {
            print("⚠️ Capture session is not running. Starting session...")
            captureSession.startRunning()
        }


        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mov")
        videoCaptureDelegate = VideoCaptureDelegate { savedURL in
            if let savedURL = savedURL {
                print("Video successfully saved to: \(savedURL.absoluteString)")
            } else {
                print("Failed to save video.")
            }
        }

        print("Starting video recording...")
        if let videoConnection = movieOutput.connection(with: .video) {
            movieOutput.startRecording(to: outputURL, recordingDelegate: videoCaptureDelegate!)
            isRecording = true
        }else {
            print("No video connection found!")
        }
    }

    func stopRecording() {
        guard let movieOutput = self.movieOutput, isRecording else {
            print("No active recording to stop")
            return
        }

        print("Stopping video recording...")
        movieOutput.stopRecording()
        isRecording = false
    }
    
    func setZoomScale(factor: CGFloat) {
        guard let device = self.videoDeviceInput?.device else { return }

        do {
            try device.lockForConfiguration()
            let clampedFactor = max(device.minAvailableVideoZoomFactor, min(factor, device.maxAvailableVideoZoomFactor))
            device.videoZoomFactor = clampedFactor
            self.zoomFactor = clampedFactor
            device.unlockForConfiguration()
        } catch {
            print(error.localizedDescription)
        }
    }

    func getCurrentZoomScale() -> CGFloat? {
        guard let device = self.videoDeviceInput?.device else { return nil }
        return device.videoZoomFactor
    }

    func setFocusWithSlider(_ focusValue: Float) {
        guard let device = self.videoDeviceInput?.device else { return }

        do {
            try device.lockForConfiguration()
            
            if device.isFocusModeSupported(.locked) {
                device.focusMode = .locked
                device.setFocusModeLocked(lensPosition: focusValue) { time in
                    print("Focus set at: \(focusValue)")
                }
            }

            device.unlockForConfiguration()
        } catch {
            print("Error setting focus with slider: \(error)")
        }
    }
    
    func setFocusOnTap(devicePoint: CGPoint) {
        guard let device = self.videoDeviceInput?.device else { return }
        
        print("Focusing on tap")
        
        do {
            try device.lockForConfiguration()

            if device.isFocusModeSupported(.autoFocus) {
                device.focusMode = .autoFocus
                device.focusPointOfInterest = devicePoint
            }

            device.exposurePointOfInterest = devicePoint
            device.exposureMode = .autoExpose
            device.isSubjectAreaChangeMonitoringEnabled = true
            device.unlockForConfiguration()
            
        } catch {
            print("Failed to configure focus: \(error)")
        }
    }
}
