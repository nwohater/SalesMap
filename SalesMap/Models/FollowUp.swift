//
//  FollowUp.swift
//  SalesMap
//
//  Created by Brandon Lackey on 9/15/25.
//

import Foundation

struct FollowUp: Codable, Identifiable {
    let id: String
    let customerId: String
    let userId: String
    let followUpDate: Date
    let notes: String?
    let priority: FollowUpPriority
    let isCompleted: Bool
    let createdAt: Date
    let completedAt: Date?
    let completionNotes: String?
    let relatedVisitId: String?
    
    enum CodingKeys: String, CodingKey {
        case id, notes, priority, createdAt
        case customerId = "customer_id"
        case userId = "user_id"
        case followUpDate = "follow_up_date"
        case isCompleted = "is_completed"
        case completedAt = "completed_at"
        case completionNotes = "completion_notes"
        case relatedVisitId = "related_visit_id"
    }
}

enum FollowUpPriority: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case urgent = "Urgent"
    
    var displayName: String {
        return self.rawValue
    }
    
    var color: String {
        switch self {
        case .low:
            return "blue"
        case .medium:
            return "orange"
        case .high:
            return "red"
        case .urgent:
            return "purple"
        }
    }
    
    var sortOrder: Int {
        switch self {
        case .urgent:
            return 0
        case .high:
            return 1
        case .medium:
            return 2
        case .low:
            return 3
        }
    }
}

// MARK: - Sample Data
extension FollowUp {
    static let sampleFollowUps: [FollowUp] = [
        FollowUp(
            id: "followup_001",
            customerId: "12345",
            userId: "rep_456",
            followUpDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date(),
            notes: "Follow up on Q4 inventory pricing discussion",
            priority: .high,
            isCompleted: false,
            createdAt: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
            completedAt: nil,
            completionNotes: nil,
            relatedVisitId: "visit_001"
        ),
        FollowUp(
            id: "followup_002",
            customerId: "12346",
            userId: "rep_456",
            followUpDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
            notes: "Send product demo video and pricing sheet",
            priority: .medium,
            isCompleted: false,
            createdAt: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            completedAt: nil,
            completionNotes: nil,
            relatedVisitId: "visit_002"
        ),
        FollowUp(
            id: "followup_003",
            customerId: "12347",
            userId: "rep_456",
            followUpDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            notes: "Check if they received the contract documents",
            priority: .urgent,
            isCompleted: false,
            createdAt: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
            completedAt: nil,
            completionNotes: nil,
            relatedVisitId: nil
        ),
        FollowUp(
            id: "followup_004",
            customerId: "12348",
            userId: "rep_456",
            followUpDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date(),
            notes: "Schedule implementation kickoff meeting",
            priority: .medium,
            isCompleted: false,
            createdAt: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            completedAt: nil,
            completionNotes: nil,
            relatedVisitId: "visit_003"
        ),
        FollowUp(
            id: "followup_005",
            customerId: "12349",
            userId: "rep_456",
            followUpDate: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
            notes: "Thank you call for successful implementation",
            priority: .low,
            isCompleted: true,
            createdAt: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
            completedAt: Calendar.current.date(byAdding: .day, value: -5, to: Date()),
            completionNotes: "Called customer, they were very satisfied with the implementation. Mentioned they may need additional training in Q1.",
            relatedVisitId: "visit_004"
        )
    ]
}
