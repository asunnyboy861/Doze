# Doze - iOS Development Guide

## Executive Summary

Doze is a calm, minimal sleep tracker that helps users notice their rest without the pressure of scores, goals, or optimization. Unlike complex sleep apps that require wearables, accounts, and subscriptions, Doze offers a 3-second manual logging experience with privacy-first local storage. Targeting the US market where sleep apps generate $500M+ annually, Doze differentiates through radical simplicity, no-judgment design, and pricing 60-80% below competitors.

**Product Vision**: Track your sleep, not your performance.

**Target Audience**: US adults aged 25-55 who want simple sleep tracking without wearable dependency, complex UI, or privacy concerns.

**Key Differentiators**:
- 3-second manual logging (vs. complex setup in competitors)
- No wearable required (vs. Apple Watch dependency in Pillow, AutoSleep)
- No account needed (vs. mandatory accounts in Sleep Cycle, Rise)
- Pricing 60-80% below competitors with lifetime purchase option
- Privacy-first: local storage default, optional iCloud sync

## Competitive Analysis

| App | Strengths | Weaknesses | Our Advantage |
|-----|-----------|------------|---------------|
| Pillow (4.4, 94.6K ratings) | Apple Watch integration, smart alarm, snore recording, Editor's Choice | Requires Apple Watch for full features, expensive subscription ($4.99/mo), complex UI after updates | No wearable needed, simpler UI, 60% cheaper, no account required |
| Sleep Cycle (4.6) | 40M+ downloads, smart alarm, sound recording, sleep notes | Premium features now paywalled, laggy UI after updates, $9.99/mo subscription | No lag, manual tracking (user-controlled), 80% cheaper, no auto-tracking inaccuracy |
| Rise ($5.99/mo) | Sleep debt tracking, circadian rhythm, energy prediction | Requires Apple Health data, complex onboarding, no manual logging | Simple onboarding, manual-first approach, no data dependency |
| AutoSleep | Automatic tracking, no manual input, one-time purchase | Requires Apple Watch, complex data presentation, no free tier | Works without Apple Watch, simpler data view, free tier available |
| Lull Sleep | No scores, no pressure, privacy-first, completely free | Limited features, no statistics, no HealthKit sync | More features while keeping no-pressure philosophy, HealthKit sync, statistics |

## Apple Design Guidelines Compliance

- **HIG - Health & Fitness**: HealthKit authorization requested only when user saves a sleep session, with clear purpose explanation
- **HIG - Privacy**: All data stored locally by default; iCloud sync is opt-in; no third-party analytics; no data collection
- **HIG - Data Entry**: Quick Log uses native DatePicker and simple mood selector for minimal input friction
- **HIG - Navigation**: Standard TabView with Home, History, Stats tabs following iOS conventions
- **HIG - Dark Mode**: Full support using semantic colors (Color.primary, Color.secondary)
- **HIG - Widgets**: Small and medium widgets following WidgetKit design guidelines
- **HIG - Accessibility**: VoiceOver labels, Dynamic Type support, reduced motion respect
- **App Store Review 2.1**: HealthKit usage clearly justified in Info.plist privacy descriptions
- **App Store Review 3.1.1**: IAP subscription terms clearly stated with auto-renewal and cancellation info

## Technical Architecture

- **Language**: Swift 5.9+
- **Framework**: SwiftUI (primary), SwiftData for persistence
- **Data**: SwiftData (local default), CloudKit (optional iCloud sync)
- **Health**: HealthKit for sleep data sync
- **Charts**: Swift Charts (native, no third-party dependency)
- **Widgets**: WidgetKit with StaticConfiguration
- **Automation**: App Intents for Shortcuts integration
- **IAP**: StoreKit 2 for subscription management
- **Networking**: URLSession for feedback submission
- **Minimum iOS**: 17.0

## Module Structure

```
Doze/
├── DozeApp.swift
├── ContentView.swift
├── Models/
│   ├── SleepSession.swift
│   └── SleepMood.swift
├── ViewModels/
│   ├── SleepTrackerViewModel.swift
│   ├── HistoryViewModel.swift
│   ├── StatisticsViewModel.swift
│   └── PurchaseManager.swift
├── Views/
│   ├── Home/
│   │   ├── HomeView.swift
│   │   └── QuickLogView.swift
│   ├── History/
│   │   ├── HistoryView.swift
│   │   └── SessionDetailView.swift
│   ├── Statistics/
│   │   └── StatisticsView.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   └── ContactSupportView.swift
│   └── Paywall/
│       └── PaywallView.swift
├── Services/
│   ├── HealthKitManager.swift
│   ├── NotificationManager.swift
│   └── ExportManager.swift
├── Components/
│   ├── MoodSelector.swift
│   ├── DurationDisplay.swift
│   └── SleepSessionRow.swift
├── Extensions/
│   ├── Date+Extensions.swift
│   └── Color+Extensions.swift
└── Widget/
    ├── SleepWidget.swift
    ├── SleepWidgetBundle.swift
    └── SleepTimelineProvider.swift
```

## Implementation Flow

1. Configure SwiftData model (SleepSession) with all attributes
2. Build HomeView with greeting, last night summary, and weekly chart
3. Build QuickLogView with DatePicker, MoodSelector, and notes
4. Build HistoryView with grouped session list and swipe-to-delete
5. Build SessionDetailView for editing and viewing session details
6. Build StatisticsView with weekly bar chart and monthly trends
7. Implement HealthKitManager for reading/writing sleep data
8. Implement NotificationManager for bedtime reminders
9. Implement PurchaseManager with StoreKit 2 for subscriptions
10. Build PaywallView following Apple IAP guidelines
11. Build SettingsView with policy links, iCloud toggle, restore purchases
12. Build ContactSupportView with feedback submission
13. Implement ExportManager for CSV/PDF data export
14. Build Widget with SleepWidget for home screen
15. Implement App Intents for Shortcuts automation
16. Create policy HTML pages (support, privacy, terms)
7. Test on iPhone and iPad simulators
18. Push to GitHub and deploy policy pages

## UI/UX Design Specifications

- **Color Scheme**:
  - Primary: #007AFF (system blue)
  - Background Light: #FFFFFF
  - Background Dark: #000000
  - Secondary: #8E8E93 (system gray)
  - Mood Great: #34C759 (green)
  - Mood Good: #30D158 (light green)
  - Mood Okay: #FF9500 (orange)
  - Mood Poor: #FF3B30 (red)
  - Mood Terrible: #AF52DE (purple)

- **Typography**: SF Pro system fonts
  - Large Title: 34pt Bold
  - Title: 28pt Bold
  - Headline: 17pt Semibold
  - Body: 17pt Regular
  - Caption: 12pt Regular

- **Layout**:
  - Standard iOS TabView with 3 tabs (Home, History, Stats)
  - Content max width 720pt on iPad with centering
  - 16pt horizontal padding on all views
  - 12pt corner radius on cards
  - LazyVStack for long lists

- **Animations**:
  - Spring animation for mood selection (response: 0.3, damping: 0.6)
  - Ease-in-out for chart loading (duration: 0.6)
  - Scale effect for button interactions

## Code Generation Rules

- Use SwiftUI exclusively for all views
- Use SwiftData for data persistence
- Use Swift Charts for all chart visualizations (no third-party chart libraries)
- Use StoreKit 2 for all IAP operations
- All model attributes must be optional or have default values
- Follow MVVM pattern with @Observable ViewModels
- No code comments unless explicitly requested
- Single responsibility per file
- Semantic naming conventions
- iPad content must use .frame(maxWidth: 720).frame(maxWidth: .infinity) in ScrollView

## Build & Deployment Checklist

- [ ] Bundle ID: com.zzoutuo.Doze
- [ ] Deployment Target: iOS 17.0
- [ ] Swift Language Version: 5.0
- [ ] HealthKit capability enabled with sleep analysis
- [ ] App Icon generated and configured
- [ ] StoreKit Configuration file for testing IAP
- [ ] Privacy descriptions in Info.plist (HealthKit, Notifications)
- [ ] Widget target configured
- [ ] Build succeeds on iPhone simulator
- [ ] Build succeeds on iPad simulator
- [ ] Policy pages deployed to GitHub Pages
- [ ] App Store metadata prepared
