//
//  WorkOrderDetailView.swift
//  WorkOrderDashboard
//
//  Work Order Detail/Active View - Adapted from Workout in Progress Screen
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct WorkOrderDetailView: View {
    let workOrder: WorkOrder
    @State private var timerActive = true
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            AppTheme.backgroundPrimary.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                    
                    Spacer()
                    
                    Text(workOrder.taskID)
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Spacer()
                    
                    // Balance the header
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.clear)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 20)
                
                // Main Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Priority & Urgency Section
                        priorityUrgencySection
                        
                        // Timer Display
                        timerSection
                        
                        // Basic Task Info
                        basicTaskInfoSection
                        
                        // Location Details
                        locationDetailsSection
                        
                        // Impact Metrics
                        impactMetricsSection
                        
                        // Technical Requirements
                        technicalRequirementsSection
                        
                        // QR Code Section
                        qrCodeSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    // MARK: - Priority & Urgency Section
    private var priorityUrgencySection: some View {
        VStack(spacing: 12) {
            HStack {
                Text(workOrder.priority.displayName)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(workOrder.priority.color)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(workOrder.priority.color.opacity(0.2))
                    .cornerRadius(8)
                
                Spacer()
                
                if let slaCountdown = workOrder.slaCountdown() {
                    Text(slaCountdown)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(workOrder.priority == .critical ? Color.red : AppTheme.textPrimary)
                } else if let dueDisplay = workOrder.dueDateDisplay() {
                    Text(dueDisplay)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                }
            }
        }
        .padding(AppTheme.cardPadding)
        .background(AppTheme.backgroundSecondary)
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    // MARK: - Timer Section
    private var timerSection: some View {
        VStack(spacing: 16) {
            Text(timeString(from: elapsedTime + workOrder.timeSpent))
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.textPrimary)
                .monospacedDigit()
            
            HStack(spacing: 40) {
                VStack(spacing: 8) {
                    Text("EST. TIME")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text(workOrder.timeEstimate ?? "N/A")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                }
                
                Button(action: {
                    timerActive.toggle()
                    if timerActive {
                        startTimer()
                    } else {
                        stopTimer()
                    }
                }) {
                    Circle()
                        .fill(AppTheme.accentPrimary)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Image(systemName: timerActive ? "pause.fill" : "play.fill")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                        )
                }
                
                VStack(spacing: 8) {
                    Text("STATUS")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text(workOrder.status.rawValue)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.accentPrimary)
                }
            }
        }
    }
    
    // MARK: - Basic Task Info Section
    private var basicTaskInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("TASK INFORMATION")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            DetailRow(label: "Task ID", value: workOrder.taskID, color: AppTheme.accentPrimary)
            DetailRow(label: "Title", value: workOrder.title, color: AppTheme.textPrimary)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
                
                Text(workOrder.description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(AppTheme.textPrimary)
            }
        }
        .padding(AppTheme.cardPadding)
        .background(AppTheme.backgroundSecondary)
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    // MARK: - Location Details Section
    private var locationDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("LOCATION DETAILS")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            if let dataHall = workOrder.dataHall {
                DetailRow(label: "Data Hall", value: dataHall, color: AppTheme.textPrimary)
            }
            
            if let rackNumber = workOrder.rackNumber {
                DetailRow(label: "Rack Number", value: rackNumber, color: AppTheme.textPrimary)
            }
            
            if let serverPosition = workOrder.serverPosition {
                DetailRow(label: "Server Position", value: serverPosition, color: AppTheme.textPrimary)
            }
            
            if let locationCode = workOrder.locationCode {
                DetailRow(label: "Location Code", value: locationCode, color: AppTheme.accentPrimary)
            }
            
            DetailRow(label: "Location", value: workOrder.location, color: AppTheme.textSecondary)
        }
        .padding(AppTheme.cardPadding)
        .background(AppTheme.backgroundSecondary)
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    // MARK: - Impact Metrics Section
    private var impactMetricsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("IMPACT METRICS")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            if let usersAffected = workOrder.usersAffected {
                DetailRow(label: "Users Affected", value: "\(usersAffected)", color: AppTheme.textPrimary)
            }
            
            if let businessImpact = workOrder.businessImpact {
                DetailRow(label: "Business Impact", value: businessImpact, color: workOrder.priority == .critical ? Color.red : AppTheme.textPrimary)
            }
            
            if let systemsAffected = workOrder.systemsAffected {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Systems Affected")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text(systemsAffected)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(AppTheme.textPrimary)
                }
            }
        }
        .padding(AppTheme.cardPadding)
        .background(AppTheme.backgroundSecondary)
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    // MARK: - Technical Requirements Section
    private var technicalRequirementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("TECHNICAL REQUIREMENTS")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            if let timeEstimate = workOrder.timeEstimate {
                DetailRow(label: "Time Estimate", value: timeEstimate, color: AppTheme.textPrimary)
            }
            
            if let requiredTools = workOrder.requiredTools {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Required Tools")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text(requiredTools)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(AppTheme.textPrimary)
                }
            }
            
            if let skillsNeeded = workOrder.skillsNeeded {
                DetailRow(label: "Skills Needed", value: skillsNeeded, color: AppTheme.accentPrimary)
            }
            
            if let equipment = workOrder.equipment {
                DetailRow(label: "Equipment", value: equipment, color: AppTheme.textSecondary)
            }
        }
        .padding(AppTheme.cardPadding)
        .background(AppTheme.backgroundSecondary)
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    // MARK: - QR Code Section
    private var qrCodeSection: some View {
        VStack(spacing: 16) {
            Text("SCAN QR CODE TO VERIFY LOCATION")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            Text("Scan this code when you arrive at the location to verify you're at the correct server and await further instructions.")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
            
            if let qrCodeData = workOrder.qrCodeData {
                QRCodeView(data: qrCodeData)
                    .frame(width: 200, height: 200)
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(12)
            }
            
            Text(workOrder.qrCodeData ?? "")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(AppTheme.cardPadding)
        .background(AppTheme.backgroundSecondary)
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    // MARK: - Helper Functions
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedTime += 1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

// MARK: - QR Code View
struct QRCodeView: View {
    let data: String
    
    var body: some View {
        if let qrImage = generateQRCode(from: data) {
            Image(uiImage: qrImage)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
        } else {
            Image(systemName: "qrcode")
                .font(.system(size: 100))
                .foregroundColor(AppTheme.textSecondary)
        }
    }
    
    private func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")
        
        if let outputImage = filter.outputImage {
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)
            
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        
        return nil
    }
}

// MARK: - Detail Row
struct DetailRow: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
                .multilineTextAlignment(.trailing)
        }
    }
}

struct WorkOrderDetailView_Previews: PreviewProvider {
    static var previews: some View {
        WorkOrderDetailView(workOrder: WorkOrder.sampleData[0])
            .preferredColorScheme(.dark)
    }
}
