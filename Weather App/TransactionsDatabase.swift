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
            
            // VStack(spacing: 20) {
            //     Text("Player Balance")
            //         .font(.system(size: 32, weight: .bold))
            //         .foregroundColor(.white)
            //         .padding(.top, 20)

            //     RoundedRectangle(cornerRadius: 16)
            //         .fill(Color.white.opacity(0.2))
            //         .frame(height: 120)
            //         .padding(.horizontal)
            // }
            
            TransactionTable(tableData: tableData)
            
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: LandingPage()) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
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
            
            ScrollView([.horizontal, .vertical]) {
                VStack(spacing: 0) {
                    // Header Row
                    HStack(spacing: 0) {
                        Text("Player")
                            .padding()
                            .frame(width: 250, alignment: .leading)
                            .background(Color.blue)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                        
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 1)
                        
                        Text("Amount")
                            .padding()
                            .frame(width: 250, alignment: .leading)
                            .background(Color.blue)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                        
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 1)
                        
                        Text("Party")
                            .padding()
                            .frame(width: 250, alignment: .leading)
                            .background(Color.blue)
                            .font(.system(size: 24, weight: .bold))
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
                                .frame(width: 250, alignment: .leading)
                                .lineLimit(1)
                                .background(Color.white.opacity(0.8))
                                .font(.system(size: 24))
                                .foregroundColor(.black)
                            
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: 1)
                            
                            Text(String(format: "%.2f", row.amount))
                                .padding()
                                .frame(width: 250, alignment: .leading)
                                .lineLimit(1)
                                .background(Color.white.opacity(0.8))
                                .font(.system(size: 24))
                                .foregroundColor(.black)
                            
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: 1)
                            
                            Text(row.party)
                                .padding()
                                .frame(width: 250, alignment: .leading)
                                .lineLimit(1)
                                .background(Color.white.opacity(0.8))
                                .font(.system(size: 24))
                                .foregroundColor(.black)
                        }
                        
                        Rectangle()
                            .fill(Color.black)
                            .frame(height: 1)
                    }
                }
                .cornerRadius(8)
            }
            .padding()
        }
    }
}