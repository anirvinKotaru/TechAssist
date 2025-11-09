//
//  WorkOrder.swift
//  TechAssist2
//
//  Work Order Data Model
//

import Foundation
import SwiftUI

enum WorkOrderPriority: String, CaseIterable {
    case critical = "CRITICAL"
    case high = "HIGH"
    case medium = "MEDIUM"
    case low = "LOW"
    
    var displayName: String {
        switch self {
        case .critical:
            return "🚨 CRITICAL"
        case .high:
            return "HIGH"
        case .medium:
            return "MEDIUM"
        case .low:
            return "LOW"
        }
    }
    
    var color: Color {
        switch self {
        case .critical:
            return Color(red: 1.0, green: 0.2, blue: 0.2) // Red
        case .high:
            return Color(red: 1.0, green: 0.5, blue: 0.0) // Orange
        case .medium:
            return Color(red: 0.0, green: 0.5, blue: 1.0) // Blue
        case .low:
            return Color(red: 0.5, green: 0.5, blue: 0.5) // Gray
        }
    }
    
    var responseTime: String {
        switch self {
        case .critical:
            return "0-15 min"
        case .high:
            return "Under 1 hour"
        case .medium:
            return "2-8 hours"
        case .low:
            return "When available"
        }
    }
    
    var order: Int {
        switch self {
        case .critical: return 0
        case .high: return 1
        case .medium: return 2
        case .low: return 3
        }
    }
}

enum WorkOrderStatus: String, CaseIterable {
    case pending = "Pending"
    case inProgress = "In Progress"
    case completed = "Completed"
    case onHold = "On Hold"
}

struct WorkOrder: Identifiable, Hashable {
    let id: UUID
    var taskID: String // e.g., "WO-8472"
    var title: String
    var description: String
    var priority: WorkOrderPriority
    var status: WorkOrderStatus
    var assignedTechnician: String
    var createdAt: Date
    var dueDate: Date?
    var slaBreachDate: Date? // When SLA will be breached
    var timeSpent: TimeInterval // in seconds
    var timeEstimate: String? // e.g., "45 minutes"
    
    // Location Details
    var dataHall: String? // e.g., "Hall B"
    var rackNumber: String? // e.g., "A12"
    var serverPosition: String? // e.g., "U24"
    var locationCode: String? // e.g., "B-A12-U24"
    var location: String // General location description
    
    // Impact Metrics
    var usersAffected: Int?
    var businessImpact: String? // e.g., "$4,800/hour downtime"
    var systemsAffected: String? // e.g., "Customer XYZ Database"
    
    // Technical Requirements
    var requiredTools: String? // e.g., "PSU-750W-DELL, ESD strap"
    var skillsNeeded: String? // e.g., "HV Certified"
    var equipment: String?
    
    // QR Code
    var qrCodeData: String? // QR code data for verification
    
    // Issue Document
    var issueDocumentId: String?
    
    init(
        id: UUID = UUID(),
        taskID: String,
        title: String,
        description: String,
        priority: WorkOrderPriority,
        status: WorkOrderStatus,
        assignedTechnician: String,
        createdAt: Date = Date(),
        dueDate: Date? = nil,
        slaBreachDate: Date? = nil,
        timeSpent: TimeInterval = 0,
        timeEstimate: String? = nil,
        dataHall: String? = nil,
        rackNumber: String? = nil,
        serverPosition: String? = nil,
        locationCode: String? = nil,
        location: String,
        usersAffected: Int? = nil,
        businessImpact: String? = nil,
        systemsAffected: String? = nil,
        requiredTools: String? = nil,
        skillsNeeded: String? = nil,
        equipment: String? = nil,
        qrCodeData: String? = nil,
        issueDocumentId: String? = nil
    ) {
        self.id = id
        self.taskID = taskID
        self.title = title
        self.description = description
        self.priority = priority
        self.status = status
        self.assignedTechnician = assignedTechnician
        self.createdAt = createdAt
        self.dueDate = dueDate
        self.slaBreachDate = slaBreachDate
        self.timeSpent = timeSpent
        self.timeEstimate = timeEstimate
        self.dataHall = dataHall
        self.rackNumber = rackNumber
        self.serverPosition = serverPosition
        self.locationCode = locationCode
        self.location = location
        self.usersAffected = usersAffected
        self.businessImpact = businessImpact
        self.systemsAffected = systemsAffected
        self.requiredTools = requiredTools
        self.skillsNeeded = skillsNeeded
        self.equipment = equipment
        self.qrCodeData = qrCodeData ?? taskID // Default QR code is the task ID
        self.issueDocumentId = issueDocumentId
    }
    
    // Helper function to calculate SLA countdown
    func slaCountdown() -> String? {
        guard let slaDate = slaBreachDate else { return nil }
        let now = Date()
        
        if now >= slaDate {
            return "SLA BREACHED"
        }
        
        let timeRemaining = slaDate.timeIntervalSince(now)
        let hours = Int(timeRemaining) / 3600
        let minutes = (Int(timeRemaining) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m until breach"
        } else {
            return "\(minutes)m until breach"
        }
    }
    
    // Helper function for due date display
    func dueDateDisplay() -> String? {
        guard let dueDate = dueDate else { return nil }
        let calendar = Calendar.current
        
        if calendar.isDateInToday(dueDate) {
            return "Due Today"
        } else if calendar.isDateInTomorrow(dueDate) {
            return "Due Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return "Due \(formatter.string(from: dueDate))"
        }
    }
}

// Sample data
extension WorkOrder {
    static let sampleData: [WorkOrder] = [
        WorkOrder(
            taskID: "WO-8472",
            title: "Replace failed PSU in Rack A12",
            description: "Server shutting down due to PSU failure",
            priority: .critical,
            status: .inProgress,
            assignedTechnician: "Michael Bernando",
            dueDate: Date(),
            slaBreachDate: Calendar.current.date(byAdding: .minute, value: 15, to: Date()),
            timeSpent: 600,
            timeEstimate: "45 minutes",
            dataHall: "Hall B",
            rackNumber: "A12",
            serverPosition: "U24",
            locationCode: "B-A12-U24",
            location: "Data Center - Hall B, Rack A12",
            usersAffected: 2500,
            businessImpact: "$4,800/hour downtime",
            systemsAffected: "Customer XYZ Database",
            requiredTools: "PSU-750W-DELL, ESD strap",
            skillsNeeded: "HV Certified",
            equipment: "Server U24 - PSU Unit",
            qrCodeData: "WO-8472-B-A12-U24",
            issueDocumentId: ServerIssueDocumentLibrary.DocumentID.powerSupplyFailure.rawValue
        ),
        WorkOrder(
            taskID: "WO-9123",
            title: "Cooling System Failure - CRAC Unit",
            description: "Temperature spike detected. Risk of hardware damage if not addressed immediately.",
            priority: .critical,
            status: .pending,
            assignedTechnician: "Michael Bernando",
            dueDate: Date(),
            slaBreachDate: Calendar.current.date(byAdding: .minute, value: 10, to: Date()),
            timeEstimate: "30 minutes",
            dataHall: "Hall A",
            rackNumber: "N/A",
            serverPosition: "N/A",
            locationCode: "A-CRAC-5",
            location: "Data Center - Cooling Zone A",
            usersAffected: 5000,
            businessImpact: "$12,000/hour downtime",
            systemsAffected: "All systems in Hall A",
            requiredTools: "Multimeter, Refrigerant gauge",
            skillsNeeded: "HVAC Certified",
            equipment: "CRAC Unit #5",
            qrCodeData: "WO-9123-A-CRAC-5",
            issueDocumentId: ServerIssueDocumentLibrary.DocumentID.thermalEvent.rawValue
        ),
        WorkOrder(
            taskID: "WO-7891",
            title: "Network Backbone Failure",
            description: "Core router failure affecting multiple customers. Service degradation reported.",
            priority: .high,
            status: .pending,
            assignedTechnician: "Michael Bernando",
            dueDate: Calendar.current.date(byAdding: .hour, value: 1, to: Date()),
            slaBreachDate: Calendar.current.date(byAdding: .hour, value: 1, to: Date()),
            timeEstimate: "1 hour",
            dataHall: "Hall C",
            rackNumber: "C05",
            serverPosition: "U42",
            locationCode: "C-C05-U42",
            location: "Network Room - Main",
            usersAffected: 15000,
            businessImpact: "$25,000/hour downtime",
            systemsAffected: "Core Network Infrastructure",
            requiredTools: "Console cable, Replacement router",
            skillsNeeded: "Network Certified",
            equipment: "Core Router #1",
            qrCodeData: "WO-7891-C-C05-U42",
            issueDocumentId: ServerIssueDocumentLibrary.DocumentID.networkOutage.rawValue
        ),
        WorkOrder(
            taskID: "WO-6543",
            title: "Hardware Refresh - Server Rack 8",
            description: "Planned upgrade of servers in rack 8. Schedule during maintenance window.",
            priority: .medium,
            status: .pending,
            assignedTechnician: "Michael Bernando",
            dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()),
            slaBreachDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()),
            timeEstimate: "4 hours",
            dataHall: "Hall B",
            rackNumber: "B08",
            serverPosition: "U1-U42",
            locationCode: "B-B08-FULL",
            location: "Data Center - Rack 8",
            usersAffected: 0,
            businessImpact: "Planned maintenance",
            systemsAffected: "Server Array #8",
            requiredTools: "Server lift, ESD equipment",
            skillsNeeded: "Server Hardware Certified",
            equipment: "Server Array #8",
            qrCodeData: "WO-6543-B-B08",
            issueDocumentId: ServerIssueDocumentLibrary.DocumentID.firmwareMismatch.rawValue
        ),
        WorkOrder(
            taskID: "WO-5234",
            title: "Preventive Maintenance - Battery Testing",
            description: "Routine UPS battery testing and replacement if needed.",
            priority: .medium,
            status: .pending,
            assignedTechnician: "Michael Bernando",
            dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()),
            slaBreachDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()),
            timeEstimate: "2 hours",
            dataHall: "Hall A",
            rackNumber: "N/A",
            serverPosition: "N/A",
            locationCode: "A-UPS-3",
            location: "UPS Room - Main",
            usersAffected: 0,
            businessImpact: "Preventive maintenance",
            systemsAffected: "UPS System #3",
            requiredTools: "Battery tester, Multimeter",
            skillsNeeded: "Electrical Certified",
            equipment: "UPS System #3",
            qrCodeData: "WO-5234-A-UPS-3",
            issueDocumentId: ServerIssueDocumentLibrary.DocumentID.raidDegradation.rawValue
        ),
        WorkOrder(
            taskID: "WO-4123",
            title: "Rack Cleaning and Organization",
            description: "General cleaning and cable management in rack 15.",
            priority: .low,
            status: .pending,
            assignedTechnician: "Michael Bernando",
            timeEstimate: "1 hour",
            dataHall: "Hall C",
            rackNumber: "C15",
            serverPosition: "N/A",
            locationCode: "C-C15",
            location: "Data Center - Rack 15",
            usersAffected: 0,
            businessImpact: "No impact",
            systemsAffected: "N/A",
            requiredTools: "Cleaning supplies, Cable ties",
            skillsNeeded: "General maintenance",
            equipment: "Rack C15",
            qrCodeData: "WO-4123-C-C15"
        ),
        WorkOrder(
            taskID: "WO-3456",
            title: "Documentation Update",
            description: "Update network diagrams and equipment inventory.",
            priority: .low,
            status: .completed,
            assignedTechnician: "Michael Bernando",
            timeSpent: 1800,
            timeEstimate: "30 minutes",
            location: "Office - Documentation",
            qrCodeData: "WO-3456"
        )
    ]
}
