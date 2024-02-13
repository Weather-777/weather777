//
//  Double+Extensions.swift
//  Weather777
//
//  Created by Jason Yang on 2/13/24.
//

import Foundation

extension Double {
    
    func toFahrenheit() -> Double {
        // current temperature is always in Kelvin
        let temperature = Measurement<UnitTemperature>(value: self, unit: .kelvin)
        // convert to fahrenheit from Kelvin
        let convertedTemperature = temperature.converted(to: .fahrenheit)
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        
        if let formattedTemperature = formatter.string(from: NSNumber(value: convertedTemperature.value)) {
            return Double(formattedTemperature) ?? 0.0
        } else {
            return 0.0
        }
    }
    
    func toCelsius() -> Double {
        // current temperature is always in Kelvin
        let temperature = Measurement<UnitTemperature>(value: self, unit: .kelvin)
        // convert to fahrenheit from Kelvin
        let convertedTemperature = temperature.converted(to: .celsius)
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        
        if let formattedTemperature = formatter.string(from: NSNumber(value: convertedTemperature.value)) {
            return Double(formattedTemperature) ?? 0.0
        } else {
            return 0.0
        }
    }
    
}
