//
//  WorkOrderListView.swift
//  TechAssist2
//
//  Work Order List View - Adapted from Add Meals Screen
//

import SwiftUI

struct WorkOrderListView: View {
    @ObservedObject var firebaseService = FirebaseService.shared
    @State private var selectedDate = Date()
    @State private var selectedDayIndex = 0
    
    let daysOfWeek = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
    
    var workOrders: [WorkOrder] {
        firebaseService.workOrders.isEmpty ? WorkOrder.sampleData : firebaseService.workOrders
    }
    
    init() {
        // Initialize selectedDayIndex based on current day
        let weekday = Calendar.current.component(.weekday, from: Date())
        // Map weekday (1=Sunday, 2=Monday, etc.) to index (0=Monday, 6=Sunday)
        _selectedDayIndex = State(initialValue: (weekday + 5) % 7)
    }
    
    var filteredWorkOrders: [WorkOrder] {
        workOrders.filter { workOrder in
            Calendar.current.isDate(workOrder.createdAt, inSameDayAs: selectedDate)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundPrimary.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        HStack {
                            Spacer()
                            
                            Text("Work Orders")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 60)
                        .padding(.bottom, 20)
                        
                        // Date Selector
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text(dateString)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            
                            // Day Selector
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(0..<7) { index in
                                        let date = Calendar.current.date(byAdding: .day, value: index - selectedDayIndex, to: selectedDate) ?? Date()
                                        let weekday = Calendar.current.component(.weekday, from: date)
                                        // Map weekday (1=Sunday, 2=Monday, etc.) to our array (0=Monday, 6=Sunday)
                                        let dayIndex = (weekday + 5) % 7
                                        let dayName = daysOfWeek[dayIndex]
                                        let dayNumber = Calendar.current.component(.day, from: date)
                                        let isSelected = index == selectedDayIndex
                                        
                                        Button(action: {
                                            selectedDayIndex = index
                                            selectedDate = date
                                        }) {
                                            VStack(spacing: 4) {
                                                Text(dayName)
                                                    .font(.system(size: 10, weight: .regular))
                                                    .foregroundColor(isSelected ? AppTheme.accentPrimary : AppTheme.textSecondary)
                                                
                                                Text("\(dayNumber)")
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundColor(isSelected ? AppTheme.accentPrimary : AppTheme.textPrimary)
                                            }
                                            .frame(width: 48, height: 56)
                                            .background(isSelected ? AppTheme.accentPrimary.opacity(0.1) : Color.white)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(isSelected ? AppTheme.accentPrimary : AppTheme.cardBorderColor, lineWidth: isSelected ? 1.5 : 1)
                                            )
                                            .cornerRadius(10)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Work Order Categories/List
                        VStack(spacing: 16) {
                            ForEach(WorkOrderPriority.allCases, id: \.self) { priority in
                                let ordersForPriority = filteredWorkOrders.filter { $0.priority == priority }
                                
                                if !ordersForPriority.isEmpty {
                                    WorkOrderCategoryCard(
                                        priority: priority,
                                        workOrders: ordersForPriority,
                                        recommendedCount: ordersForPriority.count
                                    )
                                }
                            }
                            
                            // Add New Work Order Card
                            Button(action: {}) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("New Work Order")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(AppTheme.textPrimary)
                                        
                                        Text("Create a new work order")
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("+ Add")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(AppTheme.accentPrimary)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 6)
                                        .background(AppTheme.accentPrimary.opacity(0.1))
                                        .cornerRadius(6)
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
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMM yyyy"
        return formatter.string(from: selectedDate).uppercased()
    }
}

struct WorkOrderCategoryCard: View {
    let priority: WorkOrderPriority
    let workOrders: [WorkOrder]
    let recommendedCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(priority.displayName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("\(recommendedCount) work order\(recommendedCount == 1 ? "" : "s")")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Text("+ADD")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(priority.color)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(priority.color.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            
            // Work Order Items
            ForEach(workOrders) { workOrder in
                NavigationLink(destination: WorkOrderDetailView(workOrder: workOrder)) {
                    HStack(spacing: 12) {
                        // Priority Indicator
                        Circle()
                            .fill(priority.color)
                            .frame(width: 8, height: 8)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(workOrder.title)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Text(workOrder.location)
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding(.vertical, 8)
                }
            }
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

struct WorkOrderListView_Previews: PreviewProvider {
    static var previews: some View {
        WorkOrderListView()
    }
}
