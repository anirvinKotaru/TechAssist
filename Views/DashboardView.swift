//
//  DashboardView.swift
//  WorkOrderDashboard
//
//  Main Dashboard - Adapted from Fitness App Home Screen
//

import SwiftUI

struct DashboardView: View {
    @State private var workOrders = WorkOrder.sampleData
    let technicianName = "MICHAEL BERNANDO"
    
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
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("WELCOME BACK,")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text(technicianName)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                }
                
                Spacer()
                
                // Profile Picture Placeholder
                Circle()
                    .fill(AppTheme.accentPrimary)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text("MB")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
        }
        .padding(.top, 60)
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
                Text("ASSIGNED TASKS")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                Text("\(sortedWorkOrders.count) TASKS")
                    .font(.system(size: 12, weight: .medium))
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
                .font(.system(size: 24))
                .foregroundColor(AppTheme.accentPrimary)
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.cardPadding)
        .background(AppTheme.backgroundSecondary)
        .cornerRadius(AppTheme.cardCornerRadius)
    }
}

struct TaskCard: View {
    let workOrder: WorkOrder
    
    var body: some View {
        HStack(spacing: 12) {
            // Priority Indicator
            RoundedRectangle(cornerRadius: 4)
                .fill(workOrder.priority.color)
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 8) {
                // Task ID and Priority
                HStack {
                    Text(workOrder.taskID)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text(workOrder.priority.displayName)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(workOrder.priority.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(workOrder.priority.color.opacity(0.2))
                        .cornerRadius(6)
                    
                    Spacer()
                    
                    // SLA Countdown or Due Date
                    if let slaCountdown = workOrder.slaCountdown() {
                        Text(slaCountdown)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(workOrder.priority == .critical ? Color.red : AppTheme.textSecondary)
                    } else if let dueDisplay = workOrder.dueDateDisplay() {
                        Text(dueDisplay)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                
                // Title
                Text(workOrder.title)
                    .font(.system(size: 16, weight: .semibold))
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
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(AppTheme.accentPrimary)
                    }
                    
                    if let usersAffected = workOrder.usersAffected, usersAffected > 0 {
                        Label("\(usersAffected) users", systemImage: "person.2.fill")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    if let businessImpact = workOrder.businessImpact {
                        Text(businessImpact)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(workOrder.priority == .critical ? Color.red : AppTheme.textSecondary)
                    }
                }
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(AppTheme.cardPadding)
        .background(AppTheme.backgroundSecondary)
        .cornerRadius(AppTheme.cardCornerRadius)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .preferredColorScheme(.dark)
    }
}

