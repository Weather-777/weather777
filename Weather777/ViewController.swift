//
//  ViewController.swift
//  Weather777
//
//  Created by Jason Yang on 2/5/24.
//

import UIKit
import SwiftUI
import CoreLocation


class ViewController: UIViewController, UISearchBarDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - UI Properties
    
    let testLabel: UILabel = {
        let label = UILabel()
        label.text = "7팀 화이팅입니다.😃"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var weatherImage: UIImageView!
    var tempLabel: UILabel!
    var maxTempLabel: UILabel!
    var minTempLabel: UILabel!
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUI()
        setAddSubView()
        setLayout()

        let latitude = 37.4536
        let longitude = 126.7317
        
        var forecastData: [(time: String, weatherIcon: String, temperature: Double, wind: String, humidity: Int, tempMin: Double, tempMax: Double, feelsLike: Double, rainfall: Double)] = []

        WeatherManager.shared.getForecastWeather(latitude: latitude, longitude: longitude) { result in
            switch result {
            case .success(let data):
                forecastData = data
                
                // forecastData 배열에 데이터가 들어갔는지 확인

                for forecast in forecastData {
                    print("Time: \(forecast.time)")
                    print("Weather Icon: \(forecast.weatherIcon)")
                    print("Temperature: \(forecast.temperature)°C")
                    print("Wind Speed: \(forecast.wind)")
                    print("humidity: \(forecast.humidity)%")
                    print("tempMin: \(forecast.tempMin)")
                    print("tempMax: \(forecast.tempMax)")
                    print("feelsLike: \(forecast.feelsLike)")
                    print("rainfall: \(forecast.rainfall)ml")
                    print("----------")
                }
                
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
}

extension ViewController {
    func setUI() {
        // 배경색 지정
        view.backgroundColor = .white
        
        tempLabel = UILabel()
        tempLabel.translatesAutoresizingMaskIntoConstraints = false
        
        weatherImage = UIImageView()
        weatherImage.translatesAutoresizingMaskIntoConstraints = false
        
        
        maxTempLabel = UILabel()
        maxTempLabel.translatesAutoresizingMaskIntoConstraints = false
        
        minTempLabel = UILabel()
        minTempLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
    }
    
    func setAddSubView() {

        view.addSubview(testLabel)
        view.addSubview(weatherImage)
        view.addSubview(tempLabel)
        view.addSubview(maxTempLabel)
        view.addSubview(minTempLabel)
    }
    
    func setLayout() {
        NSLayoutConstraint.activate([
            
            testLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            testLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // weatherImage의 제약 조건 설정
            weatherImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            weatherImage.topAnchor.constraint(equalTo: testLabel.bottomAnchor, constant: 100),
            weatherImage.widthAnchor.constraint(equalToConstant: 100),
            weatherImage.heightAnchor.constraint(equalToConstant: 100),
            
            // tempLabel의 제약 조건 설정
            tempLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tempLabel.topAnchor.constraint(equalTo: weatherImage.bottomAnchor, constant: 20),
            
            // maxTempLabel의 제약 조건 설정
            maxTempLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            maxTempLabel.topAnchor.constraint(equalTo: tempLabel.bottomAnchor, constant: 20),
            
            // minTempLabel의 제약 조건 설정
            minTempLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            minTempLabel.topAnchor.constraint(equalTo: maxTempLabel.bottomAnchor, constant: 20)
        ])
    }

} // extension
