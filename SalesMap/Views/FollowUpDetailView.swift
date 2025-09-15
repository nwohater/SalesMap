//
//  FollowUpDetailView.swift
//  SalesMap
//
//  Created by Brandon Lackey on 9/15/25.
//

import SwiftUI

struct FollowUpDetailView: View {
    let followUp: FollowUp
    @EnvironmentObject var dataService: DataService
    @Environment(\.dismiss) private var dismiss
    @State private var showingCustomerDetail = false
    @State private var showingCompleteConfirmation = false
    @State private var showingCreateNewFollowUp = false
    @State private var completionNotes = ""
    @State private var newFollowUpDate = Date()
    @State private var newFollowUpNotes = ""
    @State private var newFollowUpPriority: FollowUpPriority = .medium
    
    var customer: Customer? {
        dataService.getCustomer(by: followUp.customerId)
    }
    
    var relatedVisit: Visit? {
        if let visitId = followUp.relatedVisitId {
            return dataService.visits.first { $0.id == visitId }
        }
        return nil
    }
    
    var isOverdue: Bool {
        followUp.followUpDate < Date()
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Customer Section
                    if let customer = customer {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Customer")
                                .font(.headline)
                            
                            Button(action: {
                                showingCustomerDetail = true
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(customer.name)
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                        Text(customer.company)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text(customer.address)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    // Follow-up Details
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Follow-up Details")
                            .font(.headline)
                        
                        VStack(spacing: 16) {
                            // Priority and Due Date
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Priority")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(followUp.priority.displayName)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(priorityColor.opacity(0.1))
                                        .foregroundColor(priorityColor)
                                        .cornerRadius(8)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Due Date")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    HStack(spacing: 4) {
                                        if isOverdue {
                                            Image(systemName: "exclamationmark.triangle.fill")
                                                .font(.caption)
                                                .foregroundColor(.red)
                                        }
                                        Text(followUp.followUpDate, style: .date)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(isOverdue ? .red : .primary)
                                    }
                                }
                            }
                            
                            // Notes
                            if let notes = followUp.notes, !notes.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Notes")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(notes)
                                        .font(.body)
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                }
                            }
                            
                            // Created Date
                            HStack {
                                Text("Created:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(followUp.createdAt, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                    
                    // Related Visit
                    if let visit = relatedVisit {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Related Visit")
                                .font(.headline)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(visit.purpose.displayName)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Spacer()
                                    Text(visit.checkInTime, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                if let visitNotes = visit.notes, !visitNotes.isEmpty {
                                    Text(visitNotes)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(3)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            showingCompleteConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Mark as Complete")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }

                        Button(action: {
                            showingCreateNewFollowUp = true
                        }) {
                            HStack {
                                Image(systemName: "arrow.right.circle.fill")
                                Text("Complete & Create New Follow-up")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
            .navigationTitle("Follow-up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showingCustomerDetail) {
                if let customer = customer {
                    CustomerDetailView(customer: customer)
                }
            }
            .sheet(isPresented: $showingCompleteConfirmation) {
                CompleteFollowUpSheet(
                    followUp: followUp,
                    completionNotes: $completionNotes,
                    onComplete: { notes in
                        Task {
                            await dataService.completeFollowUp(followUp.id, completionNotes: notes)
                            dismiss()
                        }
                    }
                )
            }
            .sheet(isPresented: $showingCreateNewFollowUp) {
                CreateNewFollowUpSheet(
                    followUp: followUp,
                    completionNotes: $completionNotes,
                    newFollowUpDate: $newFollowUpDate,
                    newFollowUpNotes: $newFollowUpNotes,
                    newFollowUpPriority: $newFollowUpPriority,
                    onCompleteAndCreate: { completionNotes, newDate, newNotes, newPriority in
                        Task {
                            await dataService.completeAndCreateNewFollowUp(
                                currentFollowUpId: followUp.id,
                                completionNotes: completionNotes,
                                newFollowUpDate: newDate,
                                newNotes: newNotes,
                                newPriority: newPriority
                            )
                            dismiss()
                        }
                    }
                )
            }
        }
    }
    
    private var priorityColor: Color {
        switch followUp.priority {
        case .low:
            return .blue
        case .medium:
            return .orange
        case .high:
            return .red
        case .urgent:
            return .purple
        }
    }
}

// MARK: - Complete Follow-up Sheet
struct CompleteFollowUpSheet: View {
    let followUp: FollowUp
    @Binding var completionNotes: String
    let onComplete: (String?) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Complete Follow-up")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Add completion notes for this follow-up:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Completion Notes")
                        .font(.headline)

                    TextEditor(text: $completionNotes)
                        .frame(minHeight: 120)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }

                Spacer()

                Button(action: {
                    onComplete(completionNotes.isEmpty ? nil : completionNotes)
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Complete Follow-up")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Create New Follow-up Sheet
struct CreateNewFollowUpSheet: View {
    let followUp: FollowUp
    @Binding var completionNotes: String
    @Binding var newFollowUpDate: Date
    @Binding var newFollowUpNotes: String
    @Binding var newFollowUpPriority: FollowUpPriority
    let onCompleteAndCreate: (String?, Date, String?, FollowUpPriority) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Complete & Create New Follow-up")
                        .font(.title2)
                        .fontWeight(.bold)

                    // Completion Notes Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Completion Notes for Current Follow-up")
                            .font(.headline)

                        TextEditor(text: $completionNotes)
                            .frame(minHeight: 80)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }

                    Divider()

                    // New Follow-up Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("New Follow-up Details")
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Follow-up Date")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            DatePicker("", selection: $newFollowUpDate, in: Date()..., displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Priority")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Picker("Priority", selection: $newFollowUpPriority) {
                                ForEach(FollowUpPriority.allCases, id: \.self) { priority in
                                    Text(priority.displayName).tag(priority)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.subheadline)
                                .fontWeight(.medium)

                            TextEditor(text: $newFollowUpNotes)
                                .frame(minHeight: 80)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                    }

                    Button(action: {
                        onCompleteAndCreate(
                            completionNotes.isEmpty ? nil : completionNotes,
                            newFollowUpDate,
                            newFollowUpNotes.isEmpty ? nil : newFollowUpNotes,
                            newFollowUpPriority
                        )
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                            Text("Complete & Create New")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    FollowUpDetailView(followUp: FollowUp.sampleFollowUps[0])
        .environmentObject(DataService())
}
