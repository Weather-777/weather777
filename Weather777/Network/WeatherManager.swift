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
    // 싱글톤 정적상수 활용
    static let shared = WeatherManager()
    
    private init() {}
    
    // MARK: - public Methods
    // 서울지역 : URL(string: "https://api.openweathermap.org/data/2.5/weather?q=seoul&appid=\(apiKey)")
    public func getWeather(completion: @escaping(Result<WeatherData, NetworkError>) -> Void) {
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=seoul&appid=\(apiKey)")
        guard let url = url else {
            return completion(.failure(.badUrl))
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                return completion(.failure(.noData))
            }
            
            // Data 타입으로 받은 리턴을 디코드
            let weatherData = try? JSONDecoder().decode(WeatherData.self, from: data)
            
            // 성공 시 성공한 데이터 저장
            if let weatherData = weatherData {
                completion(.success(weatherData))
            } else {
                completion(.failure(.decodingError))
            }
        }.resume()  // dataTask 시작
        print("Success")
    }
    
    // 서울지역이 아닌 곳을 하려면 어떻게 해야할까?
    public func getLocationWeather(completion: @escaping(Result<WeatherData, NetworkError>) -> Void) {
        guard let currentLocation = LocationManager.shared.currentLocation else {
            return completion(.failure(.badLocation))
        }
        
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(currentLocation.latitude)&lon=\(currentLocation.longitude)&appid=\(apiKey)")
        guard let url = url else {
            return completion(.failure(.badUrl))
        }
        performRequest(with: url, completion: completion)
    }
    
    
    // 위경도 기준 OpenWeatherMap의 API 요청시 날씨정보를 처리하는 메소드
    private func performRequest(with url: URL?, completion: @escaping (Result<WeatherData, NetworkError>) -> Void) {
        guard let url = url else {
            return completion(.failure(.badUrl))
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
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
    
    
    
    
}

// MARK: - Extensions
extension WeatherManager {
    //plist를 통해 숨긴 API 호출을 위한 프로퍼티
    private var apiKey: String {
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
}
