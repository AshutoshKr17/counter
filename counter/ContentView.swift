//
//  ContentView.swift
//  counter
//
//  Created by Ashutosh Kumar Kushwaha on 29/08/25.
//

import SwiftUI
import WidgetKit

// Color interpolation extension for smooth transitions
extension Color {
    func interpolated(to color: Color, progress: Double) -> Color {
        let clampedProgress = max(0, min(1, progress))
        
        // Get RGB components from both colors
        let fromComponents = self.rgbComponents
        let toComponents = color.rgbComponents
        
        // Interpolate between the RGB values
        let red = fromComponents.red + (toComponents.red - fromComponents.red) * clampedProgress
        let green = fromComponents.green + (toComponents.green - fromComponents.green) * clampedProgress
        let blue = fromComponents.blue + (toComponents.blue - fromComponents.blue) * clampedProgress
        
        return Color(red: red, green: green, blue: blue)
    }
    
    var rgbComponents: (red: Double, green: Double, blue: Double) {
        // Simplified approach using UIColor conversion
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (Double(red), Double(green), Double(blue))
    }
}

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var totalExpenses: Double = 0.0
    @State private var expenseHistory: [Double] = []
    @State private var sliderAmount: Double = 0.0
    @State private var textAmount: String = ""
    @State private var useSlider: Bool = true
    @State private var monthlyBudget: Double = 10000.0
    @State private var budgetAmount: String = ""
    @State private var showBudgetSetting: Bool = false
    @State private var showResetConfirmation: Bool = false
    
    private let defaults = UserDefaults.standard
    private let sharedDefaults = UserDefaults(suiteName: "group.com.yourcompany.counter.shared")
    private let expensesKey = "saved_expenses"
    private let budgetKey = "monthly_budget"
    private let historyKey = "expense_history"

    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 30) {
                headerSection
                budgetSection
                totalExpensesSection
                inputSection
                undoButton
            }
            .padding(.vertical)
        }
        .onAppear {
            loadExpenses()
            loadBudget()
            loadHistory()
            
            // Sync current data to widget on app start
            saveExpenses()
            saveBudget()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenAddExpense"))) { _ in
            useSlider = true
        }
        .onTapGesture {
            hideKeyboard()
        }
        .sheet(isPresented: $showBudgetSetting) {
            budgetSettingsView
        }
    }
    
    // MARK: - View Components
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: colorScheme == .light ? lightModeColors : darkModeColors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var lightModeColors: [Color] {
        [
            Color(red: 0.98, green: 0.98, blue: 1.0),  // Very light blue-white
            Color(red: 0.96, green: 0.97, blue: 0.99), // Subtle blue tint
            Color(red: 0.97, green: 0.98, blue: 1.0)   // Clean white
        ]
    }
    
    private var darkModeColors: [Color] {
        [
            Color(red: 0.05, green: 0.05, blue: 0.08),  // Very dark blue-black
            Color(red: 0.08, green: 0.08, blue: 0.12),  // Subtle dark blue tint
            Color(red: 0.06, green: 0.07, blue: 0.10)   // Rich dark
        ]
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Expenses")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.accentColor, Color.accentColor.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("Track your spending")
                    .font(.subheadline)
                    .foregroundColor(Color.accentColor.opacity(0.7))
            }
            
            Spacer()
            
            Button(action: {
                showBudgetSetting.toggle()
                budgetAmount = String(format: "%.0f", monthlyBudget)
            }) {
                ZStack {
                    Circle()
                        .fill(.thinMaterial)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.accentColor.opacity(0.8))
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }
    
    private var budgetSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Monthly Budget")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("₹\(monthlyBudget, specifier: "%.0f")")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Used")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("\(budgetPercentage, specifier: "%.1f")%")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(progressBarColor)
                }
            }
            
            cleanProgressBar
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 24)
    }
    
    private var cleanProgressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.quaternary)
                    .frame(height: 6)
                
                Capsule()
                    .fill(progressBarColor)
                    .frame(width: min(CGFloat(budgetPercentage) * geometry.size.width / 100, geometry.size.width), height: 6)
                    .animation(.easeInOut(duration: 0.5), value: budgetPercentage)
                    .animation(.easeInOut(duration: 0.5), value: progressBarColor)
            }
        }
        .frame(height: 6)
    }
    
    private var totalExpensesSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "indianrupeesign.circle.fill")
                    .font(.title2)
                    .foregroundColor(.accentColor)
                
                Text("Total Expenses")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("₹")
                    .font(.title)
                    .fontWeight(.light)
                    .foregroundColor(.secondary)
                
                Text("\(totalExpenses, specifier: "%.2f")")
                    .font(.system(size: 48, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .animation(.easeInOut(duration: 0.3), value: totalExpenses)
                
                Spacer()
            }
            
            if budgetPercentage > 75 {
                HStack {
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Circle()
                            .fill(totalDisplayColor)
                            .frame(width: 8, height: 8)
                        
                        Text(budgetPercentage > 100 ? "Over budget" : "Approaching limit")
                            .font(.caption)
                            .foregroundColor(totalDisplayColor)
                    }
                }
            }
        }
        .padding(24)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 24)
    }
    

    
    private var inputSection: some View {
        VStack(spacing: 20) {
            cleanInputModeToggle
            inputArea
            addExpenseButton
        }
        .padding(24)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 24)
    }
    
    private var cleanInputModeToggle: some View {
        Picker("Input Method", selection: $useSlider) {
            Text("Slider").tag(true)
            Text("Manual").tag(false)
        }
        .pickerStyle(.segmented)
    }
    
    @ViewBuilder
    private var inputArea: some View {
        if useSlider {
            sliderInputArea
        } else {
            textInputArea
        }
    }
    
    private var sliderInputArea: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Amount: ₹\(sliderAmount, specifier: "%.0f")")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 8) {
                Slider(value: $sliderAmount, in: 0...monthlyBudget, step: monthlyBudget / 100) {
                    Text("Amount")
                } minimumValueLabel: {
                    Text("₹0")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                } maximumValueLabel: {
                    Text("₹\(monthlyBudget >= 1000 ? String(format: "%.0fK", monthlyBudget / 1000) : String(format: "%.0f", monthlyBudget))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .tint(.accentColor)
            }
        }
    }
    
    private var textInputArea: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Enter Amount")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            HStack(spacing: 8) {
                Text("₹")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                TextField("0", text: $textAmount)
                    .keyboardType(.numberPad)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
                    .frame(maxWidth: 120)
            }
        }
    }
    
    private var addExpenseButton: some View {
        Button(action: addExpense) {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                
                Text("Add Expense")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
            .opacity(isAddButtonDisabled ? 0.6 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isAddButtonDisabled)
        }
        .disabled(isAddButtonDisabled)
        .buttonStyle(.plain)
    }
    
    private var isAddButtonDisabled: Bool {
        (useSlider && sliderAmount <= 0) || (!useSlider && textAmount.isEmpty)
    }
    
    private var undoButton: some View {
        Button(action: undoLastExpense) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 14, weight: .medium))
                
                Text("Undo")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(expenseHistory.isEmpty ? .secondary : .blue)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background((expenseHistory.isEmpty ? Color.secondary : Color.blue).opacity(0.1), in: RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        .disabled(expenseHistory.isEmpty)
        .opacity(expenseHistory.isEmpty ? 0.5 : 1.0)
    }
    

    
    // MARK: - Computed Properties
    private var budgetPercentage: Double {
        guard monthlyBudget > 0 else { return 0 }
        return (totalExpenses / monthlyBudget) * 100
    }
    
    private var totalDisplayColor: Color {
        let percentage = budgetPercentage
        if percentage < 50 {
            return .green
        } else if percentage < 75 {
            return .orange
        } else if percentage < 100 {
            return .red
        } else {
            return .red
        }
    }
    
    private var progressBarColor: Color {
        let percentage = budgetPercentage
        
        // Smooth color interpolation instead of hard thresholds
        if percentage <= 50 {
            // Pure green for 0-50%
            return .green
        } else if percentage <= 75 {
            // Smooth transition from green to orange (50-75%)
            let progress = (percentage - 50) / 25 // 0.0 to 1.0
            return Color.green.interpolated(to: .orange, progress: progress)
        } else if percentage < 100 {
            // Smooth transition from orange to red (75-100%)
            let progress = (percentage - 75) / 25 // 0.0 to 1.0
            return Color.orange.interpolated(to: .red, progress: progress)
        } else {
            // Pure red for over 100%
            return .red
        }
    }
    
    private var totalExpenseGradientColors: [Color] {
        let percentage = budgetPercentage
        if percentage < 50 {
            return [.green, .mint]
        } else if percentage < 75 {
            return [.orange, .yellow]
        } else if percentage < 100 {
            return [.red, .orange]
        } else {
            return [.red, .pink]
        }
    }
    
    // MARK: - Budget Settings View
    private var budgetSettingsView: some View {
        NavigationView {
            VStack(spacing: 32) {
                budgetSettingsHeader
                budgetSettingsCard
                resetMonthSection
                Spacer()
            }
            .padding(24)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showBudgetSetting = false
                    }
                    .fontWeight(.medium)
                }
            }
        }
        .alert("Reset Month?", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetExpenses()
            }
        } message: {
            Text("This will reset the month and all expenses you've tracked. Are you sure you want to do this?")
        }
    }
    
    private var budgetSettingsHeader: some View {
        VStack(spacing: 8) {
            Text("Monthly Budget")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Set your spending limit")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var budgetSettingsCard: some View {
        VStack(spacing: 24) {
            currentBudgetDisplay
            budgetInputSection
        }
        .padding(24)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    private var currentBudgetDisplay: some View {
        VStack(spacing: 8) {
            Text("Current Budget")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("₹\(monthlyBudget, specifier: "%.0f")")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
    }
    
    private var budgetInputSection: some View {
        VStack(spacing: 16) {
            budgetInputField
            updateBudgetButton
        }
    }
    
    private var budgetInputField: some View {
        HStack(spacing: 8) {
            Text("₹")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            TextField("Enter amount", text: $budgetAmount)
                .keyboardType(.numberPad)
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
                .frame(maxWidth: 200)
                .onChange(of: budgetAmount) { newValue in
                    budgetAmount = formatNumberInput(newValue)
                }
        }
    }
    
    private var updateBudgetButton: some View {
        Button("Update Budget") {
            withAnimation(.easeInOut(duration: 0.3)) {
                // Remove commas before converting to double
                let cleanAmount = budgetAmount.replacingOccurrences(of: ",", with: "")
                if let newBudget = Double(cleanAmount), newBudget > 0 {
                    monthlyBudget = newBudget
                    saveBudget()
                    showBudgetSetting = false
                }
            }
        }
        .font(.headline)
        .fontWeight(.semibold)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
        .disabled(isUpdateButtonDisabled)
        .opacity(isUpdateButtonDisabled ? 0.6 : 1.0)
    }
    
    private var isUpdateButtonDisabled: Bool {
        let cleanAmount = budgetAmount.replacingOccurrences(of: ",", with: "")
        return budgetAmount.isEmpty || Double(cleanAmount) == nil || Double(cleanAmount)! <= 0
    }
    
    private var resetMonthSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reset Month")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("Clear all tracked expenses")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Button(action: {
                showResetConfirmation = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "trash")
                        .font(.system(size: 14, weight: .medium))
                    
                    Text("Reset Month")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.red, in: RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Functions
    private func addExpense() {
        let amountToAdd: Double
        
        if useSlider {
            amountToAdd = sliderAmount
            sliderAmount = 0.0 // Reset slider after adding
        } else {
            amountToAdd = Double(textAmount) ?? 0.0
            textAmount = "" // Clear text field after adding
        }
        
        if amountToAdd > 0 {
            totalExpenses += amountToAdd
            expenseHistory.append(amountToAdd)
            saveExpenses()
            saveHistory()
        }
    }
    
    private func undoLastExpense() {
        guard let lastExpense = expenseHistory.last else { return }
        
        totalExpenses -= lastExpense
        expenseHistory.removeLast()
        
        saveExpenses()
        saveHistory()
    }
    
    private func resetExpenses() {
        totalExpenses = 0.0
        expenseHistory.removeAll()
        sliderAmount = 0.0
        textAmount = ""
        saveExpenses()
        saveHistory()
    }
    
    private func saveExpenses() {
        defaults.set(totalExpenses, forKey: expensesKey)
        
        // Also save to shared defaults for widget
        sharedDefaults?.set(totalExpenses, forKey: "widget_total_expenses")
        sharedDefaults?.synchronize()
        
        // Force widget refresh
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func loadExpenses() {
        totalExpenses = defaults.double(forKey: expensesKey)
    }
    
    private func saveHistory() {
        defaults.set(expenseHistory, forKey: historyKey)
    }
    
    private func loadHistory() {
        expenseHistory = defaults.array(forKey: historyKey) as? [Double] ?? []
    }
    
    private func saveBudget() {
        defaults.set(monthlyBudget, forKey: budgetKey)
        
        // Also save to shared defaults for widget
        sharedDefaults?.set(monthlyBudget, forKey: "widget_monthly_budget")
        sharedDefaults?.synchronize()
        
        // Force widget refresh
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func loadBudget() {
        let savedBudget = defaults.double(forKey: budgetKey)
        if savedBudget > 0 {
            monthlyBudget = savedBudget
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func formatNumberInput(_ input: String) -> String {
        // Remove all non-digit characters
        let digitsOnly = input.filter { $0.isNumber }
        
        // If empty, return empty
        guard !digitsOnly.isEmpty else { return "" }
        
        // Convert to number and format with commas
        if let number = Double(digitsOnly) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 0
            return formatter.string(from: NSNumber(value: number)) ?? digitsOnly
        }
        
        return digitsOnly
    }
    

}

#Preview {
    ContentView()
}
