//
//  ExpenseWidget.swift
//  ExpenseWidget
//
//  Created by Ashutosh Kumar Kushwaha on 31/08/25.
//

import WidgetKit
import SwiftUI

struct ExpenseWidget: Widget {
    let kind: String = "ExpenseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ExpenseTimelineProvider()) { entry in
            ExpenseWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Expense Tracker")
        .description("Track your monthly expenses at a glance")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
        .contentMarginsDisabled()
    }
}

struct ExpenseTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> ExpenseEntry {
        ExpenseEntry(
            date: Date(),
            totalExpenses: 0,
            monthlyBudget: 10000,
            budgetPercentage: 0
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ExpenseEntry) -> ()) {
        let entry = loadCurrentExpenseData()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ExpenseEntry>) -> ()) {
        let entry = loadCurrentExpenseData()
        
        // Update every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
    
    private func loadCurrentExpenseData() -> ExpenseEntry {
        let sharedDefaults = UserDefaults(suiteName: "group.com.yourcompany.counter.shared")
        
        let totalExpenses = sharedDefaults?.double(forKey: "widget_total_expenses") ?? 0
        let monthlyBudget = sharedDefaults?.double(forKey: "widget_monthly_budget") ?? 10000
        
        let budgetPercentage = monthlyBudget > 0 ? (totalExpenses / monthlyBudget) * 100 : 0
        
        return ExpenseEntry(
            date: Date(),
            totalExpenses: totalExpenses,
            monthlyBudget: monthlyBudget,
            budgetPercentage: budgetPercentage
        )
    }
}

struct ExpenseEntry: TimelineEntry {
    let date: Date
    let totalExpenses: Double
    let monthlyBudget: Double
    let budgetPercentage: Double
}

struct ExpenseWidgetEntryView: View {
    var entry: ExpenseTimelineProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .accessoryCircular:
            LockScreenCircularView(entry: entry)
        case .accessoryRectangular:
            LockScreenRectangularView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

struct SmallWidgetView: View {
    let entry: ExpenseEntry
    
    private var progressColor: Color {
        let percentage = entry.budgetPercentage
        if percentage <= 50 { return .green }
        else if percentage <= 75 { return .orange }
        else { return .red }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("EXPENSES")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .tracking(1.2)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            // Circular Progress with Amount in Center
            ZStack {
                // Background circle
                Circle()
                    .stroke(.quaternary, lineWidth: 12)
                    .frame(width: 90, height: 90)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: min(entry.budgetPercentage / 100, 1.0))
                    .stroke(
                        LinearGradient(
                            colors: progressColor == .green ? [.green.opacity(0.7), .green] :
                                   progressColor == .orange ? [.orange.opacity(0.7), .orange] :
                                   [.red.opacity(0.7), .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 90, height: 90)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: progressColor.opacity(0.3), radius: 4, x: 0, y: 2)
                
                // // Center content
                // VStack(spacing: 2) {
                    Text("\(Int(entry.budgetPercentage))%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(progressColor)
                    
                    // Text("₹\(formatAmount(entry.totalExpenses))")
                    //     .font(.caption2)
                    //     .fontWeight(.medium)
                    //     .foregroundColor(.secondary)
                // }
            }
            
            Spacer()
        }
        .padding(20)
        .widgetURL(URL(string: "expensetracker://open"))
    }
    
    private func formatAmount(_ amount: Double) -> String {
        if amount >= 100000 {
            return String(format: "%.1fL", amount / 100000)
        } else if amount >= 1000 {
            return String(format: "%.1fK", amount / 1000)
        } else {
            return String(format: "%.0f", amount)
        }
    }
}

struct MediumWidgetView: View {
    let entry: ExpenseEntry
    
    private var progressColor: Color {
        let percentage = entry.budgetPercentage
        if percentage <= 50 { return .green }
        else if percentage <= 75 { return .orange }
        else { return .red }
    }
    
    var body: some View {
        HStack(spacing: 24) {
            // Left side - Main content
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    Text("MONTHLY EXPENSES")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .tracking(1.2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(entry.budgetPercentage))%")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(progressColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(progressColor.opacity(0.15), in: Capsule())
                }
                
                // Amounts
                VStack(alignment: .leading, spacing: 4) {
                    Text("₹\(formatAmount(entry.totalExpenses))")
                        .font(.title)
                        .fontWeight(.heavy)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.primary, .primary.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    Text("of ₹\(formatAmount(entry.monthlyBudget)) budget")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Right side - Progress indicator
            VStack {
                Spacer()
                
                // Circular progress
                ZStack {
                    Circle()
                        .stroke(.quaternary, lineWidth: 8)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: min(entry.budgetPercentage / 100, 1.0))
                        .stroke(
                            LinearGradient(
                                colors: progressColor == .green ? [.green.opacity(0.7), .green] :
                                       progressColor == .orange ? [.orange.opacity(0.7), .orange] :
                                       [.red.opacity(0.7), .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                        .shadow(color: progressColor.opacity(0.3), radius: 4, x: 0, y: 2)
                    
                    Text("\(Int(entry.budgetPercentage))")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(progressColor)
                }
                
                Spacer()
            }
        }
        .padding(20)
        .widgetURL(URL(string: "expensetracker://open"))
    }
    
    private func formatAmount(_ amount: Double) -> String {
        if amount >= 100000 {
            return String(format: "%.1fL", amount / 100000)
        } else if amount >= 1000 {
            return String(format: "%.1fK", amount / 1000)
        } else {
            return String(format: "%.0f", amount)
        }
    }
}

// MARK: - Lock Screen Widgets
struct LockScreenCircularView: View {
    let entry: ExpenseEntry
    
    private var progressColor: Color {
        let percentage = entry.budgetPercentage
        if percentage <= 50 { return .green }
        else if percentage <= 75 { return .orange }
        else { return .red }
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(.tertiary, lineWidth: 4)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: min(entry.budgetPercentage / 100, 1.0))
                .stroke(progressColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
            
            // Center percentage
            Text("\(Int(entry.budgetPercentage))%")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(progressColor)
        }
        .widgetURL(URL(string: "expensetracker://open"))
    }
}

struct LockScreenRectangularView: View {
    let entry: ExpenseEntry
    
    private var progressColor: Color {
        let percentage = entry.budgetPercentage
        if percentage <= 50 { return .green }
        else if percentage <= 75 { return .orange }
        else { return .red }
    }
    
    var body: some View {
        HStack(spacing: 8) {
            // Left - Circular indicator
            ZStack {
                Circle()
                    .stroke(.tertiary, lineWidth: 3)
                    .frame(width: 24, height: 24)
                
                Circle()
                    .trim(from: 0, to: min(entry.budgetPercentage / 100, 1.0))
                    .stroke(progressColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 24, height: 24)
                    .rotationEffect(.degrees(-90))
            }
            
            // Right - Text info
            VStack(alignment: .leading, spacing: 1) {
                HStack {
                    Text("₹\(formatAmount(entry.totalExpenses))")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("\(Int(entry.budgetPercentage))%")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(progressColor)
                }
                
                Text("of ₹\(formatAmount(entry.monthlyBudget))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .widgetURL(URL(string: "expensetracker://open"))
    }
    
    private func formatAmount(_ amount: Double) -> String {
        if amount >= 100000 {
            return String(format: "%.1fL", amount / 100000)
        } else if amount >= 1000 {
            return String(format: "%.1fK", amount / 1000)
        } else {
            return String(format: "%.0f", amount)
        }
    }
}

#Preview(as: .systemSmall) {
    ExpenseWidget()
} timeline: {
    ExpenseEntry(date: .now, totalExpenses: 3500, monthlyBudget: 10000, budgetPercentage: 35)
    ExpenseEntry(date: .now, totalExpenses: 7500, monthlyBudget: 10000, budgetPercentage: 75)
    ExpenseEntry(date: .now, totalExpenses: 9500, monthlyBudget: 10000, budgetPercentage: 95)
}

#Preview(as: .systemMedium) {
    ExpenseWidget()
} timeline: {
    ExpenseEntry(date: .now, totalExpenses: 3500, monthlyBudget: 10000, budgetPercentage: 35)
}

#Preview(as: .accessoryCircular) {
    ExpenseWidget()
} timeline: {
    ExpenseEntry(date: .now, totalExpenses: 3500, monthlyBudget: 10000, budgetPercentage: 35)
    ExpenseEntry(date: .now, totalExpenses: 7500, monthlyBudget: 10000, budgetPercentage: 75)
    ExpenseEntry(date: .now, totalExpenses: 9500, monthlyBudget: 10000, budgetPercentage: 95)
}

#Preview(as: .accessoryRectangular) {
    ExpenseWidget()
} timeline: {
    ExpenseEntry(date: .now, totalExpenses: 3500, monthlyBudget: 10000, budgetPercentage: 35)
}
