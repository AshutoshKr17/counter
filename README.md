# 💰 Expense Tracker

*A beautifully simple iOS app to track your monthly expenses*

This is an iOS app I made just to track my monthly expenses... 

No fancy charts, no fancy features - just a monthly budget and a slider/manual input field to track expenses :)

If you like this, feel free to fork and make it better :) 

Peace -_-

---

## ✨ Features

- **🎯 Simple & Clean** - No clutter, just what you need
- **💸 Monthly Budget** - Set your budget and track progress
- **🎚️ Dual Input** - Use slider or type amounts manually  
- **🌈 Smart Colors** - Progress bar changes from green → orange → red as you approach your budget
- **🌙 Dark Mode** - Beautiful adaptive design for light and dark themes
- **💾 Persistent Data** - Your expenses and budget are automatically saved
- **₹ Rupee Support** - Built with Indian Rupee currency
- **🍎 Apple Design** - Follows Apple's minimalist design principles

## 📱 Screenshots

> *Add screenshots of your app in light and dark mode here*

## 🚀 Getting Started

### Prerequisites

- Xcode 14.0 or later
- iOS 15.0 or later
- macOS 12.0 or later

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/expense-tracker.git
   cd expense-tracker
   ```

2. **Open in Xcode**
   ```bash
   open counter.xcodeproj
   ```

3. **Build and Run**
   - Select your target device/simulator
   - Press `Cmd + R` to build and run

## 🎮 How to Use

1. **Set Your Budget** - Tap the gear icon to set your monthly budget
2. **Add Expenses** - Use the slider or text field to input amounts
3. **Track Progress** - Watch the progress bar and total change colors as you spend
4. **Reset Anytime** - Clear your expenses with the reset button

### Smart Color System
- 🟢 **Green** (0-50%) - You're doing great!
- 🟠 **Orange** (50-75%) - Getting close to budget
- 🔴 **Red** (75%+) - Slow down, you're over budget!

## 🛠️ Built With

- **SwiftUI** - Apple's modern UI framework
- **UserDefaults** - For data persistence
- **Custom Color Interpolation** - For smooth progress bar transitions

## 📁 Project Structure

```
counter/
├── ContentView.swift          # Main UI and app logic
├── counterApp.swift          # App entry point
└── Assets.xcassets/          # App icons and colors
```

## 🎨 Key Features Explained

### Adaptive Background
The app automatically adapts between light and dark modes with carefully crafted gradients:
- **Light Mode**: Subtle blue-white gradients
- **Dark Mode**: Rich dark blue-black gradients

### Smooth Color Transitions
Custom color interpolation ensures the progress bar smoothly transitions between colors instead of jarring jumps.

### Dynamic Slider Range
The slider automatically adjusts its maximum value to match your monthly budget.

## 🤝 Contributing

Found a bug? Want to add a feature? Contributions are welcome!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Ideas for Enhancement
- Multiple currency support
- Export expenses to CSV
- Weekly/yearly budget views
- Expense categories
- Basic charts/graphs
- Widgets for home screen
- Apple Watch companion app

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

## 👨‍💻 Author

Made with ❤️ by **Ashutosh Kumar Kushwaha**

---

### Why This App?

Sometimes you don't need fancy analytics or complex features. Sometimes you just need a simple, beautiful way to know "Am I spending too much this month?" 

This app answers that question in the most Apple-like way possible.

**Peace -_-**

---

*If this helped you track your expenses better, give it a ⭐ on GitHub!*