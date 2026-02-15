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
                        Button(action: {
                            print("Utilities button tapped")
                        }) {
                            ActionIcon(actionName: "Utilities", imageName: "airplane.departure")
                        }
                    }
                    
                    HStack(spacing: 20) {
                        Button(action: {
                            print("Treasury button tapped")
                        }) {
                            ActionIcon(actionName: "Treasury", imageName: "dollarsign.bank.building")
                        }
                        Button(action: {
                            print("Database button tapped")
                        }) {
                            ActionIcon(actionName: "Database", imageName: "character.book.closed")
                        }
                    }
                    
                }
                    
            }
        }
        }
        .onAppear {
            copyJSONFileToDocumentsDirectory(filename: "Player_accounts", fileExtension: "json")
            copyJSONFileToDocumentsDirectory(filename: "Asset_database", fileExtension: "json")
            copyJSONFileToDocumentsDirectory(filename: "Commercial_properties", fileExtension: "json")
            copyJSONFileToDocumentsDirectory(filename: "Player_database", fileExtension: "json")
        }
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

func copyJSONFileToDocumentsDirectory(filename: String, fileExtension: String) {
    let fileManager = FileManager.default
    guard let bundleURL = Bundle.main.url(forResource: filename, withExtension: fileExtension) else {
        print("Source file not found in bundle")
        return
    }

    // Get the destination URL in the Documents directory
    guard let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
        print("Documents directory not found")
        return
    }
    let destinationURL = documentsDirectoryURL.appendingPathComponent("\(filename).\(fileExtension)")

    // Check if the file already exists in the Documents directory
    if !fileManager.fileExists(atPath: destinationURL.path) {
        do {
            try fileManager.copyItem(at: bundleURL, to: destinationURL)
            print("File copied to Documents directory")
        } catch {
            print("Error copying file: \(error.localizedDescription)")
        }
    } else {
        print("File already exists in Documents directory")
    }
}

// Call this function when your app launches (e.g., in AppDelegate's didFinishLaunchingWithOptions or a main view's onAppear)
// copyJSONFileToDocumentsDirectory(filename: "yourFileName", fileExtension: "json")
