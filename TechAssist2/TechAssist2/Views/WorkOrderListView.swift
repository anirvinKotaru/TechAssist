//
//  WorkOrderListView.swift
//  TechAssist2
//
//  Work Order List View - Adapted from Add Meals Screen
//

import SwiftUI

struct WorkOrderListView: View {
    @ObservedObject var firebaseService = FirebaseService.shared
    
    var workOrders: [WorkOrder] {
        firebaseService.workOrders.isEmpty ? WorkOrder.sampleData : firebaseService.workOrders
    }
    
    var filteredWorkOrders: [WorkOrder] {
        // Show all non-completed work orders
        workOrders.filter { $0.status != .completed }
            .sorted { first, second in
                if first.priority.order != second.priority.order {
                    return first.priority.order < second.priority.order
                }
                return first.createdAt > second.createdAt
            }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundPrimary.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Header
                        Text("Work Orders")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                        
                        // Work Order List
                        VStack(spacing: 8) {
                            ForEach(WorkOrderPriority.allCases, id: \.self) { priority in
                                let ordersForPriority = filteredWorkOrders.filter { $0.priority == priority }
                                
                                if !ordersForPriority.isEmpty {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(priority.displayName)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(priority.color)
                                            .padding(.horizontal, 16)
                                        
                                        ForEach(ordersForPriority) { workOrder in
                                            NavigationLink(destination: WorkOrderDetailView(workOrder: workOrder)) {
                                                SimpleWorkOrderCard(workOrder: workOrder)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            if filteredWorkOrders.isEmpty {
                                Text("No work orders")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(AppTheme.textSecondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 32)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
}

struct SimpleWorkOrderCard: View {
    let workOrder: WorkOrder
    
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(workOrder.priority.color)
                .frame(width: 3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(workOrder.taskID)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(AppTheme.textSecondary)
                
                Text(workOrder.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)
            }
            
            Spacer()
            
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

struct WorkOrderListView_Previews: PreviewProvider {
    static var previews: some View {
        WorkOrderListView()
    }
}
