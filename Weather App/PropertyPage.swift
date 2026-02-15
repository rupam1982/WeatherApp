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
        .onChange(of: new_player_text) { newValue in
            if newValue == "New player" {
                new_player_text = ""
                isCreatingNewPlayer = true
                isPlayerFieldFocused = true
            } else if !newValue.isEmpty && newValue != "Select or create new player" {
                isCreatingNewPlayer = false
            }
        }
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
    let players: [String: [String: [String: PropertyInfo]]]
    
    enum CodingKeys: String, CodingKey {
        case players = ""
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        players = try container.decode([String: [String: [String: PropertyInfo]]].self)
    }
}

func readJsonDatabase<T: Codable>(filename: String) -> T? {
    guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        return nil
    }
    let fileURL = documentsDirectoryURL.appendingPathComponent(filename)

    do {
        let data = try Data(contentsOf: fileURL)
        let decodedData = try JSONDecoder().decode(T.self, from: data)
        return decodedData
    } catch {
        return nil
    }
}

struct PropertyPage_Previews: PreviewProvider {
    static var previews: some View {
        PropertyPage()
    }
}
