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
        let houses: Int
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
                            
                            Text("Locality")
                                .padding()
                                .frame(width: 250, alignment: .leading)
                                .background(Color.blue)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                            
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: 1)
                            
                            Text("Property")
                                .padding()
                                .frame(width: 250, alignment: .leading)
                                .background(Color.blue)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                            
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: 1)
                            
                            Text("No of Houses")
                                .padding()
                                .frame(width: 230, alignment: .leading)
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
                                
                                Text(row.locality)
                                    .padding()
                                    .frame(width: 250, alignment: .leading)
                                    .lineLimit(1)
                                    .background(Color.white.opacity(0.8))
                                    .font(.system(size: 24))
                                    .foregroundColor(.black)
                                
                                Rectangle()
                                    .fill(Color.black)
                                    .frame(width: 1)
                                
                                Text(row.property)
                                    .padding()
                                    .frame(width: 250, alignment: .leading)
                                    .lineLimit(1)
                                    .background(Color.white.opacity(0.8))
                                    .font(.system(size: 24))
                                    .foregroundColor(.black)
                                
                                Rectangle()
                                    .fill(Color.black)
                                    .frame(width: 1)
                                
                                Text("\(row.houses)")
                                    .padding()
                                    .frame(width: 230, alignment: .leading)
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
            loadPlayerData()
        }
    }
    
    private func loadPlayerData() {
        if let data: PlayerDatabase = readJsonDatabase(filename: "Player_database.json") {
            playerDatabase = data
            
            var rows: [TableRow] = []
            for (player, localities) in data.players.sorted(by: { $0.key < $1.key }) {
                for (locality, properties) in localities.sorted(by: { $0.key < $1.key }) {
                    for (property, propertyInfo) in properties.sorted(by: { $0.key < $1.key }) {
                        let houses = propertyInfo.houses ?? 0
                        rows.append(TableRow(player: player, locality: locality, property: property, houses: houses))
                    }
                }
            }
            tableData = rows
        }
    }
}

struct DatabasePage_Previews: PreviewProvider {
    static var previews: some View {
        DatabasePage()
    }
}
