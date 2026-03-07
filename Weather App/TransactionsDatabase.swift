//
//  TransactionsDatabase.swift
//  Weather App
//
//  Created by Rupam Mukherjee on 15/02/26.
//

import SwiftUI
import Foundation

struct TransactionsDatabase: View {
    
    @State private var accountsDatabase: AccountsDatabase?
    @State private var tableData: [TableRow] = []
    @State private var playerDatabase: PlayerDatabase?
    @State private var propertyDatabase: PropertyDatabase?
    @State private var utilityDatabase: UtilityDatabase?
    @State private var transportDatabase: TransportDatabase?
    @State private var commercialDatabase: CommercialPropertiesDatabase?
    @State private var transportCommercialDatabase: TransportCommercialDatabase?
    @State private var cardPage = 0
    
    struct TableRow: Identifiable {
        let id = UUID()
        let player: String
        let amount: Double
        let party: String
        let purpose: String
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.2, blue: 0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
            VStack(spacing: 0) {
                TabView(selection: $cardPage) {
                    // Page 0 – Net Asset Value
                    VStack(spacing: 10) {
                        Text("Net Asset Value")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top, 20)

                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 180)
                            .padding(.horizontal)
                            .overlay(
                                PlayerNetAssetBarGraph(
                                    accountsDatabase: accountsDatabase,
                                    playerDatabase: playerDatabase,
                                    propertyDatabase: propertyDatabase,
                                    utilityDatabase: utilityDatabase,
                                    transportDatabase: transportDatabase,
                                    commercialDatabase: commercialDatabase,
                                    transportCommercialDatabase: transportCommercialDatabase
                                )
                                .padding(.horizontal, 12)
                                .padding(.top, 12)
                                .padding(.bottom, 36)
                            )
                    }
                    .tag(0)

                    // Page 1 – Cash Balance
                    VStack(spacing: 10) {
                        Text("Cash Balance")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top, 20)

                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 180)
                            .padding(.horizontal)
                            .overlay(
                                PlayerBalanceBarGraph(accountsDatabase: accountsDatabase)
                                    .padding(.horizontal, 12)
                                    .padding(.top, 12)
                                    .padding(.bottom, 36)
                            )
                    }
                    .tag(1)

                    // Page 2 – Property Value
                    VStack(spacing: 10) {
                        Text("Property Value")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top, 20)

                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 180)
                            .padding(.horizontal)
                            .overlay(
                                PlayerAssetBarGraph(
                                    playerDatabase: playerDatabase,
                                    propertyDatabase: propertyDatabase,
                                    utilityDatabase: utilityDatabase,
                                    transportDatabase: transportDatabase,
                                    commercialDatabase: commercialDatabase,
                                    transportCommercialDatabase: transportCommercialDatabase
                                )
                                .padding(.horizontal, 12)
                                .padding(.top, 12)
                                .padding(.bottom, 36)
                            )
                    }
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .frame(height: 270)
            }
                
                TransactionTable(tableData: tableData)
            }
        
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 10) {
                    NavigationLink(destination: DatabasePage()) {
                        Image(systemName: "books.vertical")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                    NavigationLink(destination: LandingPage()) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .onAppear {
            loadAccountsData()
        }
    }
    
    private func loadAccountsData() {
        if let data: AccountsDatabase = readJsonDatabase(filename: "Player_accounts.json") {
            accountsDatabase = data

            var rows: [TableRow] = []
            for (player, transactions) in data.accounts.sorted(by: { $0.key < $1.key }) {
                for transaction in transactions {
                    rows.append(TableRow(
                        player: player,
                        amount: transaction.paymentAmount,
                        party: transaction.paymentSource,
                        purpose: transaction.purpose ?? ""
                    ))
                }
            }
            tableData = rows
        }

        playerDatabase   = readJsonDatabase(filename: "Player_database.json")
        propertyDatabase = readJsonDatabase(filename: "Asset_database.json")
        utilityDatabase  = readJsonDatabase(filename: "Utility_database.json") ?? UtilityDatabase()
        transportDatabase = readJsonDatabase(filename: "Transport_database.json") ?? TransportDatabase()
        commercialDatabase          = readJsonDatabase(filename: "Commercial_properties.json")
        transportCommercialDatabase = readJsonDatabase(filename: "Commercial_properties.json")
    }
}

struct TransactionInfo: Codable {
    let paymentAmount: Double
    let paymentSource: String
    let purpose: String?
    
    enum CodingKeys: String, CodingKey {
        case paymentAmount = "payment amount"
        case paymentSource = "payment source"
        case purpose = "purpose"
    }
}

struct AccountsDatabase: Codable {
    let accounts: [String: [TransactionInfo]]
    
    enum CodingKeys: String, CodingKey {
        case accounts = ""
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        accounts = try container.decode([String: [TransactionInfo]].self)
    }
}

struct TransactionsDatabase_Previews: PreviewProvider {
    static var previews: some View {
        TransactionsDatabase()
    }
}

struct TransactionTable: View {
    
    let tableData: [TransactionsDatabase.TableRow]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Transactions Database")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 20)
            
            GeometryReader { geometry in
                let separatorWidth: CGFloat = 2
                let padding: CGFloat = 16
                
                // Calculate minimum column widths based on content
                let minPlayerWidth = max(120, calculateMinWidth(for: "Player", data: tableData.map { $0.player }, fontSize: 18))
                let minAmountWidth = max(120, calculateMinWidth(for: "Amount ($)", data: tableData.map { String(format: "%.2f", $0.amount) }, fontSize: 18))
                let minPartyWidth = max(120, calculateMinWidth(for: "Party", data: tableData.map { $0.party }, fontSize: 18))
                let minPurposeWidth = max(200, calculateMinWidth(for: "Purpose", data: tableData.map { $0.purpose }, fontSize: 18))
                
                let minTableWidth = minPlayerWidth + minAmountWidth + minPartyWidth + minPurposeWidth + (separatorWidth * 3)
                let availableWidth = geometry.size.width
                
                // Use the larger of minimum content width or available width
                let totalWidth = max(minTableWidth, availableWidth)
                let extraSpace = totalWidth - minTableWidth
                
                // Distribute extra space proportionally
                let playerWidth = minPlayerWidth + (extraSpace / 4)
                let amountWidth = minAmountWidth + (extraSpace / 4)
                let partyWidth = minPartyWidth + (extraSpace / 4)
                let purposeWidth = minPurposeWidth + (extraSpace / 4)
                
                ScrollView([.horizontal, .vertical]) {
                    VStack(spacing: 0) {
                        // Header Row
                        HStack(spacing: 0) {
                            Text("Player")
                                .padding()
                                .frame(width: playerWidth, alignment: .leading)
                                .background(Color.blue)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                            
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: separatorWidth)
                            
                            Text("Amount ($)")
                                .padding()
                                .frame(width: amountWidth, alignment: .leading)
                                .background(Color.blue)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                            
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: separatorWidth)
                            
                            Text("Party")
                                .padding()
                                .frame(width: partyWidth, alignment: .leading)
                                .background(Color.blue)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                            
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: separatorWidth)
                            
                            Text("Purpose")
                                .padding()
                                .frame(width: purposeWidth, alignment: .leading)
                                .background(Color.blue)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                        }
                        
                        Rectangle()
                            .fill(Color.black)
                            .frame(height: 1)
                        
                        // Data Rows
                        ForEach(tableData) { row in
                            HStack(spacing: 0) {
                                Text(row.player)
                                    .padding()
                                    .frame(width: playerWidth, alignment: .leading)
                                    .lineLimit(1)
                                    .background(Color.white.opacity(0.8))
                                    .font(.system(size: 16))
                                    .foregroundColor(.black)
                                
                                Rectangle()
                                    .fill(Color.black)
                                    .frame(width: separatorWidth)
                                
                                Text(String(format: "%.2f", row.amount))
                                    .padding()
                                    .frame(width: amountWidth, alignment: .leading)
                                    .lineLimit(1)
                                    .background(Color.white.opacity(0.8))
                                    .font(.system(size: 16))
                                    .foregroundColor(row.amount >= 0 ? .green : .red)
                                
                                Rectangle()
                                    .fill(Color.black)
                                    .frame(width: separatorWidth)
                                
                                Text(row.party)
                                    .padding()
                                    .frame(width: partyWidth, alignment: .leading)
                                    .lineLimit(1)
                                    .background(Color.white.opacity(0.8))
                                    .font(.system(size: 16))
                                    .foregroundColor(.black)
                                
                                Rectangle()
                                    .fill(Color.black)
                                    .frame(width: separatorWidth)
                                
                                Text(row.purpose)
                                    .padding()
                                    .frame(width: purposeWidth, alignment: .leading)
                                    .lineLimit(1)
                                    .background(Color.white.opacity(0.8))
                                    .font(.system(size: 16))
                                    .foregroundColor(.black)
                            }
                            
                            Rectangle()
                                .fill(Color.black)
                                .frame(height: 1)
                        }
                    }
                }
                .background(Color.white.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal)
        }
    }
}

func calculateMinWidth(for header: String, data: [String], fontSize: CGFloat) -> CGFloat {
    let allTexts = [header] + data
    let font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
    let maxWidth = allTexts.map { text -> CGFloat in
        let attributes = [NSAttributedString.Key.font: font]
        let size = (text as NSString).size(withAttributes: attributes)
        return size.width + 32  // Add padding
    }.max() ?? 100
    return maxWidth
}

struct PlayerBalanceBarGraph: View {
    let accountsDatabase: AccountsDatabase?
    
    var playerBalances: [(player: String, balance: Double)] {
        guard let database = accountsDatabase else { return [] }
        
        var balances: [(String, Double)] = []
        for (player, transactions) in database.accounts.sorted(by: { $0.key < $1.key }) {
            let balance = transactions.reduce(0.0) { $0 + $1.paymentAmount }
            balances.append((player, balance))
        }
        return balances
    }
    
    var maxBalance: Double {
        guard let max = playerBalances.map({ abs($0.balance) }).max(), max > 0 else { return 1 }
        return max
    }
    
    var body: some View {
        GeometryReader { geometry in
            let margin: CGFloat = 16
            let spacing: CGFloat = 16
            let totalMargins = margin * 2
            let totalSpacing = CGFloat(max(0, playerBalances.count - 1)) * spacing
            let barWidth = (geometry.size.width - totalMargins - totalSpacing) / CGFloat(max(1, playerBalances.count))
            let maxBarHeight = (geometry.size.height - 60) / 2  // Split height for positive and negative
            
            VStack(spacing: 0) {
                // Top section for positive bars
                HStack(alignment: .bottom, spacing: 0) {
                    ForEach(Array(playerBalances.enumerated()), id: \.element.player) { index, element in
                        let (player, balance) = element
                        HStack(spacing: 0) {
                            if index == 0 {
                                Spacer().frame(width: margin)
                            }
                            
                            VStack(spacing: 0) {
                                if balance >= 0 {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.green.opacity(0.8))
                                        .frame(width: barWidth, height: max(20, (balance / maxBalance) * maxBarHeight))
                                        .overlay(
                                            Text(String(format: "%.0f", balance))
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.white)
                                        )
                                } else {
                                    Spacer()
                                }
                            }
                            .frame(width: barWidth)
                            
                            if index < playerBalances.count - 1 {
                                Spacer().frame(width: spacing)
                            } else {
                                Spacer().frame(width: margin)
                            }
                        }
                    }
                }
                .frame(height: maxBarHeight + 20)
                
                // X-axis line (full width)
                Rectangle()
                    .fill(Color.white.opacity(0.5))
                    .frame(height: 2)
                
                // Bottom section for negative bars
                HStack(alignment: .top, spacing: 0) {
                    ForEach(Array(playerBalances.enumerated()), id: \.element.player) { index, element in
                        let (player, balance) = element
                        HStack(spacing: 0) {
                            if index == 0 {
                                Spacer().frame(width: margin)
                            }
                            
                            VStack(spacing: 0) {
                                if balance < 0 {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.red.opacity(0.8))
                                        .frame(width: barWidth, height: max(20, (abs(balance) / maxBalance) * maxBarHeight))
                                        .overlay(
                                            Text(String(format: "%.0f", balance))
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.white)
                                        )
                                } else {
                                    Spacer()
                                }
                            }
                            .frame(width: barWidth)
                            
                            if index < playerBalances.count - 1 {
                                Spacer().frame(width: spacing)
                            } else {
                                Spacer().frame(width: margin)
                            }
                        }
                    }
                }
                .frame(height: maxBarHeight + 20)
                
                // Player names at the bottom
                HStack(spacing: 0) {
                    ForEach(Array(playerBalances.enumerated()), id: \.element.player) { index, element in
                        let (player, _) = element
                        HStack(spacing: 0) {
                            if index == 0 {
                                Spacer().frame(width: margin)
                            }
                            
                            Text(player)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .frame(width: barWidth)
                            
                            if index < playerBalances.count - 1 {
                                Spacer().frame(width: spacing)
                            } else {
                                Spacer().frame(width: margin)
                            }
                        }
                    }
                }
                .frame(height: 18)
                .padding(.bottom, 24)
            }
        }
    }
}

struct PlayerNetAssetBarGraph: View {
    let accountsDatabase: AccountsDatabase?
    let playerDatabase: PlayerDatabase?
    let propertyDatabase: PropertyDatabase?
    let utilityDatabase: UtilityDatabase?
    let transportDatabase: TransportDatabase?
    let commercialDatabase: CommercialPropertiesDatabase?
    let transportCommercialDatabase: TransportCommercialDatabase?

    var playerNetValues: [(player: String, value: Double)] {
        var allPlayers: Set<String> = []
        if let db = accountsDatabase { allPlayers.formUnion(db.accounts.keys) }
        if let db = playerDatabase { allPlayers.formUnion(db.players.keys) }
        if let db = utilityDatabase { allPlayers.formUnion(db.owners.keys) }
        if let db = transportDatabase { allPlayers.formUnion(db.owners.keys) }

        return allPlayers.sorted().map { player in
            // Cash balance
            var cash: Double = 0
            if let transactions = accountsDatabase?.accounts[player] {
                cash = transactions.reduce(0.0) { $0 + $1.paymentAmount }
            }

            // Liquidation value (50% of all assets)
            var assets: Double = 0
            if let localities = playerDatabase?.players[player] {
                for (locality, properties) in localities {
                    if locality == "Utilities" || locality == "Transport" { continue }
                    for (property, info) in properties {
                        if let assetInfo = propertyDatabase?.properties[locality]?[property] {
                            assets += Double(assetInfo.landPrice) * 0.5
                            if let houses = info.houses {
                                assets += Double(houses * assetInfo.housePrice) * 0.5
                            }
                        }
                    }
                }
            }
            if let owned = utilityDatabase?.owners[player] {
                for utility in owned {
                    let price = commercialDatabase?.utilities[utility]?.price ?? 150
                    assets += Double(price) * 0.5
                }
            }
            if let owned = transportDatabase?.owners[player] {
                for company in owned {
                    let price = transportCommercialDatabase?.transport[company]?.price ?? 200
                    assets += Double(price) * 0.5
                }
            }

            return (player: player, value: cash + assets)
        }
    }

    var maxAbsValue: Double {
        guard let max = playerNetValues.map({ abs($0.value) }).max(), max > 0 else { return 1 }
        return max
    }

    var body: some View {
        GeometryReader { geometry in
            let margin: CGFloat = 16
            let spacing: CGFloat = 16
            let totalMargins = margin * 2
            let totalSpacing = CGFloat(max(0, playerNetValues.count - 1)) * spacing
            let barWidth = (geometry.size.width - totalMargins - totalSpacing) / CGFloat(max(1, playerNetValues.count))
            let maxBarHeight = (geometry.size.height - 60) / 2

            VStack(spacing: 0) {
                // Positive bars (top)
                HStack(alignment: .bottom, spacing: 0) {
                    ForEach(Array(playerNetValues.enumerated()), id: \.element.player) { index, element in
                        HStack(spacing: 0) {
                            if index == 0 { Spacer().frame(width: margin) }
                            VStack(spacing: 0) {
                                if element.value >= 0 {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.green.opacity(0.8))
                                        .frame(width: barWidth, height: max(20, (element.value / maxAbsValue) * maxBarHeight))
                                        .overlay(
                                            Text(String(format: "%.0f", element.value))
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.white)
                                        )
                                } else {
                                    Spacer()
                                }
                            }
                            .frame(width: barWidth)
                            if index < playerNetValues.count - 1 {
                                Spacer().frame(width: spacing)
                            } else {
                                Spacer().frame(width: margin)
                            }
                        }
                    }
                }
                .frame(height: maxBarHeight + 20)

                Rectangle()
                    .fill(Color.white.opacity(0.5))
                    .frame(height: 2)

                // Negative bars (bottom)
                HStack(alignment: .top, spacing: 0) {
                    ForEach(Array(playerNetValues.enumerated()), id: \.element.player) { index, element in
                        HStack(spacing: 0) {
                            if index == 0 { Spacer().frame(width: margin) }
                            VStack(spacing: 0) {
                                if element.value < 0 {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.red.opacity(0.8))
                                        .frame(width: barWidth, height: max(20, (abs(element.value) / maxAbsValue) * maxBarHeight))
                                        .overlay(
                                            Text(String(format: "%.0f", element.value))
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.white)
                                        )
                                } else {
                                    Spacer()
                                }
                            }
                            .frame(width: barWidth)
                            if index < playerNetValues.count - 1 {
                                Spacer().frame(width: spacing)
                            } else {
                                Spacer().frame(width: margin)
                            }
                        }
                    }
                }
                .frame(height: maxBarHeight + 20)

                // Player names
                HStack(spacing: 0) {
                    ForEach(Array(playerNetValues.enumerated()), id: \.element.player) { index, element in
                        HStack(spacing: 0) {
                            if index == 0 { Spacer().frame(width: margin) }
                            Text(element.player)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .frame(width: barWidth)
                            if index < playerNetValues.count - 1 {
                                Spacer().frame(width: spacing)
                            } else {
                                Spacer().frame(width: margin)
                            }
                        }
                    }
                }
                .frame(height: 18)
                .padding(.bottom, 24)
            }
        }
    }
}

struct PlayerAssetBarGraph: View {
    let playerDatabase: PlayerDatabase?
    let propertyDatabase: PropertyDatabase?
    let utilityDatabase: UtilityDatabase?
    let transportDatabase: TransportDatabase?
    let commercialDatabase: CommercialPropertiesDatabase?
    let transportCommercialDatabase: TransportCommercialDatabase?

    var playerAssetValues: [(player: String, value: Double)] {
        var allPlayers: Set<String> = []
        if let db = playerDatabase { allPlayers.formUnion(db.players.keys) }
        if let db = utilityDatabase { allPlayers.formUnion(db.owners.keys) }
        if let db = transportDatabase { allPlayers.formUnion(db.owners.keys) }

        return allPlayers.sorted().map { player in
            var total: Double = 0

            // Residential / commercial properties — 50% of land + 50% of house value
            if let localities = playerDatabase?.players[player] {
                for (locality, properties) in localities {
                    if locality == "Utilities" || locality == "Transport" { continue }
                    for (property, info) in properties {
                        if let assetInfo = propertyDatabase?.properties[locality]?[property] {
                            total += Double(assetInfo.landPrice) * 0.5
                            if let houses = info.houses {
                                total += Double(houses * assetInfo.housePrice) * 0.5
                            }
                        }
                    }
                }
            }

            // Utilities — 50% of purchase price
            if let owned = utilityDatabase?.owners[player] {
                for utility in owned {
                    let price = commercialDatabase?.utilities[utility]?.price ?? 150
                    total += Double(price) * 0.5
                }
            }

            // Transport — 50% of purchase price
            if let owned = transportDatabase?.owners[player] {
                for company in owned {
                    let price = transportCommercialDatabase?.transport[company]?.price ?? 200
                    total += Double(price) * 0.5
                }
            }

            return (player: player, value: total)
        }
    }

    var maxValue: Double {
        guard let max = playerAssetValues.map({ $0.value }).max(), max > 0 else { return 1 }
        return max
    }

    var body: some View {
        GeometryReader { geometry in
            let margin: CGFloat = 16
            let spacing: CGFloat = 16
            let totalMargins = margin * 2
            let totalSpacing = CGFloat(max(0, playerAssetValues.count - 1)) * spacing
            let barWidth = (geometry.size.width - totalMargins - totalSpacing) / CGFloat(max(1, playerAssetValues.count))
            let maxBarHeight = geometry.size.height - 26

            VStack(spacing: 0) {
                // Bars
                HStack(alignment: .bottom, spacing: 0) {
                    ForEach(Array(playerAssetValues.enumerated()), id: \.element.player) { index, element in
                        HStack(spacing: 0) {
                            if index == 0 { Spacer().frame(width: margin) }
                            VStack(spacing: 0) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.blue.opacity(0.8))
                                    .frame(width: barWidth, height: max(20, (element.value / maxValue) * maxBarHeight))
                                    .overlay(
                                        Text(String(format: "%.0f", element.value))
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                            }
                            .frame(width: barWidth)
                            if index < playerAssetValues.count - 1 {
                                Spacer().frame(width: spacing)
                            } else {
                                Spacer().frame(width: margin)
                            }
                        }
                    }
                }
                .frame(height: maxBarHeight)

                Rectangle()
                    .fill(Color.white.opacity(0.5))
                    .frame(height: 2)

                // Player names
                HStack(spacing: 0) {
                    ForEach(Array(playerAssetValues.enumerated()), id: \.element.player) { index, element in
                        HStack(spacing: 0) {
                            if index == 0 { Spacer().frame(width: margin) }
                            Text(element.player)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .frame(width: barWidth)
                            if index < playerAssetValues.count - 1 {
                                Spacer().frame(width: spacing)
                            } else {
                                Spacer().frame(width: margin)
                            }
                        }
                    }
                }
                .frame(height: 18)
                .padding(.bottom, 24)
            }
        }
    }
}
