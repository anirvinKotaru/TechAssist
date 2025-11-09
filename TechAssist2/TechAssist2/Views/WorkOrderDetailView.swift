//
//  WorkOrderDetailView.swift
//  TechAssist2
//
//  Professional Work Order Detail View
//

import SwiftUI

struct WorkOrderDetailView: View {
    let workOrder: WorkOrder
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
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                    
                    Spacer()
                    
                    Text(workOrder.taskID)
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.clear)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)
                
                // Main Content
                ScrollView {
                    VStack(spacing: 16) {
                        // Priority & Status
                        priorityStatusSection
                        
                        // Task Info
                        basicTaskInfoSection
                        
                        // Location
                        locationDetailsSection
                        
                        // Requirements
                        technicalRequirementsSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Priority & Status Section
    private var priorityStatusSection: some View {
        HStack {
            Text(workOrder.priority.displayName)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(workOrder.priority.color)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(workOrder.priority.color.opacity(0.1))
                .cornerRadius(6)
            
            Spacer()
            
            Text(workOrder.status.rawValue)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(statusColor(for: workOrder.status))
        }
        .padding(AppTheme.cardPadding)
        .background(AppTheme.backgroundSecondary)
        .cornerRadius(AppTheme.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
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
        VStack(alignment: .leading, spacing: 12) {
            Text(workOrder.title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)
            
            Text(workOrder.description)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.cardPadding)
        .background(AppTheme.backgroundSecondary)
        .cornerRadius(AppTheme.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
    
    // MARK: - Location Details Section
    private var locationDetailsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let locationCode = workOrder.locationCode {
                Text(locationCode)
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(AppTheme.accentPrimary)
            }
            
            Text(workOrder.location)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(AppTheme.textSecondary)
            
            if let dataHall = workOrder.dataHall, let rackNumber = workOrder.rackNumber {
                Text("\(dataHall) • \(rackNumber)")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.cardPadding)
        .background(AppTheme.backgroundSecondary)
        .cornerRadius(AppTheme.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
    
    
    // MARK: - Technical Requirements Section
    private var technicalRequirementsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let timeEstimate = workOrder.timeEstimate {
                Text("Est. Time: \(timeEstimate)")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            if let requiredTools = workOrder.requiredTools {
                Text("Tools: \(requiredTools)")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            if let skillsNeeded = workOrder.skillsNeeded {
                Text("Skills: \(skillsNeeded)")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.cardPadding)
        .background(AppTheme.backgroundSecondary)
        .cornerRadius(AppTheme.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
    
}

struct WorkOrderDetailView_Previews: PreviewProvider {
    static var previews: some View {
        WorkOrderDetailView(workOrder: WorkOrder.sampleData[0])
    }
}
