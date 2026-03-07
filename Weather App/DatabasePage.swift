//
//  DatabasePage.swift
//  Weather App
//
//  Created by Rupam Mukherjee on 15/02/26.
//

import SwiftUI
import Foundation

struct DatabasePage: View {
    
    @State private var playerDatabase: PlayerDatabase?
    @State private var tableData: [TableRow] = []
    
    struct TableRow: Identifiable {
        let id = UUID()
        let player: String
        let locality: String
        let property: String
        let houses: Int?
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.2, blue: 0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Property Database")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                GeometryReader { geometry in
                    let separatorWidth: CGFloat = 2
                    let padding: CGFloat = 16
                    
                    // Calculate minimum column widths based on content
                    let minPlayerWidth = max(120, calculateMinWidth(for: "Player", data: tableData.map { $0.player }, fontSize: 18))
                    let minLocalityWidth = max(120, calculateMinWidth(for: "Locality", data: tableData.map { $0.locality }, fontSize: 18))
                    let minPropertyWidth = max(120, calculateMinWidth(for: "Property", data: tableData.map { $0.property }, fontSize: 18))
                    let minHousesWidth = max(120, calculateMinWidth(for: "No of Houses", data: tableData.map { $0.houses.map { "\($0)" } ?? "" }, fontSize: 18))
                    
                    let minTableWidth = minPlayerWidth + minLocalityWidth + minPropertyWidth + minHousesWidth + (separatorWidth * 3)
                    let availableWidth = geometry.size.width
                    
                    // Use the larger of minimum content width or available width
                    let totalWidth = max(minTableWidth, availableWidth)
                    let extraSpace = totalWidth - minTableWidth
                    
                    // Distribute extra space proportionally
                    let playerWidth = minPlayerWidth + (extraSpace / 4)
                    let localityWidth = minLocalityWidth + (extraSpace / 4)
                    let propertyWidth = minPropertyWidth + (extraSpace / 4)
                    let housesWidth = minHousesWidth + (extraSpace / 4)
                    
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
                                
                                Text("Locality")
                                    .padding()
                                    .frame(width: localityWidth, alignment: .leading)
                                    .background(Color.blue)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.black)
                                
                                Rectangle()
                                    .fill(Color.black)
                                    .frame(width: separatorWidth)
                                
                                Text("Property")
                                    .padding()
                                    .frame(width: propertyWidth, alignment: .leading)
                                    .background(Color.blue)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.black)
                                
                                Rectangle()
                                    .fill(Color.black)
                                    .frame(width: separatorWidth)
                                
                                Text("No of Houses")
                                    .padding()
                                    .frame(width: housesWidth, alignment: .leading)
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
                                    
                                    Text(row.locality)
                                        .padding()
                                        .frame(width: localityWidth, alignment: .leading)
                                        .lineLimit(1)
                                        .background(Color.white.opacity(0.8))
                                        .font(.system(size: 16))
                                        .foregroundColor(.black)
                                    
                                    Rectangle()
                                        .fill(Color.black)
                                        .frame(width: separatorWidth)
                                    
                                    Text(row.property)
                                        .padding()
                                        .frame(width: propertyWidth, alignment: .leading)
                                        .lineLimit(1)
                                        .background(Color.white.opacity(0.8))
                                        .font(.system(size: 16))
                                        .foregroundColor(.black)
                                    
                                    Rectangle()
                                        .fill(Color.black)
                                        .frame(width: separatorWidth)
                                    
                                    Text(row.houses.map { "\($0)" } ?? "")
                                        .padding()
                                        .frame(width: housesWidth, alignment: .leading)
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
                    .background(Color.white.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal)
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
                    NavigationLink(destination: LandingPage()) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .onAppear {
            loadPlayerData()
        }
    }
    
    private func loadPlayerData() {
        var rows: [TableRow] = []

        // Load residential properties from Player_database.json
        if let data: PlayerDatabase = readJsonDatabase(filename: "Player_database.json") {
            playerDatabase = data
            for (player, localities) in data.players.sorted(by: { $0.key < $1.key }) {
                for (locality, properties) in localities.sorted(by: { $0.key < $1.key }) {
                    for (property, propertyInfo) in properties.sorted(by: { $0.key < $1.key }) {
                        rows.append(TableRow(player: player, locality: locality, property: property, houses: propertyInfo.houses))
                    }
                }
            }
        }

        // Merge utilities directly from Utility_database.json so they always appear
        // even if the Player_database.json write was incomplete
        if let utilityDB: UtilityDatabase = readJsonDatabase(filename: "Utility_database.json") {
            let existingKeys = Set(rows.map { "\($0.player)|\($0.locality)|\($0.property)" })
            for (player, utilities) in utilityDB.owners.sorted(by: { $0.key < $1.key }) {
                for utility in utilities.sorted() {
                    let key = "\(player)|Utilities|\(utility)"
                    if !existingKeys.contains(key) {
                        rows.append(TableRow(player: player, locality: "Utilities", property: utility, houses: nil))
                    }
                }
            }
        }

        // Merge transport companies from Transport_database.json
        if let transportDB: TransportDatabase = readJsonDatabase(filename: "Transport_database.json") {
            let existingKeys = Set(rows.map { "\($0.player)|\($0.locality)|\($0.property)" })
            for (player, companies) in transportDB.owners.sorted(by: { $0.key < $1.key }) {
                for company in companies.sorted() {
                    let key = "\(player)|Transport|\(company)"
                    if !existingKeys.contains(key) {
                        rows.append(TableRow(player: player, locality: "Transport", property: company, houses: nil))
                    }
                }
            }
        }

        // Sort merged list
        rows.sort { ($0.player, $0.locality, $0.property) < ($1.player, $1.locality, $1.property) }

        // Pad to minimum row count
        let minRows = 20
        if rows.count < minRows {
            for _ in rows.count..<minRows {
                rows.append(TableRow(player: "", locality: "", property: "", houses: nil))
            }
        }

        tableData = rows
    }
}

struct DatabasePage_Previews: PreviewProvider {
    static var previews: some View {
        DatabasePage()
    }
}
