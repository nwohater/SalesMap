//
//  FollowUpView.swift
//  SalesMap
//
//  Created by Brandon Lackey on 9/15/25.
//

import SwiftUI

struct FollowUpView: View {
    @EnvironmentObject var dataService: DataService
    @State private var searchText = ""
    @State private var selectedPriorityFilter: FollowUpPriority?
    @State private var showUrgentOnly = false
    @State private var showingFilters = false
    @State private var selectedFollowUp: FollowUp?
    
    var filteredAndSortedFollowUps: [FollowUp] {
        var followUps = dataService.getPendingFollowUps()
        
        // Apply search filter
        if !searchText.isEmpty {
            followUps = followUps.filter { followUp in
                if let customer = dataService.getCustomer(by: followUp.customerId) {
                    return customer.name.localizedCaseInsensitiveContains(searchText) ||
                           customer.company.localizedCaseInsensitiveContains(searchText) ||
                           (followUp.notes?.localizedCaseInsensitiveContains(searchText) ?? false)
                }
                return false
            }
        }
        
        // Apply priority filter
        if let priorityFilter = selectedPriorityFilter {
            followUps = followUps.filter { $0.priority == priorityFilter }
        }
        
        // Apply urgent filter (overdue + due today)
        if showUrgentOnly {
            let calendar = Calendar.current
            let now = Date()
            let endOfToday = calendar.dateInterval(of: .day, for: now)?.end ?? now
            followUps = followUps.filter { $0.followUpDate <= endOfToday }
        }
        
        return followUps
    }
    
    var overdueCount: Int {
        dataService.getOverdueFollowUps().count
    }

    var urgentCount: Int {
        dataService.getUrgentFollowUps().count
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Urgent banner (overdue + due today)
                if urgentCount > 0 {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text("\(urgentCount) urgent follow-up\(urgentCount == 1 ? "" : "s") (overdue or due today)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Button("Show") {
                            showUrgentOnly = true
                            showingFilters = true
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                }
                
                // Filter Controls
                if showingFilters {
                    FollowUpFilterControlsView(
                        selectedPriorityFilter: $selectedPriorityFilter,
                        showUrgentOnly: $showUrgentOnly,
                        followUpCount: filteredAndSortedFollowUps.count
                    )
                    .padding()
                    .background(Color(.systemGray6))
                }
                
                // Follow-ups list
                if filteredAndSortedFollowUps.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        Text("All caught up!")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("No pending follow-ups at this time.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(filteredAndSortedFollowUps) { followUp in
                        FollowUpRow(followUp: followUp) {
                            selectedFollowUp = followUp
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search follow-ups...")
                }
            }
            .navigationTitle("Follow-ups (\(filteredAndSortedFollowUps.count))")
            .navigationBarItems(
                trailing: Button(action: {
                    withAnimation {
                        showingFilters.toggle()
                    }
                }) {
                    Image(systemName: showingFilters ? "line.horizontal.3.decrease.circle.fill" : "line.horizontal.3.decrease.circle")
                        .foregroundColor(.blue)
                }
            )
            .sheet(item: $selectedFollowUp) { followUp in
                FollowUpDetailView(followUp: followUp)
            }
        }
    }
}

struct FollowUpRow: View {
    let followUp: FollowUp
    let onTap: () -> Void
    @EnvironmentObject var dataService: DataService
    
    var customer: Customer? {
        dataService.getCustomer(by: followUp.customerId)
    }
    
    var isOverdue: Bool {
        followUp.followUpDate < Date()
    }
    
    var timeUntilDue: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: followUp.followUpDate, relativeTo: Date())
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Customer info and priority
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        if let customer = customer {
                            Text(customer.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(customer.company)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Priority badge
                    Text(followUp.priority.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(priorityColor.opacity(0.1))
                        .foregroundColor(priorityColor)
                        .cornerRadius(8)
                }
                
                // Due date and notes
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: isOverdue ? "clock.badge.exclamationmark" : "clock")
                            .font(.caption)
                            .foregroundColor(isOverdue ? .red : .blue)
                        Text(timeUntilDue)
                            .font(.caption)
                            .foregroundColor(isOverdue ? .red : .blue)
                    }
                    
                    Spacer()
                    
                    if let notes = followUp.notes, !notes.isEmpty {
                        Image(systemName: "note.text")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                // Notes preview
                if let notes = followUp.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .padding(.top, 4)
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
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

struct FollowUpFilterControlsView: View {
    @Binding var selectedPriorityFilter: FollowUpPriority?
    @Binding var showUrgentOnly: Bool
    let followUpCount: Int
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("\(followUpCount) follow-up\(followUpCount == 1 ? "" : "s")")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            VStack(spacing: 8) {
                HStack {
                    Text("Priority:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Picker("Priority", selection: $selectedPriorityFilter) {
                        Text("All Priorities").tag(nil as FollowUpPriority?)
                        ForEach(FollowUpPriority.allCases, id: \.self) { priority in
                            Text(priority.displayName).tag(priority as FollowUpPriority?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Toggle("Urgent only (overdue + due today)", isOn: $showUrgentOnly)
                    .font(.subheadline)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

#Preview {
    FollowUpView()
        .environmentObject(DataService())
}
