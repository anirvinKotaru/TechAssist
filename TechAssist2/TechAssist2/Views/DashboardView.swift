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
    @State private var selectedArticle: TroubleshootingArticle?
    @State private var showArticleDetail = false
    
    var technicianName: String {
        // Use name as primary identifier, fallback to email if name not available
        if let name = authViewModel.userName {
            return name
        } else if let email = authViewModel.userEmail {
            return email
        } else {
            return "Technician"
        }
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
                    VStack(spacing: 20) {
                        // Header Section
                        headerSection
                        
                        // Key Metrics Section
                        keyMetricsSection
                        
                        // Task List Section
                        taskListSection
                    }
                    .padding(.horizontal, 16)
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
            Text("No work order or troubleshooting article found matching the scanned QR code.")
        }
        .sheet(isPresented: $showArticleDetail) {
            if let article = selectedArticle {
                ArticleDetailView(article: article)
            }
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
    
    /// Handles scanned QR code and finds matching work order or troubleshooting article
    private func handleScannedQRCode(_ code: String) {
        // First, check if it's a troubleshooting article QR code
        if let article = TroubleshootingArticle.findArticle(byQRCodeID: code) {
            // Found matching troubleshooting article - show article detail
            selectedArticle = article
            showArticleDetail = true
            return
        }
        
        // Otherwise, search for work order by QR code data or task ID
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
            // No matching work order or article found
            showQRNotFoundAlert = true
        }
    }
    
    private var headerSection: some View {
        HStack {
            Text(technicianName)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)
            
            Spacer()
            
            Button(action: {
                showQRScanner = true
            }) {
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppTheme.accentPrimary)
            }
        }
        .padding(.top, 16)
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
        HStack(spacing: 12) {
            MetricCard(
                value: "\(openWorkOrders)",
                label: "Open"
            )
            
            MetricCard(
                value: "\(criticalPriorityCount)",
                label: "Critical"
            )
            
            MetricCard(
                value: "\(completedToday)",
                label: "Done"
            )
        }
    }
    
    private var taskListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Work Orders")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)
            
            if sortedWorkOrders.isEmpty {
                Text("No pending tasks")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(AppTheme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
            } else {
                VStack(spacing: 8) {
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
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
            
            Text(label)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(AppTheme.backgroundSecondary)
        .cornerRadius(AppTheme.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct TaskCard: View {
    let workOrder: WorkOrder
    
    var body: some View {
        HStack(spacing: 12) {
            // Priority Indicator
            RoundedRectangle(cornerRadius: 2)
                .fill(workOrder.priority.color)
                .frame(width: 3)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(workOrder.taskID)
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Spacer()
                    
                    Text(workOrder.priority.displayName)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(workOrder.priority.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(workOrder.priority.color.opacity(0.15))
                        .cornerRadius(4)
                }
                
                Text(workOrder.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(2)
                
                if let locationCode = workOrder.locationCode {
                    Text(locationCode)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(AppTheme.cardPadding)
        .background(AppTheme.backgroundSecondary)
        .cornerRadius(AppTheme.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(AuthenticationViewModel())
    }
}
