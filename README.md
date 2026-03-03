# Anti-Monopoly App

A SwiftUI iOS application that started as a weather tutorial and has evolved into a full **Anti-Monopoly board game tracker**. The app manages players, property ownership, house purchases, rent payments, and transaction history — all persisted locally via JSON files.

---

## Features

### Landing Page
- Central hub with four action icons: **Property**, **Utilities**, **Treasury**, and **Database**.
- Bottom navigation bar with quick-access icons for Transactions, Property Database, and game reset.
- **Long-press tooltips** on bottom bar icons to describe each action.
- **Clear All Databases** button (with confirmation alert) to wipe all player data and restart the game.
- JSON data files are automatically seeded to the app's Documents directory on first launch.

### Property Page
- **Player selection**: choose an existing player from a dropdown or create a new player by typing a name.
- **Locality & property selection**: cascading dropdowns — locality list populates from `Asset_database.json`, property list filters based on the chosen locality.
- **House counter**: tap buttons (0–4) to select the number of houses to add; capped at 4 total per property.
- **Rent detection**: selecting a property already owned by another player triggers an automatic rent-payment alert showing the correct rent amount based on the owner's current house count.
- **Purchase confirmation**: shows the calculated cost (land price + house price) before saving.
- On confirm, updates `Player_database.json` and records the debit transaction in `Player_accounts.json`.

### Database Page
- Scrollable table (horizontal + vertical) displaying all owned properties across all players.
- Columns: **Player**, **Locality**, **Property**, **No of Houses**.
- Column widths auto-size to fit content, with extra space distributed evenly.

### Transactions Database Page
- **Player Balance bar graph**: visual overview of each player's net balance.
- Scrollable **Transactions table** with columns: **Player**, **Amount**, **Party**, **Purpose**.
- All debits (property purchases, rent paid) and credits (rent received, initial deposit) are displayed.

### Data Persistence
- All game state is stored as JSON in the app's Documents directory:
  - `Player_database.json` — property ownership per player.
  - `Player_accounts.json` — transaction history and balances per player.
  - `Asset_database.json` — property metadata (land price, house price, rent tiers).
  - `Commercial_properties.json` — commercial property data.
- Read/write utilities (`readJsonDatabase`, `writeJsonDatabase`) handle both initial bundle seeding and ongoing updates.

### Navigation
- Built on `NavigationStack` with toolbar icons on each page for quick jumps between Property, Database, Transactions, and the Landing Page.

---

## Original Weather App
The project originated from Sean Allen's SwiftUI weather tutorial (YouTube). `ContentView.swift` retains the original weather UI with a day/night toggle, hardcoded forecast data, and a gradient `BackgroundView`. The app entry point (`Weather_AppApp.swift`) currently launches `LandingPage`.

---

## Project Structure

| File | Purpose |
|---|---|
| `Weather_AppApp.swift` | App entry point — launches `LandingPage` |
| `LandingPage.swift` | Main hub, action icons, bottom nav bar, DB seeding |
| `PropertyPage.swift` | Property purchase & rent payment flow |
| `DatabasePage.swift` | Property ownership table view |
| `TransactionsDatabase.swift` | Balance bar graph & transaction history table |
| `ContentView.swift` | Original weather UI (retained) |
| `Asset_database.json` | Property pricing and rent data |
| `Player_database.json` | Player property ownership records |
| `Player_accounts.json` | Player transaction history |
| `Commercial_properties.json` | Commercial property data |

---

## Build & Run
Open `Weather App.xcodeproj` in Xcode, select a simulator or device, and press **Cmd+R**.
