//
//  FirebaseService.swift
//  TechAssist2
//
//  Firebase Service for Data Management
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import Combine

class FirebaseService: ObservableObject {
    static let shared = FirebaseService()
    
    private var db: Firestore?
    private var cancellables = Set<AnyCancellable>()
    
    @Published var workOrders: [WorkOrder] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var isInitialized = false
    
    private init() {
        // Firebase initialization is handled in TechAssist2App
        // We'll initialize Firestore when Firebase is configured
    }
    
    func initialize() {
        guard !isInitialized else { return }
        guard FirebaseApp.app() != nil else {
            print("Warning: Firebase not initialized. Call FirebaseApp.configure() first.")
            return
        }
        db = Firestore.firestore()
        isInitialized = true
    }
    
    // MARK: - Work Orders
    
    /// Fetch all work orders from Firestore
    func fetchWorkOrders(userId: String? = nil) {
        guard let db = db else {
            initialize()
            guard let db = db else {
                errorMessage = "Firestore not initialized"
                return
            }
            self.db = db
            // Need to return here after initialization
            fetchWorkOrders(userId: userId)
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        var query: Query = db.collection("workOrders")
        
        // Filter by user if provided
        if let userId = userId {
            query = query.whereField("assignedTechnicianId", isEqualTo: userId)
        }
        
        query.order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        self?.workOrders = []
                        return
                    }
                    
                    self?.workOrders = documents.compactMap { document -> WorkOrder? in
                        try? self?.parseWorkOrder(from: document)
                    }
                }
            }
    }
    
    /// Add a new work order to Firestore
    func addWorkOrder(_ workOrder: WorkOrder) async throws {
        guard let db = db else {
            throw NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firestore not initialized"])
        }
        
        let data = try encodeWorkOrder(workOrder)
        try await db.collection("workOrders").document(workOrder.id.uuidString).setData(data)
    }
    
    /// Update an existing work order
    func updateWorkOrder(_ workOrder: WorkOrder) async throws {
        guard let db = db else {
            throw NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firestore not initialized"])
        }
        
        let data = try encodeWorkOrder(workOrder)
        try await db.collection("workOrders").document(workOrder.id.uuidString).updateData(data)
    }
    
    /// Delete a work order
    func deleteWorkOrder(_ workOrder: WorkOrder) async throws {
        guard let db = db else {
            throw NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firestore not initialized"])
        }
        
        try await db.collection("workOrders").document(workOrder.id.uuidString).delete()
    }
    
    // MARK: - User Management
    
    /// Create or update user profile in Firestore
    func updateUserProfile(userId: String, email: String, name: String) async throws {
        guard let db = db else {
            throw NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firestore not initialized"])
        }
        
        let userData: [String: Any] = [
            "email": email,
            "name": name,
            "updatedAt": Timestamp(date: Date())
        ]
        
        try await db.collection("users").document(userId).setData(userData, merge: true)
    }
    
    /// Get user profile from Firestore
    func getUserProfile(userId: String) async throws -> [String: Any]? {
        guard let db = db else {
            throw NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firestore not initialized"])
        }
        
        let document = try await db.collection("users").document(userId).getDocument()
        return document.data()
    }
    
    // MARK: - Authentication Integration
    // Note: Authentication removed - using Firebase without Auth0
    
    // MARK: - Helper Methods
    
    private func parseWorkOrder(from document: QueryDocumentSnapshot) throws -> WorkOrder {
        let data = document.data()
        
        guard let idString = data["id"] as? String,
              let id = UUID(uuidString: idString),
              let title = data["title"] as? String,
              let description = data["description"] as? String,
              let priorityString = data["priority"] as? String,
              let priority = WorkOrderPriority(rawValue: priorityString),
              let statusString = data["status"] as? String,
              let status = WorkOrderStatus(rawValue: statusString),
              let assignedTechnician = data["assignedTechnician"] as? String,
              let location = data["location"] as? String else {
            throw NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid work order data"])
        }
        
        // taskID can fallback to document ID if not present
        let taskID = (data["taskID"] as? String) ?? document.documentID
        
        let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        let dueDate = (data["dueDate"] as? Timestamp)?.dateValue()
        let slaBreachDate = (data["slaBreachDate"] as? Timestamp)?.dateValue()
        let timeSpent = data["timeSpent"] as? Double ?? 0
        let timeEstimate = data["timeEstimate"] as? String
        let equipment = data["equipment"] as? String
        let dataHall = data["dataHall"] as? String
        let rackNumber = data["rackNumber"] as? String
        let serverPosition = data["serverPosition"] as? String
        let locationCode = data["locationCode"] as? String
        let usersAffected = data["usersAffected"] as? Int
        let businessImpact = data["businessImpact"] as? String
        let systemsAffected = data["systemsAffected"] as? String
        let requiredTools = data["requiredTools"] as? String
        let skillsNeeded = data["skillsNeeded"] as? String
        let qrCodeData = data["qrCodeData"] as? String
        let issueDocumentId = data["issueDocumentId"] as? String
        
        return WorkOrder(
            id: id,
            taskID: taskID,
            title: title,
            description: description,
            priority: priority,
            status: status,
            assignedTechnician: assignedTechnician,
            createdAt: createdAt,
            dueDate: dueDate,
            slaBreachDate: slaBreachDate,
            timeSpent: timeSpent,
            timeEstimate: timeEstimate,
            dataHall: dataHall,
            rackNumber: rackNumber,
            serverPosition: serverPosition,
            locationCode: locationCode,
            location: location,
            usersAffected: usersAffected,
            businessImpact: businessImpact,
            systemsAffected: systemsAffected,
            requiredTools: requiredTools,
            skillsNeeded: skillsNeeded,
            equipment: equipment,
            qrCodeData: qrCodeData,
            issueDocumentId: issueDocumentId
        )
    }
    
    private func encodeWorkOrder(_ workOrder: WorkOrder) throws -> [String: Any] {
        var data: [String: Any] = [
            "id": workOrder.id.uuidString,
            "taskID": workOrder.taskID,
            "title": workOrder.title,
            "description": workOrder.description,
            "priority": workOrder.priority.rawValue,
            "status": workOrder.status.rawValue,
            "assignedTechnician": workOrder.assignedTechnician,
            "createdAt": Timestamp(date: workOrder.createdAt),
            "timeSpent": workOrder.timeSpent,
            "location": workOrder.location
        ]
        
        if let dueDate = workOrder.dueDate {
            data["dueDate"] = Timestamp(date: dueDate)
        }
        
        if let slaBreachDate = workOrder.slaBreachDate {
            data["slaBreachDate"] = Timestamp(date: slaBreachDate)
        }
        
        if let timeEstimate = workOrder.timeEstimate {
            data["timeEstimate"] = timeEstimate
        }
        
        if let equipment = workOrder.equipment {
            data["equipment"] = equipment
        }
        
        if let dataHall = workOrder.dataHall {
            data["dataHall"] = dataHall
        }
        
        if let rackNumber = workOrder.rackNumber {
            data["rackNumber"] = rackNumber
        }
        
        if let serverPosition = workOrder.serverPosition {
            data["serverPosition"] = serverPosition
        }
        
        if let locationCode = workOrder.locationCode {
            data["locationCode"] = locationCode
        }
        
        if let usersAffected = workOrder.usersAffected {
            data["usersAffected"] = usersAffected
        }
        
        if let businessImpact = workOrder.businessImpact {
            data["businessImpact"] = businessImpact
        }
        
        if let systemsAffected = workOrder.systemsAffected {
            data["systemsAffected"] = systemsAffected
        }
        
        if let requiredTools = workOrder.requiredTools {
            data["requiredTools"] = requiredTools
        }
        
        if let skillsNeeded = workOrder.skillsNeeded {
            data["skillsNeeded"] = skillsNeeded
        }
        
        if let qrCodeData = workOrder.qrCodeData {
            data["qrCodeData"] = qrCodeData
        }
        
        if let issueDocumentId = workOrder.issueDocumentId {
            data["issueDocumentId"] = issueDocumentId
        }
        
        return data
    }
}
