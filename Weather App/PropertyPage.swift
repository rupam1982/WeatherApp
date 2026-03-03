//
//  PropertyPage.swift
//  Weather App
//
//  Created by Rupam Mukherjee on 15/02/26.
//

import SwiftUI
import Foundation

struct PropertyPage: View {
    
    @State private var isNight = false
    @State private var new_player_text = "Select or create new player"
    @State private var player_names: [String] = []
    @State private var new_locality_text = "Select locality"
    @State private var locality_names: [String] = []
    @State private var new_property_text = "Select property"
    @State private var property_names: [String] = []
    @State private var number_of_houses: Double = 0
    @State private var propertyDatabase: PropertyDatabase?
    @State private var playerDatabase: PlayerDatabase?
    @State private var isCreatingNewPlayer = false
    @State private var showingConfirmationAlert = false
    @State private var showingRentAlert = false
    @State private var propertyOwner: String = ""
    @State private var navigateToLanding = false
    @FocusState private var isPlayerFieldFocused: Bool
    @FocusState private var isLocalityFieldFocused: Bool
    @FocusState private var isPropertyFieldFocused: Bool
    
    var topRightIconName: String = "house.fill"
    
    private var isPlayerSelected: Bool {
        !new_player_text.isEmpty && new_player_text != "New player"
    }

    private var isLocalitySelected: Bool {
        !new_locality_text.isEmpty
    }
    
    private var isPropertySelected: Bool {
        !new_property_text.isEmpty
    }
    
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
                    isLocalityFieldFocused = false
                    isPropertyFieldFocused = false
                }
            
            VStack {
                VStack {
                Spacer()
                    .onTapGesture {
                        isPlayerFieldFocused = false
                        isLocalityFieldFocused = false
                        isPropertyFieldFocused = false
                    }
                SelectionBox(InputPrompt: "Select Player", new_data_input_text: $new_player_text, option_names: player_names, allowTyping: isCreatingNewPlayer, isFocused: $isPlayerFieldFocused)
                    .id("playerSelectionBox")
                    .onSubmit {
                        isCreatingNewPlayer = false
                        isPlayerFieldFocused = false
                    }
                Spacer()
                    .onTapGesture {
                        isPlayerFieldFocused = false
                        isLocalityFieldFocused = false
                        isPropertyFieldFocused = false
                    }
                SelectionBox(InputPrompt: "Select Locality", new_data_input_text: $new_locality_text, option_names: locality_names, isDisabled: !isPlayerSelected, isFocused: $isLocalityFieldFocused)
                Spacer()
                    .onTapGesture {
                        isPlayerFieldFocused = false
                        isLocalityFieldFocused = false
                        isPropertyFieldFocused = false
                    }
                SelectionBox(InputPrompt: "Select Property", new_data_input_text: $new_property_text, option_names: property_names, isDisabled: !isLocalitySelected, isFocused: $isPropertyFieldFocused)
                Spacer()
                    .onTapGesture {
                        isPlayerFieldFocused = false
                        isLocalityFieldFocused = false
                        isPropertyFieldFocused = false
                    }
                VStack(alignment: .leading, spacing: 16) {
                    Text("No of houses")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.white)

                    HStack(spacing: 8) {
                        ForEach(0...4, id: \.self) { value in
                            Button(action: {
                                number_of_houses = Double(value)
                            }) {
                                Text("\(value)")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(Int(number_of_houses) == value ? .blue : .white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Int(number_of_houses) == value ? Color.white : Color.white.opacity(0.3))
                                    .cornerRadius(8)
                            }
                            .disabled(!isPropertySelected)
                        }
                    }
                }
                .padding(.horizontal, 30)
                .opacity(isPropertySelected ? 1.0 : 0.5)
                Spacer()
                
                Button(action: {
                    showingConfirmationAlert = true
                }) {
                    Text("Save")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(isPropertySelected ? Color.green : Color.gray)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
                .disabled(!isPropertySelected)
                
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
            if let data: PropertyDatabase = readJsonDatabase(filename: "Asset_database.json") {
                propertyDatabase = data
                locality_names = Array(data.properties.keys).sorted()
            }

            if let data: PlayerDatabase = readJsonDatabase(filename: "Player_database.json") {
                playerDatabase = data
                player_names = ["New player"] + Array(data.players.keys).sorted()
            } else {
                player_names = ["New player"]
            }
        }
        .onChange(of: new_locality_text) { newLocality in
            new_property_text = ""
            if let propertyDatabase, let properties = propertyDatabase.properties[newLocality] {
                property_names = Array(properties.keys).sorted()
            } else {
                property_names = []
            }
        }
        .onChange(of: new_property_text) { newProperty in
            // Check property ownership when property is selected
            if !newProperty.isEmpty && newProperty != "Select property" {
                if let owner = checkPropertyOwnership(), owner != new_player_text {
                    // Property owned by another player - show rent alert immediately
                    propertyOwner = owner
                    showingRentAlert = true
                }
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
                // Only process if not in creating mode and selecting from menu
                isPlayerFieldFocused = false
            }
        }
        .alert("Confirm Purchase", isPresented: $showingConfirmationAlert) {
            Button("Cancel", role: .cancel) { }
            Button("OK") {
                purchaseProperty()
            }
        } message: {
            let existingHouses = playerDatabase?.players[new_player_text]?[new_locality_text]?[new_property_text]?.houses ?? 0
            let allowedHouses = min(Int(number_of_houses), 4 - existingHouses)
            let assetInfo = propertyDatabase?.properties[new_locality_text]?[new_property_text]
            let landCost = (existingHouses == 0) ? (assetInfo?.landPrice ?? 0) : 0
            let houseCost = allowedHouses * (assetInfo?.housePrice ?? 0)
            let purchaseCost = landCost + houseCost
            return Text("Pay \(purchaseCost) to Treasurer for \(allowedHouses) houses on \(new_locality_text) \(new_property_text).")
        }
        .alert("Pay Rent", isPresented: $showingRentAlert) {
            Button("Cancel", role: .cancel) {
                // Reset property selection and stay on page
                new_property_text = "Select property"
                number_of_houses = 0
            }
            Button("OK") {
                payRent()
                // Navigate to landing page
                navigateToLanding = true
            }
        } message: {
            let ownerHouses = playerDatabase?.players[propertyOwner]?[new_locality_text]?[new_property_text]?.houses ?? 0
            let assetInfo = propertyDatabase?.properties[new_locality_text]?[new_property_text]
            let rentAmount = rentForHouses(ownerHouses, assetInfo: assetInfo)
            return Text("Pay \(rentAmount) rent to \(propertyOwner) for \(new_locality_text) \(new_property_text).")
        }
    }
    
    private func checkPropertyOwnership() -> String? {
        guard let database = playerDatabase else { return nil }
        
        // Search through all players to find who owns this property
        for (playerName, localities) in database.players {
            if let properties = localities[new_locality_text],
               properties[new_property_text] != nil {
                return playerName
            }
        }
        return nil
    }
    
    private func payRent() {
        let ownerHouses = playerDatabase?.players[propertyOwner]?[new_locality_text]?[new_property_text]?.houses ?? 0
        let assetInfo = propertyDatabase?.properties[new_locality_text]?[new_property_text]
        let rentAmount = rentForHouses(ownerHouses, assetInfo: assetInfo)
        let purpose = "Rent for \(new_locality_text) \(new_property_text)"
        
        var accountsDB: PlayerAccountsDatabase
        if let existingAccounts: PlayerAccountsDatabase = readJsonDatabase(filename: "Player_accounts.json") {
            accountsDB = existingAccounts
        } else {
            accountsDB = PlayerAccountsDatabase(accounts: [:])
        }
        
        // Deduct rent from the paying player
        if accountsDB.accounts[new_player_text] == nil {
            accountsDB.accounts[new_player_text] = []
            accountsDB.accounts[new_player_text]?.append(Transaction(paymentAmount: 1500, paymentSource: "Treasurer", purpose: "Initial deposit"))
        }
        accountsDB.accounts[new_player_text]?.append(Transaction(paymentAmount: Double(-rentAmount), paymentSource: propertyOwner, purpose: purpose))
        
        // Credit rent to the property owner
        if accountsDB.accounts[propertyOwner] == nil {
            accountsDB.accounts[propertyOwner] = []
            accountsDB.accounts[propertyOwner]?.append(Transaction(paymentAmount: 1500, paymentSource: "Treasurer", purpose: "Initial deposit"))
        }
        accountsDB.accounts[propertyOwner]?.append(Transaction(paymentAmount: Double(rentAmount), paymentSource: new_player_text, purpose: purpose))
        
        writeJsonDatabase(filename: "Player_accounts.json", data: accountsDB)
        print("Rent paid: \(new_player_text) paid \(rentAmount) to \(propertyOwner) for \(new_locality_text) \(new_property_text)")
    }
    
    private func rentForHouses(_ houses: Int, assetInfo: AssetInfo?) -> Int {
        guard let rent = assetInfo?.rent else { return 0 }
        switch houses {
        case 0: return rent.noHouses
        case 1: return rent.oneHouse
        case 2: return rent.twoHouses
        case 3: return rent.threeHouses
        default: return rent.fourHouses
        }
    }
    
    private func purchaseProperty() {
        // Validate all required fields are filled
        guard !new_player_text.isEmpty && new_player_text != "Select or create new player",
              !new_locality_text.isEmpty && new_locality_text != "Select locality",
              !new_property_text.isEmpty && new_property_text != "Select property" else {
            print("All fields must be filled before saving")
            return
        }
        
        // Load existing player database or create new one
        var database: PlayerDatabase
        if let existingData: PlayerDatabase = readJsonDatabase(filename: "Player_database.json") {
            database = existingData
        } else {
            database = PlayerDatabase(players: [:])
        }
        
        // Update or create player entry
        let housesToAdd = Int(number_of_houses)
        
        if database.players[new_player_text] == nil {
            database.players[new_player_text] = [:]
        }
        if database.players[new_player_text]?[new_locality_text] == nil {
            database.players[new_player_text]?[new_locality_text] = [:]
        }
        
        // Check if property already exists and add to existing houses
        let existingHouses = database.players[new_player_text]?[new_locality_text]?[new_property_text]?.houses ?? 0
        let allowedHouses = min(housesToAdd, 4 - existingHouses)
        let totalHouses = min(existingHouses + allowedHouses, 4)
        let propertyInfo = PropertyInfo(houses: totalHouses)
        
        database.players[new_player_text]?[new_locality_text]?[new_property_text] = propertyInfo
        
        // Write back to JSON file
        writeJsonDatabase(filename: "Player_database.json", data: database)
        
        // Calculate purchase cost and record transaction
        let assetInfo = propertyDatabase?.properties[new_locality_text]?[new_property_text]
        let landCost = (existingHouses == 0) ? (assetInfo?.landPrice ?? 0) : 0
        let houseCost = allowedHouses * (assetInfo?.housePrice ?? 0)
        let purchaseCost = landCost + houseCost
        
        var accountsDB: PlayerAccountsDatabase
        if let existingAccounts: PlayerAccountsDatabase = readJsonDatabase(filename: "Player_accounts.json") {
            accountsDB = existingAccounts
        } else {
            accountsDB = PlayerAccountsDatabase(accounts: [:])
        }
        if accountsDB.accounts[new_player_text] == nil {
            accountsDB.accounts[new_player_text] = []
            accountsDB.accounts[new_player_text]?.append(Transaction(paymentAmount: 1500, paymentSource: "Treasurer", purpose: "Initial deposit"))
        }
        accountsDB.accounts[new_player_text]?.append(Transaction(paymentAmount: Double(-purchaseCost), paymentSource: "Treasurer", purpose: "Purchase of \(allowedHouses) house(s) in \(new_locality_text) \(new_property_text)"))
        writeJsonDatabase(filename: "Player_accounts.json", data: accountsDB)
        
        // Update the local state
        playerDatabase = database
        
        print("Property saved: \(new_player_text) - \(new_locality_text) - \(new_property_text) - \(totalHouses) houses (added \(housesToAdd))")
        
        // Navigate back to landing page
        navigateToLanding = true
    }
}

struct FlatBackgroundView: View {
    var isNight: Bool

    var body: some View {
        // This replaces the LinearGradient with a solid Color
        (isNight ? Color.black : Color(red: 0.1, green: 0.2, blue: 0.4))
            .ignoresSafeArea() // Ensures the color reaches the very edges of the screen
    }
}

struct SelectionBox: View {
    
    var InputPrompt: String
    @Binding var new_data_input_text: String
    var option_names: [String]
    var isDisabled: Bool = false
    var allowTyping: Bool = false
    var isFocused: FocusState<Bool>.Binding
    
    var body: some View {
        VStack(alignment: .leading, spacing:20) {
            Text(InputPrompt)
                .font(.system(size:32, weight: .medium, design: .default ))
                .foregroundColor(.white)

            TextBoxWithMenu(text: $new_data_input_text, options: option_names, backgroundColor: Color.white.opacity(1.0), isDisabled: isDisabled, allowTyping: allowTyping, isFocused: isFocused)
                .font(.system(size: 20))
            
        }
        .padding(.horizontal, 30)
    }
}

struct PropertyInfo: Codable {
    let houses: Int?
}

struct RentInfo: Codable {
    let noHouses: Int
    let oneHouse: Int
    let twoHouses: Int
    let threeHouses: Int
    let fourHouses: Int
    
    enum CodingKeys: String, CodingKey {
        case noHouses = "no_houses"
        case oneHouse = "one_house"
        case twoHouses = "two_houses"
        case threeHouses = "three_houses"
        case fourHouses = "four_houses"
    }
}

struct AssetInfo: Codable {
    let landPrice: Int
    let housePrice: Int
    let rent: RentInfo
    
    enum CodingKeys: String, CodingKey {
        case landPrice = "land_price"
        case housePrice = "house_price"
        case rent
    }
}

struct PropertyDatabase: Codable {
    let properties: [String: [String: AssetInfo]]
    
    enum CodingKeys: String, CodingKey {
        case properties = ""
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        properties = try container.decode([String: [String: AssetInfo]].self)
    }
}

struct PlayerDatabase: Codable {
    var players: [String: [String: [String: PropertyInfo]]]
    
    enum CodingKeys: String, CodingKey {
        case players = ""
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        players = try container.decode([String: [String: [String: PropertyInfo]]].self)
    }
    
    init(players: [String: [String: [String: PropertyInfo]]]) {
        self.players = players
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(players)
    }
}

func readJsonDatabase<T: Codable>(filename: String) -> T? {
    guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        return nil
    }
    let documentsFileURL = documentsDirectoryURL.appendingPathComponent(filename)
    
    // First try to read from documents directory (writable location)
    if FileManager.default.fileExists(atPath: documentsFileURL.path) {
        do {
            let data = try Data(contentsOf: documentsFileURL)
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return decodedData
        } catch {
            print("Error reading from documents directory: \(error)")
        }
    }
    
    // If not in documents directory, read from app bundle (initial read-only copy)
    if let bundleURL = Bundle.main.url(forResource: filename.replacingOccurrences(of: ".json", with: ""), withExtension: "json") {
        do {
            let data = try Data(contentsOf: bundleURL)
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            
            // Copy to documents directory for future writes
            try? data.write(to: documentsFileURL)
            
            return decodedData
        } catch {
            print("Error reading from bundle: \(error)")
        }
    }
    
    return nil
}

func writeJsonDatabase<T: Codable>(filename: String, data: T) {
    guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        print("Error: Could not access documents directory")
        return
    }
    let fileURL = documentsDirectoryURL.appendingPathComponent(filename)

    do {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(data)
        try jsonData.write(to: fileURL)
        print("Successfully wrote to \(filename)")
    } catch {
        print("Error writing to \(filename): \(error)")
    }
}

struct PropertyPage_Previews: PreviewProvider {
    static var previews: some View {
        PropertyPage()
    }
}
