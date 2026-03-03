//
//  UtilitiesPage.swift
//  Weather App
//
//  Created by Rupam Mukherjee on 03/03/26.
//

import SwiftUI
import Foundation

// MARK: - Data Models

struct UtilityInfo: Codable {
    let price: Int
    let multiplier: [String: Int]
}

struct CommercialPropertiesDatabase: Codable {
    let utilities: [String: UtilityInfo]

    enum CodingKeys: String, CodingKey {
        case utilities = "Utilities"
    }
}

struct UtilityDatabase: Codable {
    var owners: [String: [String]]   // playerName → [utilityName, ...]

    init(owners: [String: [String]] = [:]) {
        self.owners = owners
    }
}

// MARK: - UtilitiesPage View

struct UtilitiesPage: View {

    @State private var isNight = false
    @State private var new_player_text = "Select or create new player"
    @State private var player_names: [String] = []
    @State private var new_utility_text = "Select utility"
    @State private var utility_names: [String] = []
    @State private var commercialDatabase: CommercialPropertiesDatabase?
    @State private var playerDatabase: PlayerDatabase?
    @State private var utilityDatabase: UtilityDatabase?
    @State private var isCreatingNewPlayer = false
    @State private var showingConfirmationAlert = false
    @State private var showingRentAlert = false
    @State private var utilityOwner: String = ""
    @State private var navigateToLanding = false
    @FocusState private var isPlayerFieldFocused: Bool
    @FocusState private var isUtilityFieldFocused: Bool

    var topRightIconName: String = "house.fill"

    // MARK: - Computed state

    private var isPlayerSelected: Bool {
        !new_player_text.isEmpty && new_player_text != "Select or create new player"
    }

    private var isUtilitySelected: Bool {
        !new_utility_text.isEmpty && new_utility_text != "Select utility"
    }

    /// True only if no player currently holds this utility
    private var isUtilityFree: Bool {
        guard isUtilitySelected else { return false }
        guard let db = utilityDatabase else { return true }
        return !db.owners.values.contains { $0.contains(new_utility_text) }
    }

    private var isSaveEnabled: Bool {
        isPlayerSelected && isUtilitySelected && isUtilityFree
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // Hidden NavigationLink for programmatic navigation
            NavigationLink(destination: LandingPage(), isActive: $navigateToLanding) {
                EmptyView()
            }
            .hidden()

            FlatBackgroundView(isNight: isNight)
                .onTapGesture {
                    isPlayerFieldFocused = false
                    isUtilityFieldFocused = false
                }

            VStack {
                VStack {
                    Spacer()
                        .onTapGesture {
                            isPlayerFieldFocused = false
                            isUtilityFieldFocused = false
                        }

                    SelectionBox(
                        InputPrompt: "Select Player",
                        new_data_input_text: $new_player_text,
                        option_names: player_names,
                        allowTyping: isCreatingNewPlayer,
                        isFocused: $isPlayerFieldFocused
                    )
                    .id("playerSelectionBox")
                    .onSubmit {
                        isCreatingNewPlayer = false
                        isPlayerFieldFocused = false
                    }

                    Spacer()
                        .onTapGesture {
                            isPlayerFieldFocused = false
                            isUtilityFieldFocused = false
                        }

                    SelectionBox(
                        InputPrompt: "Select Utility",
                        new_data_input_text: $new_utility_text,
                        option_names: utility_names,
                        isDisabled: !isPlayerSelected,
                        isFocused: $isUtilityFieldFocused
                    )

                    Spacer()
                        .onTapGesture {
                            isPlayerFieldFocused = false
                            isUtilityFieldFocused = false
                        }

                    Button(action: {
                        showingConfirmationAlert = true
                    }) {
                        Text("Save")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(isSaveEnabled ? Color.green : Color.gray)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                    .disabled(!isSaveEnabled)

                    Spacer()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 10) {
                    NavigationLink(destination: TransactionsDatabase()) {
                        Image(systemName: "dollarsign")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                    NavigationLink(destination: DatabasePage()) {
                        Image(systemName: "books.vertical")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                    NavigationLink(destination: LandingPage()) {
                        Image(systemName: topRightIconName)
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .onAppear {
            loadData()
        }
        .onChange(of: new_utility_text) { newUtility in
            guard isPlayerSelected,
                  !newUtility.isEmpty,
                  newUtility != "Select utility" else { return }
            if let owner = checkUtilityOwnership(utilityName: newUtility), owner != new_player_text {
                utilityOwner = owner
                showingRentAlert = true
            }
        }
        .onChange(of: new_player_text) { newValue in
            if newValue == "New player" {
                new_player_text = ""
                isCreatingNewPlayer = true
                DispatchQueue.main.async {
                    isPlayerFieldFocused = true
                }
            } else if !isCreatingNewPlayer && player_names.contains(newValue) && newValue != "New player" {
                isPlayerFieldFocused = false
            }
        }
        // MARK: - Confirm Purchase
        .alert("Confirm Purchase", isPresented: $showingConfirmationAlert) {
            Button("Cancel", role: .cancel) { }
            Button("OK") {
                purchaseUtility()
            }
        } message: {
            let price = commercialDatabase?.utilities[new_utility_text]?.price ?? 0
            return Text("Pay $\(price) to Treasurer to purchase \(new_utility_text).")
        }
        // MARK: - Pay Rent
        .alert("Pay Rent", isPresented: $showingRentAlert) {
            Button("Cancel", role: .cancel) {
                new_utility_text = "Select utility"
            }
            Button("OK") {
                payUtilityRent()
                navigateToLanding = true
            }
        } message: {
            let rentAmount = calculateRentForOwner(utilityOwner)
            let utilitiesOwned = utilityDatabase?.owners[utilityOwner]?.count ?? 0
            return Text("Pay $\(rentAmount) to \(utilityOwner) for \(new_utility_text) (\(utilitiesOwned) \(utilitiesOwned == 1 ? "utility" : "utilities") owned).")
        }
    }

    // MARK: - Private Helpers

    private func loadData() {
        if let data: CommercialPropertiesDatabase = readJsonDatabase(filename: "Commercial_properties.json") {
            commercialDatabase = data
            utility_names = Array(data.utilities.keys).sorted()
        }

        if let data: PlayerDatabase = readJsonDatabase(filename: "Player_database.json") {
            playerDatabase = data
        }
        // Union names from Player_database.json and Player_accounts.json so that
        // players whose first action was a rent payment (no owned property yet) also appear.
        var allPlayerNames: Set<String> = Set(playerDatabase.map { Array($0.players.keys) } ?? [])
        if let accountsData: PlayerAccountsDatabase = readJsonDatabase(filename: "Player_accounts.json") {
            allPlayerNames.formUnion(accountsData.accounts.keys)
        }
        player_names = ["New player"] + allPlayerNames.sorted()

        utilityDatabase = readJsonDatabase(filename: "Utility_database.json") ?? UtilityDatabase()
    }

    private func checkUtilityOwnership(utilityName: String) -> String? {
        guard let db = utilityDatabase else { return nil }
        return db.owners.first { $0.value.contains(utilityName) }?.key
    }

    /// Rent = multiplier for however many utilities the owner currently holds.
    /// E.g. owner holds 1 → key "1 owned" → multiplier 4; 2 → "2 owned" → 10
    private func calculateRentForOwner(_ owner: String) -> Int {
        let owned = utilityDatabase?.owners[owner]?.count ?? 0
        let key = "\(owned) owned"
        return commercialDatabase?.utilities[new_utility_text]?.multiplier[key] ?? 0
    }

    private func purchaseUtility() {
        let price = commercialDatabase?.utilities[new_utility_text]?.price ?? 0

        // Record ownership in Utility_database.json
        var db = utilityDatabase ?? UtilityDatabase()
        if db.owners[new_player_text] == nil { db.owners[new_player_text] = [] }
        db.owners[new_player_text]?.append(new_utility_text)
        writeJsonDatabase(filename: "Utility_database.json", data: db)
        utilityDatabase = db

        // Record entry in Player_database.json (locality = "Utilities", no houses)
        // Use explicit extraction+reassignment to avoid silent no-op through nested value-type optional chaining
        var playerDB: PlayerDatabase = readJsonDatabase(filename: "Player_database.json") ?? PlayerDatabase(players: [:])
        var playerEntry = playerDB.players[new_player_text] ?? [:]
        var utilitiesLocality = playerEntry["Utilities"] ?? [:]
        utilitiesLocality[new_utility_text] = PropertyInfo(houses: nil)
        playerEntry["Utilities"] = utilitiesLocality
        playerDB.players[new_player_text] = playerEntry
        writeJsonDatabase(filename: "Player_database.json", data: playerDB)
        playerDatabase = playerDB

        // Debit transaction
        var accountsDB: PlayerAccountsDatabase = readJsonDatabase(filename: "Player_accounts.json") ?? PlayerAccountsDatabase(accounts: [:])
        if accountsDB.accounts[new_player_text] == nil {
            accountsDB.accounts[new_player_text] = []
            accountsDB.accounts[new_player_text]?.append(Transaction(paymentAmount: 1500, paymentSource: "Treasurer", purpose: "Initial deposit"))
        }
        accountsDB.accounts[new_player_text]?.append(
            Transaction(paymentAmount: Double(-price), paymentSource: "Treasurer", purpose: "Purchase of \(new_utility_text) (Utility)")
        )
        writeJsonDatabase(filename: "Player_accounts.json", data: accountsDB)

        navigateToLanding = true
    }

    private func payUtilityRent() {
        let rentAmount = calculateRentForOwner(utilityOwner)
        let purpose = "Rent for \(new_utility_text)"

        var accountsDB: PlayerAccountsDatabase = readJsonDatabase(filename: "Player_accounts.json") ?? PlayerAccountsDatabase(accounts: [:])

        // Debit paying player
        if accountsDB.accounts[new_player_text] == nil {
            accountsDB.accounts[new_player_text] = []
            accountsDB.accounts[new_player_text]?.append(Transaction(paymentAmount: 1500, paymentSource: "Treasurer", purpose: "Initial deposit"))
        }
        accountsDB.accounts[new_player_text]?.append(
            Transaction(paymentAmount: Double(-rentAmount), paymentSource: utilityOwner, purpose: purpose)
        )

        // Credit owner
        if accountsDB.accounts[utilityOwner] == nil {
            accountsDB.accounts[utilityOwner] = []
            accountsDB.accounts[utilityOwner]?.append(Transaction(paymentAmount: 1500, paymentSource: "Treasurer", purpose: "Initial deposit"))
        }
        accountsDB.accounts[utilityOwner]?.append(
            Transaction(paymentAmount: Double(rentAmount), paymentSource: new_player_text, purpose: purpose)
        )

        writeJsonDatabase(filename: "Player_accounts.json", data: accountsDB)
    }
}

struct UtilitiesPage_Previews: PreviewProvider {
    static var previews: some View {
        UtilitiesPage()
    }
}
