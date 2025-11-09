//
//  DashboardView.swift
//  TechAssist2
//
//  Main Dashboard - Adapted from Fitness App Home Screen
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject var firebaseService = FirebaseService.shared
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    // QR Scanner state
    @State private var showQRScanner = false
    @State private var scannedQRCode: String?
    @State private var selectedWorkOrder: WorkOrder?
    @State private var showWorkOrderDetail = false
    @State private var showQRNotFoundAlert = false
    
    var technicianName: String {
        authViewModel.userName?.uppercased() ?? "TECHNICIAN"
    }
    
    var workOrders: [WorkOrder] {
        firebaseService.workOrders.isEmpty ? WorkOrder.sampleData : firebaseService.workOrders
    }
    
    var openWorkOrders: Int {
        workOrders.filter { $0.status != .completed }.count
    }
    
    var criticalPriorityCount: Int {
        workOrders.filter { $0.priority == .critical && $0.status != .completed }.count
    }
    
    var highPriorityCount: Int {
        workOrders.filter { $0.priority == .high && $0.status != .completed }.count
    }
    
    var sortedWorkOrders: [WorkOrder] {
        workOrders
            .filter { $0.status != .completed }
            .sorted { first, second in
                if first.priority.order != second.priority.order {
                    return first.priority.order < second.priority.order
                }
                if let firstDue = first.dueDate, let secondDue = second.dueDate {
                    return firstDue < secondDue
                }
                return first.createdAt < second.createdAt
            }
    }
    
    var completedToday: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return workOrders.filter { workOrder in
            workOrder.status == .completed &&
            Calendar.current.startOfDay(for: workOrder.createdAt) == today
        }.count
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundPrimary.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Section
                        headerSection
                        
                        // Key Metrics Section
                        keyMetricsSection
                        
                        // Task List Section
                        taskListSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showQRScanner) {
            QRCodeScannerView(
                isPresented: $showQRScanner,
                scannedCode: $scannedQRCode,
                onCodeScanned: { code in
                    handleScannedQRCode(code)
                }
            )
        }
        .alert("QR Code Not Found", isPresented: $showQRNotFoundAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("No work order found matching the scanned QR code.")
        }
        .background(
            Group {
                if let workOrder = selectedWorkOrder {
                    NavigationLink(
                        destination: WorkOrderDetailView(workOrder: workOrder),
                        isActive: $showWorkOrderDetail
                    ) {
                        EmptyView()
                    }
                }
            }
        )
    }
    
    // MARK: - QR Code Handling
    
    /// Handles scanned QR code and finds matching work order
    private func handleScannedQRCode(_ code: String) {
        // Search for work order by QR code data or task ID
        // QR codes typically contain the taskID or qrCodeData
        let matchingOrder = workOrders.first { workOrder in
            // Match by QR code data
            workOrder.qrCodeData?.lowercased() == code.lowercased() ||
            // Match by task ID
            workOrder.taskID.lowercased() == code.lowercased() ||
            // Match if QR code contains task ID
            code.lowercased().contains(workOrder.taskID.lowercased())
        }
        
        if let order = matchingOrder {
            // Found matching work order - navigate to detail view
            selectedWorkOrder = order
            showWorkOrderDetail = true
        } else {
            // No matching work order found
            showQRNotFoundAlert = true
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome back")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text(technicianName)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    // QR Scanner Button
                    Button(action: {
                        showQRScanner = true
                    }) {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(AppTheme.accentPrimary)
                            .frame(width: 40, height: 40)
                            .background(AppTheme.accentPrimary.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    // Profile Picture Placeholder
                    Circle()
                        .fill(AppTheme.accentPrimary.opacity(0.1))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Text(getInitials())
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppTheme.accentPrimary)
                        )
                }
            }
        }
        .padding(.top, 60)
    }
    
    private func getInitials() -> String {
        guard let name = authViewModel.userName else {
            return "U"
        }
        let components = name.components(separatedBy: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1)) + String(components[1].prefix(1))
        } else if !components.isEmpty {
            return String(components[0].prefix(2)).uppercased()
        }
        return "U"
    }
    
    private var keyMetricsSection: some View {
        HStack(spacing: 16) {
            MetricCard(
                icon: "doc.text.fill",
                value: "\(openWorkOrders)",
                label: "Open Orders"
            )
            
            MetricCard(
                icon: "exclamationmark.triangle.fill",
                value: "\(criticalPriorityCount)",
                label: "Critical"
            )
            
            MetricCard(
                icon: "checkmark.circle.fill",
                value: "\(completedToday)",
                label: "Completed"
            )
        }
    }
    
    private var taskListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Tasks")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                Text("\(sortedWorkOrders.count)")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            if sortedWorkOrders.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text("No pending tasks")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 12) {
                    ForEach(sortedWorkOrders) { workOrder in
                        NavigationLink(destination: WorkOrderDetailView(workOrder: workOrder)) {
                            TaskCard(workOrder: workOrder)
                        }
                    }
                }
            }
        }
    }
}

struct MetricCard: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppTheme.accentPrimary)
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            Text(label)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.cardPadding)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .stroke(AppTheme.cardBorderColor, lineWidth: 1)
        )
        .cornerRadius(AppTheme.cardCornerRadius)
    }
}

struct TaskCard: View {
    let workOrder: WorkOrder
    
    var body: some View {
        HStack(spacing: 16) {
            // Priority Indicator
            Circle()
                .fill(workOrder.priority.color)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 8) {
                // Task ID and Priority
                HStack {
                    Text(workOrder.taskID)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text(workOrder.priority.displayName)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(workOrder.priority.color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(workOrder.priority.color.opacity(0.1))
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    // SLA Countdown or Due Date
                    if let slaCountdown = workOrder.slaCountdown() {
                        Text(slaCountdown)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(workOrder.priority == .critical ? AppTheme.error : AppTheme.textSecondary)
                    } else if let dueDisplay = workOrder.dueDateDisplay() {
                        Text(dueDisplay)
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                
                // Title
                Text(workOrder.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(2)
                
                // Description
                Text(workOrder.description)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(1)
                
                // Location Code and Impact
                HStack(spacing: 12) {
                    if let locationCode = workOrder.locationCode {
                        Label(locationCode, systemImage: "location.fill")
                            .font(.system(size: 11, weight: .regular, design: .monospaced))
                            .foregroundColor(AppTheme.accentPrimary)
                    }
                    
                    if let usersAffected = workOrder.usersAffected, usersAffected > 0 {
                        Label("\(usersAffected) users", systemImage: "person.2.fill")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(AppTheme.textTertiary)
        }
        .padding(AppTheme.cardPadding)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .stroke(AppTheme.cardBorderColor, lineWidth: 1)
        )
        .cornerRadius(AppTheme.cardCornerRadius)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(AuthenticationViewModel())
    }
}
