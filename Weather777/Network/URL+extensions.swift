//
//  URL+Extension.swift
//  Weather777
//
//  Created by Jason Yang on 2/13/24.
//

import Foundation
import CoreLocation


extension URL {
    
    //위, 경도 API call
    //https://openweathermap.org/current
    static func urlForWeatherForLocation(_ currentLocation: CLLocationCoordinate2D, apiKey: String) -> URL? {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(currentLocation.latitude)&lon=\(currentLocation.longitude)&appid=\(apiKey)") else {
            return nil
        }
        return url
    }
    
    //도시 기준 API call
    //https://openweathermap.org/current
    static func urlForWeatherFor(_ city: String, apiKey: String) -> URL? {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)") else {
            return nil
        }
        return url
    }
    
    //5일치 3시간 단위 날씨 예보 API call
    //https://openweathermap.org/forecast5
//api.openweathermap.org/data/2.5/forecast?lat=37.565534&lon=126.977895&appid=3a33f61058f414d02d09e88bfa83117c&lang=kr
    static func urlForForecastForLocation(_ currentLocation: CLLocationCoordinate2D, apiKey: String) -> URL? {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/forecast?lat=\(currentLocation.latitude)&lon=\(currentLocation.longitude)&appid=\(apiKey)&lang=kr") else {
            return nil
        }
        return url
    }
    
//    //Air Pollution API
//    //https://openweathermap.org/api/air-pollution
//    static func urlForAirPollutionForLocation(_ currentLocation: CLLocationCoordinate2D, apiKey: String) -> URL? {
//        guard let url = URL(string: "http://api.openweathermap.org/data/2.5/air_pollution?lat=\(currentLocation.latitude)&lon=\(currentLocation.longitude)&appid=\(apiKey)") else {
//            return nil
//        }
//        return url
//    }
//
//    //Geocoding API
//    //https://openweathermap.org/api/geocoding-api
//    static func urlForGeoDirect(_ city: String, stateCode: String, countryCode: String, limit: Int, apiKey: String) -> URL? {
//        guard let url = URL(string: "http://api.openweathermap.org/geo/1.0/direct?q=\(city),\(stateCode),\(countryCode)&limit=\(limit)&appid=\(apiKey)") else {
//            return nil
//        }
//        return url
//    }
//
//    //Weather Maps 1.0
//    //https://openweathermap.org/api/weathermaps
//    static func urlForMapLayer(_ layer: String, z: Int, x: Int, y: Int, apiKey: String) -> URL? {
//        guard let url = URL(string: "https://tile.openweathermap.org/map/\(layer)/\(z)/\(x)/\(y).png?appid=\(apiKey)") else {
//            return nil
//        }
//        return url
//    }
    
}



