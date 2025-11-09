//
//  PriorityView.swift
//  TechAssist2
//
//  Priority/Leaderboard View - Adapted from Add Friends Screen
//

import SwiftUI

struct PriorityView: View {
    @ObservedObject var firebaseService = FirebaseService.shared
    
    var workOrders: [WorkOrder] {
        firebaseService.workOrders.isEmpty ? WorkOrder.sampleData : firebaseService.workOrders
    }
    
    var criticalPriorityOrders: [WorkOrder] {
        workOrders.filter { $0.priority == .critical && $0.status != .completed }
            .sorted { $0.dueDate ?? Date.distantFuture < $1.dueDate ?? Date.distantFuture }
    }
    
    var highPriorityOrders: [WorkOrder] {
        workOrders.filter { $0.priority == .high && $0.status != .completed }
            .sorted { $0.dueDate ?? Date.distantFuture < $1.dueDate ?? Date.distantFuture }
    }
    
    var mediumPriorityOrders: [WorkOrder] {
        workOrders.filter { $0.priority == .medium && $0.status != .completed }
    }
    
    var lowPriorityOrders: [WorkOrder] {
        workOrders.filter { $0.priority == .low && $0.status != .completed }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundPrimary.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        HStack {
                            Button(action: {}) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                            
                            Spacer()
                            
                            Text("PRIORITY QUEUE")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.clear)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 60)
                        .padding(.bottom, 20)
                        
                        // Top Priority Section
                        if !criticalPriorityOrders.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("TOP PRIORITY")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                                
                                HStack(spacing: 16) {
                                    ForEach(Array(criticalPriorityOrders.prefix(3).enumerated()), id: \.element.id) { index, order in
                                        PriorityCard(
                                            workOrder: order,
                                            rank: index + 1,
                                            isTop: index == 0
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Priority Leaderboard
                        VStack(alignment: .leading, spacing: 16) {
                            Text("PRIORITY QUEUE")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            // Critical Priority List
                            if !criticalPriorityOrders.isEmpty {
                                PrioritySection(
                                    title: "🚨 CRITICAL PRIORITY",
                                    orders: criticalPriorityOrders,
                                    color: WorkOrderPriority.critical.color
                                )
                            }
                            
                            // High Priority List
                            if !highPriorityOrders.isEmpty {
                                PrioritySection(
                                    title: "HIGH PRIORITY",
                                    orders: highPriorityOrders,
                                    color: WorkOrderPriority.high.color
                                )
                            }
                            
                            // Medium Priority List
                            if !mediumPriorityOrders.isEmpty {
                                PrioritySection(
                                    title: "MEDIUM PRIORITY",
                                    orders: mediumPriorityOrders,
                                    color: WorkOrderPriority.medium.color
                                )
                            }
                            
                            // Low Priority List
                            if !lowPriorityOrders.isEmpty {
                                PrioritySection(
                                    title: "LOW PRIORITY",
                                    orders: lowPriorityOrders,
                                    color: WorkOrderPriority.low.color
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Assign Work Order Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Assign Work Order")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Text("Enter work order details")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(AppTheme.textSecondary)
                            
                            TextField("Work order details go here", text: .constant(""))
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(12)
                                .background(AppTheme.backgroundSecondary)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct PriorityCard: View {
    let workOrder: WorkOrder
    let rank: Int
    let isTop: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(AppTheme.backgroundSecondary)
                    .frame(width: 60, height: 60)
                
                if isTop {
                    Circle()
                        .fill(WorkOrderPriority.high.color)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Text("\(rank)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .offset(x: 25, y: -25)
                }
                
                Image(systemName: "wrench.and.screwdriver.fill")
                    .font(.system(size: 24))
                    .foregroundColor(workOrder.priority.color)
            }
            
            Text(workOrder.title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            Text("Priority \(rank)")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct PrioritySection: View {
    let title: String
    let orders: [WorkOrder]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(color)
            
            ForEach(Array(orders.enumerated()), id: \.element.id) { index, order in
                NavigationLink(destination: WorkOrderDetailView(workOrder: order)) {
                    HStack(spacing: 12) {
                        // Rank Number
                        Text("\(index + 1)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(color)
                            .frame(width: 30)
                        
                        // Icon
                        Circle()
                            .fill(color.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "doc.text.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(color)
                            )
                        
                        // Details
                        VStack(alignment: .leading, spacing: 4) {
                            Text(order.title)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Text(order.location)
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        
                        Spacer()
                        
                        // Points/Status
                        if let dueDate = order.dueDate {
                            Text("\(Int(dueDate.timeIntervalSinceNow / 3600)) hrs")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(color)
                        }
                    }
                    .padding(AppTheme.cardPadding)
                    .background(AppTheme.backgroundSecondary)
                    .cornerRadius(AppTheme.cardCornerRadius)
                }
            }
        }
    }
}

struct PriorityView_Previews: PreviewProvider {
    static var previews: some View {
        PriorityView()
            .preferredColorScheme(.dark)
    }
}
