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
    
    struct TableRow: Identifiable {
        let id = UUID()
        let player: String
        let amount: Double
        let party: String
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.2, blue: 0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                VStack(spacing: 20) {
                    Text("Player Balance")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 180)
                        .padding(.horizontal)
                        .overlay(
                            PlayerBalanceBarGraph(accountsDatabase: accountsDatabase)
                                .padding()
                        )
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
                        party: transaction.paymentSource
                    ))
                }
            }
            tableData = rows
        }
    }
}

struct TransactionInfo: Codable {
    let paymentAmount: Double
    let paymentSource: String
    
    enum CodingKeys: String, CodingKey {
        case paymentAmount = "payment amount"
        case paymentSource = "payment source"
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
                let minAmountWidth = max(120, calculateMinWidth(for: "Amount", data: tableData.map { String(format: "%.2f", $0.amount) }, fontSize: 18))
                let minPartyWidth = max(120, calculateMinWidth(for: "Party", data: tableData.map { $0.party }, fontSize: 18))
                
                let minTableWidth = minPlayerWidth + minAmountWidth + minPartyWidth + (separatorWidth * 2)
                let availableWidth = geometry.size.width
                
                // Use the larger of minimum content width or available width
                let totalWidth = max(minTableWidth, availableWidth)
                let extraSpace = totalWidth - minTableWidth
                
                // Distribute extra space proportionally
                let playerWidth = minPlayerWidth + (extraSpace / 3)
                let amountWidth = minAmountWidth + (extraSpace / 3)
                let partyWidth = minPartyWidth + (extraSpace / 3)
                
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
                            
                            Text("Amount")
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
                                    .foregroundColor(.black)
                                
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
            }
        }
    }
}
