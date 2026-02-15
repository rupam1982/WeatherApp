# Weather App - AI Agent Instructions

## Project Overview
SwiftUI-based weather/utility app for iOS. Originally a weather tutorial app that now includes an "Anti-Monopoly" landing page with action icons. Mix of weather functionality and custom action-based UI.

## Architecture & Key Files
- **Entry Point**: [Weather_AppApp.swift](Weather App/Weather_AppApp.swift) - Simple `@main` app wrapper, currently launches `ContentView`
- **Main Views**:
  - [ContentView.swift](Weather App/ContentView.swift) - Weather display with day/night toggle, hardcoded "Phoenixville, PA"
  - [LandingPage.swift](Weather App/LandingPage.swift) - "Anti-Monopoly" grid with 4 action icons (Property, Utilities, Treasurer, Database)
- **Tests**: Stub test files in `Weather AppTests/` and `Weather AppUITests/` - currently empty placeholders

## SwiftUI Component Pattern
Both views follow a **flat component structure** - all custom views defined in the same file as structs below the main view:

```swift
struct MainView: View { }
struct MainView_Previews: PreviewProvider { }
struct CustomComponent1: View { }
struct CustomComponent2: View { }
```

**Key Components** (defined in [ContentView.swift](Weather App/ContentView.swift)):
- `BackgroundView(isNight: Bool)` - Gradient background that switches black/gray (night) ↔ blue/white (day)
- `WeatherDayView(dayOfWeek:imageName:temperature:)` - Single day forecast tile
- `Weatherbutton` - Reusable button with customizable background/text colors
- `TextBoxWithMenu(text:options:)` - TextField with dropdown menu (unused in current UI)

**LandingPage Components**:
- `ActionIcon(actionName:imageName:)` - White rounded rectangle cards with SF Symbol icons
- Currently buttons have `print()` actions only - no navigation implemented

## Development Workflow
- **Build/Run**: Open `Weather App.xcodeproj` in Xcode, select target device/simulator, Cmd+R to run
- **Testing**: Use Xcode Test Navigator (Cmd+6) then Cmd+U - tests are stubs, need implementation
- **Preview**: SwiftUI Canvas in Xcode for live previews of each view

## Project-Specific Conventions
1. **File Naming**: Underscores in project files (`Weather_AppApp.swift`, `Weather_App.entitlements`) but spaces in folder names (`Weather App/`)
2. **State Management**: All state is `@State private` in view bodies - no ViewModels, ObservableObjects, or MVVM pattern
3. **Hardcoded Data**: 
   - City name: "Phoenixville, PA"
   - All forecast days show "Mon", 70°, same icon
   - LandingPage options: ["Apple", "Banana", "Cherry"] bound to `TextBoxWithMenu` but not visible in UI
4. **iOS Versioning**: Uses `#available(iOS 18.0, *)` check for `.symbolEffect(.breathe)` animation, fallbacks for older iOS
5. **Color Handling**: Uses `.opacity()` modifiers extensively (e.g., `Color.white.opacity(0.8)`)

## Integration Points
- **No External APIs**: Weather data is static/hardcoded - no network layer exists
- **No Dependencies**: Pure SwiftUI, no third-party packages in project
- **Sandboxed**: App uses sandbox entitlements (`com.apple.security.app-sandbox`, read-only file access)

## Common Tasks
- **Add New View**: Create struct conforming to `View`, add to same file or new file, update `WindowGroup` in [Weather_AppApp.swift](Weather App/Weather_AppApp.swift#L13) to change entry point
- **Switch Landing Page**: Change `ContentView()` → `LandingPage()` in [Weather_AppApp.swift](Weather App/Weather_AppApp.swift#L14)
- **Add Navigation**: Currently no NavigationStack/NavigationView - would need to wrap views and implement navigation logic
- **Dynamic Weather Data**: Would need to create a service layer, add API client, and replace hardcoded values with `@Published` properties

## Notes
- Based on Sean Allen's YouTube tutorial (acknowledged in README)
- LandingPage appears to be a pivot/expansion beyond the original tutorial scope
- Mixed metaphors: "Weather App" project name but "Anti-Monopoly" branding suggests potential app concept shift
