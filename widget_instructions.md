# iOS Widget Setup Instructions

## 🎯 **What We've Built**

A beautiful iOS expense widget with **2 sizes** and **quick actions**!

### 📱 **Small Widget Features:**
- Current expense total and budget
- Progress bar with color coding (green/orange/red)
- Percentage used
- Tap to open main app

### 📱 **Medium Widget Features:**
- All small widget features PLUS:
- **"Add" Button** - Opens app ready to add expense
- **"Notify" Button** - Opens notification input screen
- Quick expense entry from home screen

## ⚙️ **Manual Xcode Setup Required**

Since we can't directly modify Xcode project files, follow these steps:

### 1. **Add Widget Extension Target**
1. Open `counter.xcodeproj` in Xcode
2. File → New → Target
3. Choose **Widget Extension**
4. Product Name: `ExpenseWidget`
5. Bundle Identifier: `com.yourcompany.counter.ExpenseWidget`
6. Click **Finish**

### 2. **Replace Widget Files**
1. Delete the generated widget files from Xcode
2. Add our custom files from the `ExpenseWidget/` folder:
   - `ExpenseWidget.swift`
   - `ExpenseWidgetBundle.swift`
   - `Info.plist`
   - `Assets.xcassets/`

### 3. **Add App Groups** (Required for data sharing)
1. Select your main app target (`counter`)
2. Go to **Signing & Capabilities**
3. Click **+ Capability** → Add **App Groups**
4. Create group: `group.com.yourcompany.counter.shared`
5. Repeat for `ExpenseWidget` target

### 4. **Add URL Scheme** (For widget deep links)
1. Select main app target (`counter`)
2. Go to **Info** tab
3. Add **URL Types**:
   - Identifier: `expensetracker`
   - URL Schemes: `expensetracker`

### 5. **Build & Run**
```bash
# Build both targets
xcodebuild -scheme counter -destination 'platform=iOS Simulator,name=iPhone 14' build
xcodebuild -scheme ExpenseWidget -destination 'platform=iOS Simulator,name=iPhone 14' build
```

## 📊 **Widget Architecture**

```
Main App ←→ Shared UserDefaults ←→ Widget
    ↑              (App Groups)           ↑
   Save            Data Sharing       Display
```

## 🔗 **Deep Link Actions**

| Widget Action | URL | Result |
|---------------|-----|--------|
| Tap Small Widget | `expensetracker://open` | Opens main app |
| Tap Add Button | `expensetracker://add-expense` | Opens to input screen |
| Tap Notify Button | `expensetracker://notifications` | Opens notification paste |

## 🎨 **Widget Previews**

The widgets automatically adapt to:
- ✅ Light/Dark mode
- ✅ Dynamic colors (green → orange → red based on budget)
- ✅ Real expense data
- ✅ Auto-refresh every hour

## 🚀 **Next Steps**

1. Complete Xcode setup above
2. Add widget to home screen from widget gallery
3. Test deep link actions
4. Enjoy quick expense tracking!

## 🐛 **Troubleshooting**

**Widget not updating?**
- Ensure App Groups are properly configured
- Check shared UserDefaults data is being saved
- Force refresh widget by removing/re-adding

**Deep links not working?**
- Verify URL scheme is added to main app
- Check `counterApp.swift` has URL handling code
