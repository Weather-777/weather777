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
    //현재 날씨정보 : LocationManager에서 위치정보를 받고, 위경도 API에 적용한 후, 날씨 데이터 값 복사 : 독립적인 인스턴스 생성
    //https://api.openweathermap.org/data/2.5/weather?lat=37.565534&lon=126.977895&appid=3a33f61058f414d02d09e88bfa83117c
    public func getLocationWeather(latitude: Double, longitude: Double, completion: @escaping(Result<WeatherData, NetworkError>) -> Void) {
        LocationManager.shared.setLocation(latitude: latitude, longitude: longitude)
        guard let currentLocation = LocationManager.shared.currentLocation else {
            return completion(.failure(.badLocation))
        }
        
        guard let url = URL.urlForWeatherForLocation(currentLocation, apiKey: apiKey) else {
            return completion(.failure(.badUrl))
        }
        performRequest(with: url, completion: completion)
    }
    
    // OpenWeatherMap에서 지원하는 도시 검색 사이트 https://openweathermap.org/find?q
    // 현재 날씨정보의 도시 기준, url test(인천) : https://api.openweathermap.org/data/2.5/weather?q=incheon&appid=3a33f61058f414d02d09e88bfa83117c
    public func getCityWeather(city: String, completion: @escaping(Result<WeatherData, NetworkError>) -> Void) {
        let formattedCity = city.replacingOccurrences(of: " ", with: "+")
        guard let url = URL.urlForWeatherFor(formattedCity, apiKey: apiKey) else {
            return completion(.failure(.badUrl))
        }
        performRequest(with: url, completion: completion)
    }
    
    // https://openweathermap.org/forecast5 5일치 3시간 단위 일기예보
    //test API call : api.openweathermap.org/data/2.5/forecast?lat=37.4536&lon=126.7317&appid=3a33f61058f414d02d09e88bfa83117c
    public func getForecastWeather(latitude: Double, longitude: Double, completion: @escaping(Result<WeatherData, NetworkError>) -> Void) {
        LocationManager.shared.setLocation(latitude: latitude, longitude: longitude)
        guard let currentLocation = LocationManager.shared.currentLocation else {
            return completion(.failure(.badLocation))
        }
        
        guard let url = URL.urlForForecastForLocation(currentLocation, apiKey: apiKey) else {
            return completion(.failure(.badUrl))
        }
        performRequestForecast(with: url, completion: completion)
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
    
    // OpenWeatherMap의 API 요청시 현재 날씨정보를 처리하는 메소드
    private func performRequest(with url: URL?, completion: @escaping (Result<WeatherData, NetworkError>) -> Void) {
        guard let url = url else {
            return completion(.failure(.badUrl))
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            // 응답과 에러,데이터 출력 : 정상출력됨
            //            print("Data: \(String(describing: data))")
            //            print("Response: \(String(describing: response))")
            //            print("Error: \(String(describing: error))")
            
            
            guard let data = data, error == nil else {
                return completion(.failure(.noData))
            }
            let weatherData = try? JSONDecoder().decode(WeatherData.self, from: data)
            if let weatherData = weatherData {
                completion(.success(weatherData))
            } else {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    // OpenWeatherMap의 API 요청시 5일치 3시간 단위 예보 날씨정보를 처리하는 메소드
    private func performRequestForecast(with url: URL?, completion: @escaping (Result<WeatherData, NetworkError>) -> Void) {
        guard let url = url else {
            return completion(.failure(.badUrl))
        }
        
        URLSession.shared.dataTask(with: url) { data, Response, error in
            // 응답과 에러,데이터 출력 : 정상출력됨
            print("ForecastData: \(String(describing: data))")
            print("ForecastResponse: \(String(describing: Response))")
            print("ForecastError: \(String(describing: error))")
            
            
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

