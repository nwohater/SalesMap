//
//  VisitHistoryView.swift
//  SalesMap
//
//  Created by Brandon Lackey on 9/11/25.
//

import SwiftUI

struct VisitHistoryView: View {
    @EnvironmentObject var dataService: DataService
    @State private var searchText = ""
    @State private var selectedPurposeFilter: VisitPurpose?
    @State private var selectedDateRange: DateRange = .all
    @State private var showingFilters = false

    enum DateRange: String, CaseIterable {
        case all = "All Time"
        case today = "Today"
        case thisWeek = "This Week"
        case thisMonth = "This Month"
    }

    var filteredAndSortedVisits: [Visit] {
        var visits = dataService.visits

        // Apply search filter
        if !searchText.isEmpty {
            visits = visits.filter { visit in
                if let customer = dataService.getCustomer(by: visit.customerId) {
                    return customer.name.localizedCaseInsensitiveContains(searchText) ||
                           customer.company.localizedCaseInsensitiveContains(searchText) ||
                           visit.purpose.rawValue.localizedCaseInsensitiveContains(searchText) ||
                           (visit.notes?.localizedCaseInsensitiveContains(searchText) ?? false)
                }
                return false
            }
        }

        // Apply purpose filter
        if let purposeFilter = selectedPurposeFilter {
            visits = visits.filter { $0.purpose == purposeFilter }
        }

        // Apply date range filter
        let calendar = Calendar.current
        let now = Date()

        switch selectedDateRange {
        case .all:
            break
        case .today:
            visits = visits.filter { calendar.isDate($0.checkInTime, inSameDayAs: now) }
        case .thisWeek:
            let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
            visits = visits.filter { $0.checkInTime >= weekAgo }
        case .thisMonth:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            visits = visits.filter { $0.checkInTime >= monthAgo }
        }

        // Sort by date (most recent first)
        return visits.sorted { $0.checkInTime > $1.checkInTime }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter Controls
                if showingFilters {
                    VisitFilterControlsView(
                        selectedPurposeFilter: $selectedPurposeFilter,
                        selectedDateRange: $selectedDateRange
                    )
                    .padding()
                    .background(Color(.systemGray6))
                }

                List(filteredAndSortedVisits) { visit in
                    VisitHistoryRow(visit: visit)
                }
                .searchable(text: $searchText, prompt: "Search visits...")
            }
            .navigationTitle("Visits (\(filteredAndSortedVisits.count))")
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
        }
    }
}

struct VisitHistoryRow: View {
    let visit: Visit
    @EnvironmentObject var dataService: DataService

    var customer: Customer? {
        dataService.getCustomer(by: visit.customerId)
    }

    var visitDuration: String? {
        guard let checkOutTime = visit.checkOutTime else { return nil }
        let duration = checkOutTime.timeIntervalSince(visit.checkInTime)
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with customer info and time
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if let customer = customer {
                        Text(customer.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(customer.company)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Unknown Customer")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(visit.checkInTime, style: .time)
                        .font(.caption)
                        .fontWeight(.medium)
                    Text(visit.checkInTime, style: .date)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            // Purpose and duration
            HStack {
                Text(visit.purpose.displayName)
                    .font(.subheadline)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(purposeColor.opacity(0.1))
                    .foregroundColor(purposeColor)
                    .cornerRadius(8)

                if let duration = visitDuration {
                    Text(duration)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.green)
                        .cornerRadius(6)
                }

                Spacer()

                if visit.photos?.isEmpty == false {
                    Image(systemName: "camera.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }

            // Notes
            if let notes = visit.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }

    private var purposeColor: Color {
        switch visit.purpose {
        case .salesCall:
            return .blue
        case .serviceVisit:
            return .orange
        case .productDemo:
            return .purple
        case .contractNegotiation:
            return .green
        case .followUp:
            return .teal
        case .other:
            return .gray
        }
    }
}

struct VisitFilterControlsView: View {
    @Binding var selectedPurposeFilter: VisitPurpose?
    @Binding var selectedDateRange: VisitHistoryView.DateRange

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Date Range:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Picker("Date Range", selection: $selectedDateRange) {
                    ForEach(VisitHistoryView.DateRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }

            HStack {
                Text("Purpose:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Picker("Purpose", selection: $selectedPurposeFilter) {
                    Text("All Purposes").tag(nil as VisitPurpose?)
                    ForEach(VisitPurpose.allCases, id: \.self) { purpose in
                        Text(purpose.displayName).tag(purpose as VisitPurpose?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
        }
    }
}

#Preview {
    VisitHistoryView()
        .environmentObject(DataService())
}
