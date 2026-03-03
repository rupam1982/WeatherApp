//
//  LandingPage.swift
//  Weather App
//
//  Created by Rupam Mukherjee on 08/02/26.
//

import SwiftUI
import Foundation

struct LandingPage: View {
    
    @State private var isNight = false
    @State private var text = ""
    @State private var showingClearConfirmation = false
    @State private var tooltipText: String = ""
    @State private var showTooltip: Bool = false
    @State private var navigateToTransactions = false
    @State private var navigateToDatabase = false
    let options = ["Apple", "Banana", "Cherry"]
    
    
    var body: some View {
        NavigationStack {
        ZStack {
            BackgroundView(isNight: isNight)
            
            VStack(spacing:100) {
                Text("Anti-Monopoly")
                    .font(.system(size:50, weight: .medium, design: .default ))
                    .foregroundColor(.white)
                
                VStack(spacing: 20) {
                    
                    HStack(spacing: 20) {
                        NavigationLink(destination: PropertyPage()) {
                            ActionIcon(actionName: "Property", imageName: "house.fill")
                        }
                        NavigationLink(destination: UtilitiesPage()) {
                            ActionIcon(actionName: "Utilities", imageName: "airplane.departure")
                        }
                    }
                    
                    HStack(spacing: 20) {
                        NavigationLink(destination: DatabasePage()) {
                            ActionIcon(actionName: "Database", imageName: "character.book.closed")
                        }
                        Button(action: {
                            // Treasury action placeholder
                        }) {
                            ActionIcon(actionName: "Treasury", imageName: "dollarsign.bank.building")
                        }
                    }
                    
                }
                
                // Bottom navigation bar with icons
                ZStack(alignment: .top) {
                    HStack {
                        NavigationLink(destination: TransactionsDatabase(), isActive: $navigateToTransactions) { EmptyView() }.hidden()
                        NavigationLink(destination: DatabasePage(), isActive: $navigateToDatabase) { EmptyView() }.hidden()

                        Image(systemName: "dollarsign")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .onTapGesture { navigateToTransactions = true }
                            .onLongPressGesture(minimumDuration: 0.5) {
                                tooltipText = "Check player account status"
                                showTooltip = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { showTooltip = false }
                            }
                        Spacer()
                        Image(systemName: "books.vertical")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .onTapGesture { navigateToDatabase = true }
                            .onLongPressGesture(minimumDuration: 0.5) {
                                tooltipText = "Check player property records"
                                showTooltip = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { showTooltip = false }
                            }
                        Spacer()
                        Image(systemName: "document.on.trash")
                            .renderingMode(.template)
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .onTapGesture { showingClearConfirmation = true }
                            .onLongPressGesture(minimumDuration: 0.5) {
                                tooltipText = "Clear all records and restart game"
                                showTooltip = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { showTooltip = false }
                            }
                    }
                    .padding(16)
                    .frame(width: 340)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue)
                    )

                    if showTooltip {
                        Text(tooltipText)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.black.opacity(0.75))
                            )
                            .offset(y: -44)
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.2), value: showTooltip)
                    }
                }
                    
            }
        }
        }

        .alert("Clear All Databases", isPresented: $showingClearConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                clearDatabases()
            }
        } message: {
            Text("This will permanently delete all player data and accounts. This action cannot be undone.")
        }
        .onAppear {
            copyJSONFileToDocumentsDirectory(filename: "Player_accounts", fileExtension: "json")
            copyJSONFileToDocumentsDirectory(filename: "Asset_database", fileExtension: "json")
            copyJSONFileToDocumentsDirectory(filename: "Commercial_properties", fileExtension: "json")
            copyJSONFileToDocumentsDirectory(filename: "Player_database", fileExtension: "json")
        }
    }
    
    private func clearDatabases() {
        // Clear Player_database.json
        let emptyPlayerDatabase = PlayerDatabase(players: [:])
        writeJsonDatabase(filename: "Player_database.json", data: emptyPlayerDatabase)
        
        // Clear Player_accounts.json
        let emptyAccountsDatabase = PlayerAccountsDatabase(accounts: [:])
        writeJsonDatabase(filename: "Player_accounts.json", data: emptyAccountsDatabase)
        
        // Clear Utility_database.json
        let emptyUtilityDatabase = UtilityDatabase()
        writeJsonDatabase(filename: "Utility_database.json", data: emptyUtilityDatabase)
        
        print("Databases cleared successfully")
    }
}

struct LandingPage_Previews: PreviewProvider {
    static var previews: some View {
        LandingPage()
    }
}

struct ActionIcon: View {
    
    var actionName: String
    var imageName: String
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.8))
                .frame(width: 160, height: 160)
            VStack(spacing:0){
                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 90, height: 90)
                    .foregroundColor(.blue)
                
                Text(actionName)
                    .font(.system(size:32, weight: .bold, design: .default ))
                    .italic()
                    .foregroundColor(.black)
            }
        }
    }
}

struct Transaction: Codable {
    let paymentAmount: Double
    let paymentSource: String
    let purpose: String?
    
    enum CodingKeys: String, CodingKey {
        case paymentAmount = "payment amount"
        case paymentSource = "payment source"
        case purpose = "purpose"
    }
}

struct PlayerAccountsDatabase: Codable {
    var accounts: [String: [Transaction]]
    
    enum CodingKeys: String, CodingKey {
        case accounts = ""
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        accounts = try container.decode([String: [Transaction]].self)
    }
    
    init(accounts: [String: [Transaction]]) {
        self.accounts = accounts
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(accounts)
    }
}

func copyJSONFileToDocumentsDirectory(filename: String, fileExtension: String) {
    let fileManager = FileManager.default
    guard let bundleURL = Bundle.main.url(forResource: filename, withExtension: fileExtension) else {
        return
    }

    // Get the destination URL in the Documents directory
    guard let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
        return
    }
    let destinationURL = documentsDirectoryURL.appendingPathComponent("\(filename).\(fileExtension)")

    // Check if the file already exists in the Documents directory
    if !fileManager.fileExists(atPath: destinationURL.path) {
        do {
            try fileManager.copyItem(at: bundleURL, to: destinationURL)
        } catch {
            // Silently handle error
        }
    }
}

// Call this function when your app launches (e.g., in AppDelegate's didFinishLaunchingWithOptions or a main view's onAppear)
// copyJSONFileToDocumentsDirectory(filename: "yourFileName", fileExtension: "json")
