//
//  ContentView.swift
//  OpenWeatherApp
//

import SwiftUI

struct MainView: View {
    @StateObject var owds = OpenWeatherDataService.instance
    @ObservedObject var cds = CityDataService.instance
    @State var isLoading = true
    var body: some View {
        NavigationStack{
            ZStack{
                if owds.openWeatherError == nil {
                    if cds.cities.isEmpty {
                        if isLoading {
                            showLoading
                        } else {
                            CityEmptyListView()
                            .modifier(CityListModifier(showSearchCity: showSearchCity, cds: cds))
                            .transition(.scale)
                        }
                    } else {
                        CityListView(cds: cds, owds: owds)
                        .modifier(CityListModifier(showSearchCity: showSearchCity, cds: cds))
                        .refreshable { try? cds.loadCities() }
                    }
                } else {
                    showError
                }
            }
            .onAppear() {
                Task{
                    await loadWeathers()
                }
            }
            .ignoresSafeArea()
            
        }
    }
    
//     var showWeathers: some View{
//         GeometryReader { geo in
//             ScrollView(.horizontal){
//                 LazyHStack(spacing: 0){
//                     ForEach(owds.weathers, id:\.self){ weather in
//                         WeatherView(weather: weather)
//                             .frame(width: geo.size.width)
//                     }
//                 }
//             }
//             .transition(.opacity)
//
//         }
//     }
    
    var showLoading: some View{
        VStack(alignment: .center){
            Text("Weather").font(.largeTitle).fontWeight(.bold)
            Text("is loading...").font(.headline).fontWeight(.thin)
        }
        .transition(.scale)
    }
    
    var showProgress: some View{
        ProgressView()
    }
    
    var showError: some View {
        VStack(spacing: 150){
            Spacer()
            List{
                Section(header: Text("Error")) {
                    VStack(alignment: .leading){
                        Text("code: \(owds.openWeatherError?.cod ?? 0)")
                        Text(owds.openWeatherError?.message ?? "")
                            .font(.subheadline.weight(.semibold))
                    }
                }
            }
        }
        .navigationTitle(Text("OpenWeather App"))
    }
    
    func loadWeathers() async {
        do {
            withAnimation { isLoading = true }
            let _ = try await owds.loadWeathers(cityNames: cds.getCityNames())
            withAnimation { isLoading = false }
        } catch {
            print("\(error)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

struct CityListModifier: ViewModifier {
    @State var showSearchCity: Bool
    @ObservedObject var cds:CityDataService
    func body(content: Content) -> some View {
            ZStack {
                    VStack {
                            Spacer()
                        HStack {
                                Spacer()
                                Button(action: {
                                    showSearchCity.toggle()
                                }, label: {
                                    Text("+")
                                    .font(.system(.largeTitle))
                                    .frame(width: 77, height: 70)
                                    .foregroundColor(Color.white)
                                    .padding(.bottom, 7)
                                })
                                .background(Color.blue)
                                .cornerRadius(38.5)
                                .padding()
                                .shadow(color: Color.black.opacity(0.3),
                                        radius: 3,
                                        x: 3,
                                        y: 3)
                                }
                        }
                    }
                })
    }
}

// MARK: Small Custom Detent
extension PresentationDetent{
    static let small = Self.height(100)
}

struct MockCityMainViewPreview:View{
    func mock(){}
    var body: some View{
        CityMainView(loadWeathers: mock)
    }
}

struct CityMainView_Previews: PreviewProvider {
    static var previews: some View {
        MockCityMainViewPreview()
    }

}