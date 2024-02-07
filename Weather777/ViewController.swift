//
//  ViewController.swift
//  Weather777
//
//  Created by Jason Yang on 2/5/24.
//

import UIKit
import SwiftUI


class ViewController: UIViewController {
    
    var weather: Weather?
    var main: Main?

    
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
       
        //LocationManager가 위치정보 업데이트 -> WeatherManager가 날씨정보 업데이트 -> 초기화한 weather, main DTO에서 날씨정보를 가져와 비동기로 UI를 업데이트
        LocationManager.shared.onLocationUpdate = { [weak self] location in
            WeatherManager.shared.getLocationWeather { result in
                switch result {
                case .success(let weatherResponse):
                    DispatchQueue.main.async {
                        self?.weather = weatherResponse.weather.first
                        self?.main = weatherResponse.main
                        self?.updateWeather()
                    }
                case .failure(_ ):
                    print("error")
                }
            }
        }
        
        // 위치정보를 가져오는 시간이 걸리더라도 날씨정보를 우선 업데이트해서 UI를 변경하여 viewDidLoad()에서 즉시 반환
        LocationManager.shared.requestLocation()
    }
    
}


extension ViewController {
    func setUI() {
        // 배경색 지정
        view.backgroundColor = .white
        
        weatherImage = UIImageView()
        weatherImage.translatesAutoresizingMaskIntoConstraints = false
        
        tempLabel = UILabel()
        tempLabel.translatesAutoresizingMaskIntoConstraints = false
        
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
    
    //WeatherData의 데이터를 활용하여 UI에 적용하기
    private func updateWeather() {
        guard let icon = self.weather?.icon else {
            return
        }
        
        let urlString = "https://openweathermap.org/img/wn/\(icon)@2x.png"
        guard let url = URL(string: urlString) else {
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                self.weatherImage.image = UIImage(data: data)
            }
        }
        task.resume()
        
        if let main = self.main {
            let tempCelsius = main.temp
            let tempMaxCelsius = main.tempMax
            let tempMinCelsius = main.tempMin
            
            DispatchQueue.main.async {
                if let celsiustempLabel = self.convertFahrenheitToCelsius(tempCelsius),
                   let celsiusmaxTempLabel = self.convertFahrenheitToCelsius(tempMaxCelsius),
                   let celsiusminTempLabel = self.convertFahrenheitToCelsius(tempMinCelsius) {
                    // Call to method 'convertFahrenheitToCelsius' in closure requires explicit use of 'self' to make capture semantics explicit
                    
                    self.tempLabel.text = "\(celsiustempLabel)"
                    self.maxTempLabel.text = "\(celsiusmaxTempLabel)"
                    self.minTempLabel.text = "\(celsiusminTempLabel)"
                }
            }
        }
    }
}

// 화씨를 섭씨로 전환하는 매소드
extension ViewController {
    func convertFahrenheitToCelsius(_ fahrenheit: Double) -> String? {
        let celsiusUnit = UnitTemperature.celsius
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        let celsius = celsiusUnit.converter.value(fromBaseUnitValue: fahrenheit)
        if let formattedCelsius = formatter.string(from: celsius as NSNumber) {
            return "\(formattedCelsius)°C"
        }
        return ""
    }
}
