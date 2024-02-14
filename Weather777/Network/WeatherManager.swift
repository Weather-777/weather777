//
//  WeatherManager.swift
//  Weather777
//
//  Created by Jason Yang on 2/5/24.
//

import Foundation

// 에러 정의
enum NetworkError: Error {
    case badUrl
    case noData
    case decodingError
    case badLocation
}

class WeatherManager {
    
    // MARK: - UI Properties
    // 싱글톤 정적상수 활용
    static let shared = WeatherManager()
    
    private init() {}
    
    // MARK: - public Methods
    
    public func getForecastWeather(latitude: Double, longitude: Double, completion: @escaping(Result<[(cityname: String, time: String, weatherIcon: String, temperature: Double, wind: String, humidity: Int, tempMin: Double, tempMax: Double, feelsLike: Double, rainfall: Double)], NetworkError>) -> Void) {
        // 위치데이터
        LocationManager.shared.setLocation(latitude: latitude, longitude: longitude)
        guard let currentLocation = LocationManager.shared.currentLocation else {
            return completion(.failure(.badLocation))
        }
        
        //API call
        guard let url = URL.urlForForecastForLocation(currentLocation, apiKey: apiKey) else {
            return completion(.failure(.badUrl))
        }
        
        //API call에서 데이터를 forecastData 배열에 넣기
        performRequestForecast(with: url) { result in
            switch result {
                //performRequestForecast매소드에서 let weatherData = try JSONDecoder().decode(WeatherData.self, from: data) 이 성공했을 때,
            case .success(let weatherData):
                // 날씨 데이터를 성공적으로 받아왔을 때
                let processor = WeatherDataProcessor()
                let forecastData = processor.process(weatherData: weatherData)
                completion(.success(forecastData))
                
            case .failure(let error):
                // 날씨 데이터를 받아오는데 실패했을 때
                completion(.failure(error))
            }
        }
    }
    

    
    
}

// MARK: - Extensions
extension WeatherManager {
    //plist를 통해 숨긴 API 호출을 위한 프로퍼티
    var apiKey: String {
        get {
            // 생성한 .plist 파일 경로 불러오기
            guard let filePath = Bundle.main.path(forResource: "WeatherKey", ofType: "plist") else {
                fatalError("Couldn't find file 'WeatherKey.plist'.")
            }
            
            // .plist를 딕셔너리로 받아오기
            let plist = NSDictionary(contentsOfFile: filePath)
            
            // 딕셔너리에서 값 찾기
            guard let value = plist?.object(forKey: "OPENWEATHERMAP_KEY") as? String else {
                fatalError("Couldn't find key 'OPENWEATHERMAP_KEY' in 'KeyList.plist'.")
            }
            return value
        }
    }
    
    // OpenWeatherMap의 API 요청시 5일치 3시간 단위 예보 날씨정보를 처리하는 메소드
    private func performRequestForecast(with url: URL?, completion: @escaping (Result<WeatherData, NetworkError>) -> Void) {
        guard let url = url else {
            return completion(.failure(.badUrl))
        }
        
        URLSession.shared.dataTask(with: url) { data, Response, error in
            // 응답과 에러,데이터 출력 : 정상출력됨
//            print("ForecastData: \(String(describing: data))")
//            print("ForecastResponse: \(String(describing: Response))")
//            print("ForecastError: \(String(describing: error))")
            
            guard let data = data, error == nil else {
                return completion(.failure(.noData))
            }
            
            do {
                let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
                completion(.success(weatherData))
            } catch {
                print("Forecast Decoding error: \(error)")
                completion(.failure(.decodingError))
            }
        }.resume()
    }
}

