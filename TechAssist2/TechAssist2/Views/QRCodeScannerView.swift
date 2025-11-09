//
//  QRCodeScannerView.swift
//  TechAssist2
//
//  QR Code Scanner using AVFoundation
//

import SwiftUI
import AVFoundation

struct QRCodeScannerView: View {
    @Binding var isPresented: Bool
    @Binding var scannedCode: String?
    var onCodeScanned: ((String) -> Void)?
    
    var body: some View {
        ZStack {
            // Camera preview
            QRCodeScannerViewController(
                scannedCode: $scannedCode,
                onCodeScanned: { code in
                    onCodeScanned?(code)
                    // Auto-dismiss after successful scan
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isPresented = false
                    }
                }
            )
            .ignoresSafeArea()
            
            // Overlay with scanning frame
            VStack {
                // Top bar
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .padding()
                    
                    Spacer()
                }
                
                Spacer()
                
                // Scanning frame indicator
                VStack(spacing: 16) {
                    Text("Position QR code within frame")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(8)
                    
                    // Scanning frame
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 250, height: 250)
                        .overlay(
                            // Corner indicators
                            VStack {
                                HStack {
                                    CornerIndicator()
                                        .rotationEffect(.degrees(0))
                                    Spacer()
                                    CornerIndicator()
                                        .rotationEffect(.degrees(90))
                                }
                                Spacer()
                                HStack {
                                    CornerIndicator()
                                        .rotationEffect(.degrees(-90))
                                    Spacer()
                                    CornerIndicator()
                                        .rotationEffect(.degrees(180))
                                }
                            }
                            .padding(8)
                        )
                }
                
                Spacer()
                
                // Instructions
                VStack(spacing: 8) {
                    Text("Scan QR code to find work order")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text("Make sure the code is clear and well-lit")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.black.opacity(0.6))
                .cornerRadius(8)
                .padding(.bottom, 40)
            }
        }
    }
}

// Corner indicator for scanning frame
struct CornerIndicator: View {
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.white)
                .frame(width: 30, height: 4)
            Rectangle()
                .fill(Color.white)
                .frame(width: 4, height: 30)
        }
    }
}

// UIKit wrapper for AVFoundation camera
struct QRCodeScannerViewController: UIViewControllerRepresentable {
    @Binding var scannedCode: String?
    var onCodeScanned: ((String) -> Void)?
    
    func makeUIViewController(context: Context) -> QRScannerViewController {
        let controller = QRScannerViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, QRScannerDelegate {
        let parent: QRCodeScannerViewController
        
        init(_ parent: QRCodeScannerViewController) {
            self.parent = parent
        }
        
        func didScanQRCode(_ code: String) {
            DispatchQueue.main.async {
                self.parent.scannedCode = code
                self.parent.onCodeScanned?(code)
            }
        }
    }
}

// QR Scanner Delegate Protocol
protocol QRScannerDelegate: AnyObject {
    func didScanQRCode(_ code: String)
}

// UIKit View Controller for camera
class QRScannerViewController: UIViewController {
    weak var delegate: QRScannerDelegate?
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var hasScanned = false // Prevent multiple scans
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSession()
    }
    
    private func setupCamera() {
        // Check camera authorization
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.configureCamera()
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.showCameraPermissionAlert()
                    }
                }
            }
        default:
            showCameraPermissionAlert()
        }
    }
    
    private func configureCamera() {
        let session = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Failed to get camera device")
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
            } else {
                print("Cannot add video input")
                return
            }
            
            // Configure metadata output for QR code detection
            let metadataOutput = AVCaptureMetadataOutput()
            
            if session.canAddOutput(metadataOutput) {
                session.addOutput(metadataOutput)
                
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.qr]
            } else {
                print("Cannot add metadata output")
                return
            }
            
            // Setup preview layer
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
            
            self.captureSession = session
            self.previewLayer = previewLayer
            
        } catch {
            print("Error setting up camera: \(error.localizedDescription)")
        }
    }
    
    private func startSession() {
        if let session = captureSession, !session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
            }
        }
        hasScanned = false
    }
    
    private func stopSession() {
        if let session = captureSession, session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                session.stopRunning()
            }
        }
    }
    
    private func showCameraPermissionAlert() {
        let alert = UIAlertController(
            title: "Camera Permission Required",
            message: "Please enable camera access in Settings to scan QR codes.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Prevent multiple scans
        guard !hasScanned else { return }
        
        if let metadataObject = metadataObjects.first,
           let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
           let stringValue = readableObject.stringValue {
            
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            hasScanned = true
            stopSession()
            
            // Notify delegate
            delegate?.didScanQRCode(stringValue)
        }
    }
}

