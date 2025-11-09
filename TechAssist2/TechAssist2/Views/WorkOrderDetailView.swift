//
//  WorkOrderDetailView.swift
//  TechAssist2
//
//  Professional Work Order Detail View
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct WorkOrderDetailView: View {
    @State private var workOrder: WorkOrder
    @ObservedObject private var firebaseService = FirebaseService.shared
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.openURL) private var openURL
    
    @State private var showIssueDocument = false
    @State private var isUpdatingWorkOrder = false
    @State private var alertInfo: AlertInfo?
    
    private let supervisorContact = "tel:19725550134"
    
    private var issueDocument: ServerIssueDocument? {
        ServerIssueDocumentLibrary.document(for: workOrder.issueDocumentId)
    }
    
    struct AlertInfo: Identifiable {
        let id = UUID()
        let title: String
        let message: String
    }
    
    init(workOrder: WorkOrder) {
        _workOrder = State(initialValue: workOrder)
    }
    
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
                        // Priority & Status Section
                        priorityStatusSection
                        
                        // Basic Task Info
                        basicTaskInfoSection
                        
                        // Location Details
                        locationDetailsSection
                        
                        // Impact Metrics
                        impactMetricsSection
                        
                        // Technical Requirements
                        technicalRequirementsSection
                        
                        if let document = issueDocument {
                            issueDocumentSection(document)
                            resolutionActionsSection(document)
                        } else {
                            resolutionActionsSection(nil)
                        }
                        
                        // QR Code Section
                        qrCodeSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showIssueDocument) {
            if let document = issueDocument {
                IssueDocumentDetailView(document: document, workOrder: workOrder)
            }
        }
        .alert(item: $alertInfo) { info in
            Alert(
                title: Text(info.title),
                message: Text(info.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // MARK: - Priority & Status Section
    private var priorityStatusSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text(workOrder.priority.displayName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(workOrder.priority.color)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(workOrder.priority.color.opacity(0.2))
                    .cornerRadius(8)
                
                Spacer()
                
                // Status Badge
                Text(workOrder.status.rawValue.uppercased())
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(statusColor(for: workOrder.status))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(statusColor(for: workOrder.status).opacity(0.2))
                    .cornerRadius(6)
            }
            
            if let dueDisplay = workOrder.dueDateDisplay() {
                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                    Text(dueDisplay)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            
            if let timeEstimate = workOrder.timeEstimate {
                HStack {
                    Image(systemName: "clock")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondary)
                    Text("Estimated Time: \(timeEstimate)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
        .padding(AppTheme.cardPadding)
        .background(AppTheme.backgroundSecondary)
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    private func statusColor(for status: WorkOrderStatus) -> Color {
        switch status {
        case .pending:
            return AppTheme.warning
        case .inProgress:
            return AppTheme.accentPrimary
        case .completed:
            return AppTheme.success
        case .onHold:
            return AppTheme.textSecondary
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
    
    // MARK: - Issue Document Section
    private func issueDocumentSection(_ document: ServerIssueDocument) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("ACTIVE INCIDENT PLAYBOOK")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text(document.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                }
                
                Spacer()
                
                Button(action: {
                    showIssueDocument = true
                }) {
                    Text("View Document")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppTheme.accentPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(AppTheme.accentPrimary.opacity(0.12))
                        .cornerRadius(8)
                }
            }
            
            Text(document.summary)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondary)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Immediate Actions")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                
                ForEach(document.immediateActions.prefix(3), id: \.self) { action in
                    BulletRow(text: action)
                }
            }
            
            if let firstStep = document.resolutionSteps.first {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Next Step")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text(firstStep)
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
        .padding(AppTheme.cardPadding)
        .background(AppTheme.backgroundSecondary)
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    // MARK: - Resolution Actions
    private func resolutionActionsSection(_ document: ServerIssueDocument?) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AVAILABLE ACTIONS")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            if let document = document {
                DetailRow(
                    label: "Estimated Time",
                    value: "\(document.estimatedTimeMinutes) min",
                    color: AppTheme.textPrimary
                )
            }
            
            VStack(spacing: 12) {
                Button {
                    resolveIssue()
                } label: {
                    ActionButtonLabel(
                        icon: "checkmark.seal.fill",
                        title: workOrder.status == .completed ? "Issue Resolved" : "Mark Issue Resolved",
                        subtitle: "Close the work order and log the fix",
                        foregroundColor: .white,
                        backgroundColor: workOrder.status == .completed ? AppTheme.success.opacity(0.7) : AppTheme.success
                    )
                }
                .disabled(isUpdatingWorkOrder || workOrder.status == .completed)
                
                if isUpdatingWorkOrder {
                    HStack(spacing: 10) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.accentPrimary))
                        Text("Updating work order status…")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textSecondary)
                        Spacer()
                    }
                    .padding(.horizontal, 4)
                }
                
                Button {
                    callSupervisor()
                } label: {
                    ActionButtonLabel(
                        icon: "phone.fill",
                        title: "Call Supervisor",
                        subtitle: "Escalate for hands-on support at the rack",
                        foregroundColor: Color(red: 0.8, green: 0.1, blue: 0.1),
                        backgroundColor: Color(red: 0.8, green: 0.1, blue: 0.1).opacity(0.12)
                    )
                }
            }
        }
        .padding(AppTheme.cardPadding)
        .background(AppTheme.backgroundSecondary)
        .cornerRadius(AppTheme.cardCornerRadius)
    }
    
    private func resolveIssue() {
        guard workOrder.status != .completed else {
            alertInfo = AlertInfo(title: "Already Completed", message: "This work order is already marked as completed.")
            return
        }
        
        isUpdatingWorkOrder = true
        var updatedOrder = workOrder
        updatedOrder.status = .completed
        
        Task {
            do {
                try await firebaseService.updateWorkOrder(updatedOrder)
                await MainActor.run {
                    workOrder = updatedOrder
                    alertInfo = AlertInfo(
                        title: "Marked as Resolved",
                        message: "The work order has been updated to Completed and synced to Firebase."
                    )
                }
            } catch {
                await MainActor.run {
                    workOrder = updatedOrder
                    alertInfo = AlertInfo(
                        title: "Marked Locally",
                        message: "Issue marked as resolved locally, but syncing to Firebase failed: \(error.localizedDescription)"
                    )
                }
            }
            
            await MainActor.run {
                isUpdatingWorkOrder = false
            }
        }
    }
    
    private func callSupervisor() {
        guard let url = URL(string: supervisorContact) else {
            alertInfo = AlertInfo(
                title: "Supervisor Contact Not Configured",
                message: "Unable to initiate a call because the supervisor contact number is missing."
            )
            return
        }
        
        let result = openURL(url)
        if case .discarded = result {
            alertInfo = AlertInfo(
                title: "Call Not Started",
                message: "Your device could not start the call. Please dial the supervisor manually."
            )
        }
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

// MARK: - Bullet Row
struct BulletRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(AppTheme.accentPrimary)
                .frame(width: 6, height: 6)
                .padding(.top, 6)
            
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.leading)
        }
    }
}

// MARK: - Action Button Label
struct ActionButtonLabel: View {
    let icon: String
    let title: String
    let subtitle: String
    let foregroundColor: Color
    let backgroundColor: Color
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(foregroundColor)
                .frame(width: 32, height: 32)
                .background(foregroundColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(foregroundColor)
                
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(foregroundColor.opacity(0.7))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(foregroundColor.opacity(0.8))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(backgroundColor)
        .cornerRadius(12)
    }
}

struct WorkOrderDetailView_Previews: PreviewProvider {
    static var previews: some View {
        WorkOrderDetailView(workOrder: WorkOrder.sampleData[0])
            .preferredColorScheme(.dark)
    }
}
