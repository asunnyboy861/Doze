# Capabilities Configuration

## Analysis
Based on operation guide analysis:
- "HealthKit" / "健康" / "Apple Health" → HealthKit capability required
- "通知" / "提醒" / "notification" → Push Notifications capability
- "iCloud" / "同步" / "sync" → iCloud capability (optional, user-controlled)
- "Widget" / "小组件" → WidgetKit extension
- "Shortcuts" / "自动化" → App Intents capability
- "订阅" / "会员" / "premium" → In-App Purchase capability

## Auto-Configured Capabilities
| Capability | Status | Method |
|------------|--------|--------|
| HealthKit | ✅ Will configure in code | Info.plist + Entitlements |
| Push Notifications | ✅ Will configure in code | UNUserNotificationCenter |
| In-App Purchase | ✅ Will configure in code | StoreKit 2 |

## Manual Configuration Required
| Capability | Status | Steps |
|------------|--------|-------|
| iCloud (CloudKit) | ⏳ Pending | 1. Enable iCloud in Xcode Signing & Capabilities 2. Add CloudKit container 3. Switch to NSPersistentCloudKitContainer |
| Widget Extension | ⏳ Pending | 1. Add Widget Extension target in Xcode 2. Configure App Groups for data sharing |

## No Configuration Needed
- Camera: Not needed (no photo features)
- Location Services: Not needed
- Siri: Not needed (using App Intents instead)
- Apple Watch: Not required (optional future enhancement)
- Background Modes: Not needed (no background tracking)

## Verification
- Build succeeded after configuration: ⏳ Pending
- All entitlements correct: ⏳ Pending
