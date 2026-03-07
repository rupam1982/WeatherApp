//
//  TransportPage.swift
//  Weather App
//
//  Created by Rupam Mukherjee on 07/03/26.
//

import SwiftUI
import Foundation

// MARK: - Data Models

struct TransportInfo: Codable {
    let price: Int
    let ticket: [String: Int]
}

struct TransportCommercialDatabase: Codable {
    let transport: [String: TransportInfo]

    enum CodingKeys: String, CodingKey {
        case transport = "Transport"
    }
}

struct TransportDatabase: Codable {
    var owners: [String: [String]]   // playerName → [companyName, ...]

    init(owners: [String: [String]] = [:]) {
        self.owners = owners
    }
}

// MARK: - TransportPage View

struct TransportPage: View {

    @State private var isNight = false
    @State private var new_player_text = "Select or create new player"
    @State private var player_names: [String] = []
    @State private var new_transport_text = "Select transport co."
    @State private var commercialDatabase: TransportCommercialDatabase?
    @State private var playerDatabase: PlayerDatabase?
    @State private var transportDatabase: TransportDatabase?
    @State private var isCreatingNewPlayer = false
    @State private var showingConfirmationAlert = false
    @State private var showingRentAlert = false
    @State private var transportOwner: String = ""
    @State private var navigateToLanding = false
    @FocusState private var isPlayerFieldFocused: Bool
    @FocusState private var isTransportFieldFocused: Bool

    var topRightIconName: String = "house.fill"

    // MARK: - Computed state

    private var isPlayerSelected: Bool {
        !new_player_text.isEmpty && new_player_text != "Select or create new player"
    }

    private var isTransportSelected: Bool {
        !new_transport_text.isEmpty && new_transport_text != "Select transport co."
    }

    /// True only if no player currently holds this transport company
    private var isTransportFree: Bool {
        guard isTransportSelected else { return false }
        guard let db = transportDatabase else { return true }
        return !db.owners.values.contains { $0.contains(new_transport_text) }
    }

    /// All transport companies minus those already owned by the selected player.
    private var transport_names: [String] {
        guard let allTransport = commercialDatabase?.transport else { return [] }
        let ownedByPlayer = Set(transportDatabase?.owners[new_player_text] ?? [])
        return Array(allTransport.keys).filter { !ownedByPlayer.contains($0) }.sorted()
    }

    private var isSaveEnabled: Bool {
        isPlayerSelected && isTransportSelected && isTransportFree
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
                    isTransportFieldFocused = false
                }

            VStack {
                VStack {
                    Spacer()
                        .onTapGesture {
                            isPlayerFieldFocused = false
                            isTransportFieldFocused = false
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
                        new_transport_text = "Select transport co."
                    }

                    Spacer()
                        .onTapGesture {
                            isPlayerFieldFocused = false
                            isTransportFieldFocused = false
                        }

                    SelectionBox(
                        InputPrompt: "Select Transport Co.",
                        new_data_input_text: $new_transport_text,
                        option_names: transport_names,
                        isDisabled: !isPlayerSelected,
                        isFocused: $isTransportFieldFocused
                    )
                    .id(new_player_text)

                    Spacer()
                        .onTapGesture {
                            isPlayerFieldFocused = false
                            isTransportFieldFocused = false
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
        .onChange(of: new_transport_text) { newTransport in
            guard isPlayerSelected,
                  !newTransport.isEmpty,
                  newTransport != "Select transport co." else { return }
            if let owner = checkTransportOwnership(companyName: newTransport), owner != new_player_text {
                transportOwner = owner
                showingRentAlert = true
            } else if isTransportFree {
                showingConfirmationAlert = true
            }
        }
        .onChange(of: new_player_text) { newValue in
            if newValue == "New player" {
                new_player_text = ""
                isCreatingNewPlayer = true
                DispatchQueue.main.async {
                    isPlayerFieldFocused = true
                }
            } else if !isCreatingNewPlayer && !newValue.isEmpty && newValue != "Select or create new player" {
                new_transport_text = "Select transport co."
                isPlayerFieldFocused = false
            }
        }
        // MARK: - Confirm Purchase
        .alert("Confirm Purchase", isPresented: $showingConfirmationAlert) {
            Button("Cancel", role: .cancel) { }
            Button("OK") {
                purchaseTransport()
            }
        } message: {
            let price = commercialDatabase?.transport[new_transport_text]?.price ?? 0
            return Text("Pay $\(price) to Treasurer to purchase \(new_transport_text).")
        }
        // MARK: - Pay Rent
        .alert("Pay Rent", isPresented: $showingRentAlert) {
            Button("Cancel", role: .cancel) {
                new_transport_text = "Select transport co."
            }
            Button("OK") {
                payTransportRent()
                navigateToLanding = true
            }
        } message: {
            let ticketAmount = calculateTicketForOwner(transportOwner)
            let companiesOwned = transportDatabase?.owners[transportOwner]?.count ?? 0
            return Text("Pay $\(ticketAmount) rent to \(transportOwner) for \(new_transport_text) (\(companiesOwned) \(companiesOwned == 1 ? "company" : "companies") owned).")
        }
    }

    // MARK: - Private Helpers

    private func loadData() {
        if let data: TransportCommercialDatabase = readJsonDatabase(filename: "Commercial_properties.json") {
            commercialDatabase = data
        }

        if let data: PlayerDatabase = readJsonDatabase(filename: "Player_database.json") {
            playerDatabase = data
        }
        var allPlayerNames: Set<String> = Set(playerDatabase.map { Array($0.players.keys) } ?? [])
        if let accountsData: PlayerAccountsDatabase = readJsonDatabase(filename: "Player_accounts.json") {
            allPlayerNames.formUnion(accountsData.accounts.keys)
        }
        player_names = ["New player"] + allPlayerNames.sorted()

        transportDatabase = readJsonDatabase(filename: "Transport_database.json") ?? TransportDatabase()
    }

    private func checkTransportOwnership(companyName: String) -> String? {
        guard let db = transportDatabase else { return nil }
        return db.owners.first { $0.value.contains(companyName) }?.key
    }

    /// Ticket = fare based on how many transport companies the owner currently holds.
    /// E.g. owner holds 1 → key "1 owned" → 40; 4 → "4 owned" → 320
    private func calculateTicketForOwner(_ owner: String) -> Int {
        let owned = transportDatabase?.owners[owner]?.count ?? 0
        let key = "\(owned) owned"
        return commercialDatabase?.transport[new_transport_text]?.ticket[key] ?? 0
    }

    private func purchaseTransport() {
        let price = commercialDatabase?.transport[new_transport_text]?.price ?? 0

        // Record ownership in Transport_database.json
        var db = transportDatabase ?? TransportDatabase()
        if db.owners[new_player_text] == nil { db.owners[new_player_text] = [] }
        db.owners[new_player_text]?.append(new_transport_text)
        writeJsonDatabase(filename: "Transport_database.json", data: db)
        transportDatabase = db

        // Record entry in Player_database.json (locality = "Transport", no houses)
        var playerDB: PlayerDatabase = readJsonDatabase(filename: "Player_database.json") ?? PlayerDatabase(players: [:])
        var playerEntry = playerDB.players[new_player_text] ?? [:]
        var transportLocality = playerEntry["Transport"] ?? [:]
        transportLocality[new_transport_text] = PropertyInfo(houses: nil)
        playerEntry["Transport"] = transportLocality
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
            Transaction(paymentAmount: Double(-price), paymentSource: "Treasurer", purpose: "Purchase of \(new_transport_text) (Transport)")
        )
        writeJsonDatabase(filename: "Player_accounts.json", data: accountsDB)

        navigateToLanding = true
    }

    private func payTransportRent() {
        let ticketAmount = calculateTicketForOwner(transportOwner)
        let purpose = "Rent for \(new_transport_text)"

        var accountsDB: PlayerAccountsDatabase = readJsonDatabase(filename: "Player_accounts.json") ?? PlayerAccountsDatabase(accounts: [:])

        // Debit paying player
        if accountsDB.accounts[new_player_text] == nil {
            accountsDB.accounts[new_player_text] = []
            accountsDB.accounts[new_player_text]?.append(Transaction(paymentAmount: 1500, paymentSource: "Treasurer", purpose: "Initial deposit"))
        }
        accountsDB.accounts[new_player_text]?.append(
            Transaction(paymentAmount: Double(-ticketAmount), paymentSource: transportOwner, purpose: purpose)
        )

        // Credit owner
        if accountsDB.accounts[transportOwner] == nil {
            accountsDB.accounts[transportOwner] = []
            accountsDB.accounts[transportOwner]?.append(Transaction(paymentAmount: 1500, paymentSource: "Treasurer", purpose: "Initial deposit"))
        }
        accountsDB.accounts[transportOwner]?.append(
            Transaction(paymentAmount: Double(ticketAmount), paymentSource: new_player_text, purpose: purpose)
        )

        writeJsonDatabase(filename: "Player_accounts.json", data: accountsDB)
    }
}

struct TransportPage_Previews: PreviewProvider {
    static var previews: some View {
        TransportPage()
    }
}
