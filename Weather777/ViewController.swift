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
    
    var weather: Weather?
    var main: MainClass?
    
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
        
        
        // 3시간 뒤의 최고 온도와 최저 온도 업데이트
//        updateForecastWeather()
        // 위치정보를 가져오는 시간이 걸리더라도 날씨정보를 우선 업데이트해서 UI를 변경하여 viewDidLoad()에서 즉시 반환
//        LocationManager.shared.requestLocation()
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
    
//    private func updateForecastWeather() {
//        // 위치정보 설정
//        let latitude = 37.4536
//        let longitude = 126.7317
//        LocationManager.shared.setLocation(latitude: latitude, longitude: longitude)
//        // 날씨 정보 가져오기
//        WeatherManager.shared.getForecastWeather(latitude: latitude, longitude: longitude) { result in
//            switch result {
//            case .success(let weatherData):
//                // 성공적으로 데이터를 가져왔을 때의 처리
//                if let list = weatherData.list.first {
//                    let maxTemp = list.main.tempMax
//                    let minTemp = list.main.tempMin
//                    let weatherIconString = list.weather.first?.icon ?? ""
//                    
//                    // 아이콘 이미지 다운로드
//                    let urlString = "https://openweathermap.org/img/wn/\(weatherIconString)@2x.png"
//                    guard let url = URL(string: urlString) else {
//                        return
//                    }
//                    
//                    let session = URLSession.shared
//                    let task = session.dataTask(with: url) { (data, response, error) in
//                        guard let data = data, error == nil else {
//                            return
//                        }
//                        
//                        DispatchQueue.main.async {
//                            self.weatherImage.image = UIImage(data: data)
//                            self.tempLabel.text = "현재 온도: \(String(describing: list.main.temp))"
//                            self.maxTempLabel.text = "최고 온도: \(maxTemp)"
//                            self.minTempLabel.text = "최저 온도: \(minTemp)"
//                        }
//                    }
//                    task.resume()
//                }
//            case .failure(let error):
//                // 에러 발생 시 처리
//                print(error)
//            }
//        }
//    }
    

    
} // extension

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


// MARK: - Preview
struct PreView: PreviewProvider {
    static var previews: some View {
        ViewController().toPreview()
    }
}

#if DEBUG
extension UIViewController {
    private struct Preview: UIViewControllerRepresentable {
        let viewController: UIViewController
        
        func makeUIViewController(context: Context) -> UIViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        }
    }
    
    func toPreview() -> some View {
        Preview(viewController: self)
    }
}
#endif

