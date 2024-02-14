//
//  WeatherDataProcessor.swift
//  Weather777
//
//  Created by Jason Yang on 2/14/24.
//

import Foundation

class WeatherDataProcessor {
    func process(weatherData: WeatherData) -> [(time: String, weatherIcon: String, temperature: Double, wind: String, humidity: Int, tempMin: Double, tempMax: Double, feelsLike: Double, rainfall: Double)] {
        // 날씨 데이터를 성공적으로 받아왔을 때
        var forecastData: [(time: String, weatherIcon: String, temperature: Double, wind: String, humidity: Int, tempMin: Double, tempMax: Double, feelsLike: Double, rainfall: Double)] = []
        
        for list in weatherData.list {
            let time = list.dtTxt
            let weatherIcon = list.weather.first?.icon ?? ""
            let temperature = Double(list.main.temp)
            let celsiusTemperature = temperature.toCelsius()
            let windSpeed = list.wind.speed
            let humidity = list.main.humidity
            let tempMin = Double(list.main.tempMin)
            let tempMax = Double(list.main.tempMax)
            let celsiustempMin = tempMin.toCelsius()
            let celsiustempMax = tempMax.toCelsius()
            let feelsLike = Double(list.main.feelsLike)
            let celsiusfeelsLike = feelsLike.toCelsius()
            let rainfall = list.rain?.the3H ?? 0.0
            
            let forecast = (time: time, weatherIcon: weatherIcon, temperature: celsiusTemperature, wind: "\(windSpeed) m/s", humidity: humidity, tempMin: celsiustempMin, tempMax: celsiustempMax, feelsLike: celsiusfeelsLike, rainfall: rainfall)
            forecastData.append(forecast)
        }
        
        return forecastData
    }
}
