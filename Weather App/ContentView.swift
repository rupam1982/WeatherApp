//
//  ContentView.swift
//  Weather App
//
//  Created by Slivinski, Benjamin on 10/22/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var isNight = false
    @State private var text = ""
    let options = ["Apple", "Banana", "Cherry"]
    
    
    var body: some View {
        ZStack {
            BackgroundView(isNight: isNight)
            VStack {
                Text("Phoenixville, PA")
                    .font(.system(size:32, weight: .medium, design: .default ))
                    .foregroundColor(.white)
                    .padding()
                
                
                VStack (spacing: 9) {
                    if #available(iOS 18.0, *) {
                        Image(systemName: "thermometer.sun.fill")
                            .resizable()
                            .symbolRenderingMode(.multicolor)
                            .symbolEffect(.breathe)
                            .foregroundColor(.yellow)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 180)
                    } else {
                        Image(systemName: "thermometer.sun.fill")
                            .resizable()
                            .symbolRenderingMode(.multicolor)
                            .foregroundColor(.yellow)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 180)
                    }
                    
                    Text("76")
                        .font(.system(size: 70, weight: .medium))
                        .foregroundColor(.white)
                }
                Spacer().frame(height: 15)
                
                TextBoxWithMenu(text: $text, options: options, backgroundColor: Color.white.opacity(1.0))
                    
                HStack(spacing: 20) {
                    WeatherDayView(dayOfWeek: "Mon", imageName: "cloud.sun.fill", temperature: 70)
                    WeatherDayView(dayOfWeek: "Mon", imageName: "cloud.sun.fill", temperature: 70)
                    WeatherDayView(dayOfWeek: "Mon", imageName: "cloud.sun.fill", temperature: 70)
                    WeatherDayView(dayOfWeek: "Mon", imageName: "cloud.sun.fill", temperature: 70)
                    WeatherDayView(dayOfWeek: "Mon", imageName: "cloud.sun.fill", temperature: 70)
                    WeatherDayView(dayOfWeek: "Mon", imageName: "cloud.sun.fill", temperature: 70)
                }
                Spacer()
                
                Button {
                    isNight.toggle()
                } label: {
                    Weatherbutton(title: "Change Day Time", backgroundcolor: Color.white,
                                  textcolor: Color.blue)
                }
                Spacer()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct TextBoxWithMenu: View {
    @Binding var text: String
    var options: [String]
    var backgroundColor: Color = .white
    var isDisabled: Bool = false
    var allowTyping: Bool = false
    var isFocused: FocusState<Bool>.Binding? = nil

    var body: some View {
        HStack {
            Group {
                if let isFocused = isFocused {
                    TextField("Type or choose…", text: $text)
                        .foregroundColor(.black)
                        .disabled(isDisabled || !allowTyping)
                        .focused(isFocused)
                        .autocorrectionDisabled()
                        .onSubmit {
                            isFocused.wrappedValue = false
                        }
                } else {
                    TextField("Type or choose…", text: $text)
                        .foregroundColor(.black)
                        .disabled(isDisabled || !allowTyping)
                        .autocorrectionDisabled()
                }
            }

            Menu {
                ForEach(options, id: \.self) { item in
                    Button(item) {
                        text = item
                    }
                }
            } label: {
                Image(systemName: "chevron.down")
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .foregroundColor(.black)
                    .contentShape(Rectangle())
            }
            .disabled(isDisabled)
        }
        .padding()
        .background(isDisabled ? backgroundColor.opacity(0.5) : backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct WeatherDayView: View {
        var dayOfWeek: String
        var imageName: String
        var temperature: Int
        
        var body: some View {
            VStack {
                Text(dayOfWeek)
                    . font(.system(size: 16, weight: .medium, design: .default))
                    .foregroundColor(.white)
                Image(systemName: imageName)
                    . renderingMode(.original)
                    . resizable()
                    . aspectRatio(contentMode: .fit)
                    . frame(width: 40, height: 40)
                Text("\(temperature)°")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(.white)
            }
        }
    }
    
    struct BackgroundView: View {
        var isNight: Bool
        
        var body: some View {
            LinearGradient(gradient: Gradient(colors: [isNight ? .black: .blue, isNight ? .gray: .white]), startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .ignoresSafeArea(.all)
        }
    }
    struct CityTextView: View {
        var cityname: String
        var body: some View {
            Text(cityname)
                .font(.system(size:32, weight: .medium, design: .default ))
                .foregroundColor(.white)
                .padding()
        }
    }
    struct MainWeatherStatusView: View {
        var iconName: String
        var temperature: Int
        
        var body: some View {
            VStack (spacing: 9) {
                Image(systemName: iconName)
                    . renderingMode(.original)
                    . resizable()
                    . aspectRatio(contentMode: .fit)
                    . frame(width: 180, height: 180)
                Text("\(temperature)")
                    .font(.system(size: 70, weight: .medium))
                    .foregroundColor(.white)
            }
            
            .padding(.bottom, 40)
        }
    }

struct Weatherbutton: View {
    var title: String
    var backgroundcolor: Color
    var textcolor: Color
    var body: some View {
        Text(title)
            .frame(width: 280, height: 50)
            .background(backgroundcolor)
            .foregroundColor(textcolor)
            .font(.system(size: 20, weight: .bold, design: .default))
            .cornerRadius(10)
    }
}
