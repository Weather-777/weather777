//
//  MainViewController.swift
//  Weather777
//
//  Created by Jason Yang on 2/5/24.
//

import UIKit
import SwiftUI
import Then
import Gifu
import CoreLocation

class MainViewController: UIViewController {
    
    var gifImageView: GIFImageView?
    let scrollView = UIScrollView().then {
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
    }
    let viewOverGif = UIView().then {
        $0.backgroundColor = .white.withAlphaComponent(0)
    }
    let currentCityNameLabel = UILabel().then {
        $0.font = UIFont(name: "Roboto-Medium", size: 35)
        $0.textColor = .white
    }
    let currentWeatherIcon = UIImageView().then {
        $0.contentMode = .scaleToFill
    }
    let currentWeatherConditionLabel = UILabel().then {
        $0.font = UIFont(name: "Roboto-Bold", size: 40)
        $0.textColor = .white
    }
    let currentWeatherTemperatureLabel = UILabel().then {
        $0.font = UIFont(name: "Roboto-Bold", size: 60)
        $0.textColor = .white
    }
    let celsiusLabel = UILabel().then {
        $0.font = UIFont(name: "Roboto-Bold", size: 20)
        $0.text = "ºC"
        $0.textColor = .white
    }
    let fahrenheitLabel = UILabel().then {
        $0.font = UIFont(name: "Roboto-Bold", size: 20)
        $0.text = "ºF"
    }
    let humidityVStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.spacing = 4
    }
    let humidityImageView = UIImageView().then {
        $0.image = UIImage(named: "Humidity")
    }
    let humidityLabel = UILabel().then {
        $0.font = UIFont(name: "Roboto-Regular", size: 14)
        $0.text = "습기"
        $0.textColor = .white
    }
    let humidityPercentageLabel = UILabel().then {
        $0.font = UIFont(name: "Roboto-Regular", size: 14)
        $0.textColor = .white
    }
    let windVStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.spacing = 4
    }
    let windImageView = UIImageView().then {
        $0.image = UIImage(named: "Wind")
    }
    let windLabel = UILabel().then {
        $0.font = UIFont(name: "Roboto-Regular", size: 14)
        $0.text = "바람"
        $0.textColor = .white
    }
    let windSpeedLabel = UILabel().then {
        $0.font = UIFont(name: "Roboto-Regular", size: 14)
        $0.textColor = .white
    }
    let feelLikeTemperatureVStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.spacing = 4
    }
    let feelLikeTemperatureImageView = UIImageView().then {
        $0.image = UIImage(named: "FeelLike")
    }
    let feelLikeTemperatureLabel = UILabel().then {
        $0.font = UIFont(name: "Roboto-Regular", size: 14)
        $0.text = "체감 온도"
        $0.textColor = .white
    }
    let feelLikeTemperatureIndexLabel = UILabel().then {
        $0.font = UIFont(name: "Roboto-Regular", size: 14)
        $0.textColor = .white
    }
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout()).then {
        $0.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 0.3)
        $0.register(WeatherCollectionViewCell.self, forCellWithReuseIdentifier: "WeatherCollectionViewCell")
        $0.dataSource = self
        $0.layer.cornerRadius = 16
    }
    let bottomViewSeparatorLine = UIView().then {
        $0.backgroundColor = .white
        $0.alpha = 0.5
    }
    let bottomView = UIView().then {
        $0.backgroundColor = .clear
    }
    let mapButton = UIButton().then {
        $0.setImage(UIImage(named: "Map"), for: .normal)
    }
    let weatherListButton = UIButton().then {
        $0.setImage(UIImage(named: "WeatherList"), for: .normal)
    }
    var forecastData: [(cityname:String, time: String, weatherIcon: String, weatherdescription: String, temperature: Double, wind: String, humidity: Int, tempMin: Double, tempMax: Double, feelsLike: Double, rainfall: Double)] = []
    
    var currentLatitude: Double = 0
    var currentLongitude: Double = 0
    var tempMin: Double = 0
    var tempMax: Double = 0
    
    // LocationManager 인스턴스에 접근
    private let locationManager = LocationManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateBackgroundGIF(with: "CleanSky")
        setUpViewHierarchy()
        setUpLayout()
        fahrenheitLabel.isHidden = true
        mapButton.addTarget(self, action: #selector(mapButtonTapped), for: .touchUpInside)
        weatherListButton.addTarget(self, action: #selector(weatherListButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 사용자에게 위치 권한 요청
        requestLocationAccess()
        
        // 위치 정보 업데이트 시 처리
        LocationManager.shared.onLocationUpdate = { [weak self] location in
            // 위경도 값 사용하여 UI 업데이트
            print("Updated location: \(location.latitude), \(location.longitude)")
            self?.currentLatitude = location.latitude
            self?.currentLongitude = location.longitude
            self?.updateForecastData(latitude: self?.currentLatitude ?? 0, longitude: self?.currentLongitude ?? 0)
        }
        
        // 앱 최초 실행에서 위치 권한 거부시 위치 설정으로 유도
        LocationManager.shared.onAuthorizationStatusChanged = { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .denied, .restricted:
                    // 권한 거부 상태에 따른 UI 표시
                    let alert = UIAlertController(title: "위치 서비스 권한 필요", message: "앱의 전체 기능을 사용하려면 위치 서비스 권한이 필요합니다. 설정에서 권한을 허용해주세요.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default, handler: { _ in
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsURL)
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "취소", style: .cancel))
                    self?.present(alert, animated: true)
                default:
                    break
                }
            }
        }
    }
    
    private func requestLocationAccess() {
        // 권한 상태에 따라 직접 처리하지 않고, LocationManager의 기능을 활용
        locationManager.requestLocation()
    }
    
    private func showAlertForLocationServiceDisabled() {
        let alert = UIAlertController(title: "위치 서비스 비활성화", message: "위치 서비스가 비활성화되어 있습니다. 설정에서 위치 서비스를 활성화해주세요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    private func setUpViewHierarchy() {
        view.addSubview(scrollView)
        view.addSubview(bottomView)
        view.addSubview(bottomViewSeparatorLine)
        bottomView.addSubview(mapButton)
        bottomView.addSubview(weatherListButton)
        scrollView.addSubview(viewOverGif)
        humidityVStackView.addArrangedSubviews(humidityImageView, humidityLabel, humidityPercentageLabel)
        windVStackView.addArrangedSubviews(windImageView, windLabel, windSpeedLabel)
        feelLikeTemperatureVStackView.addArrangedSubviews(feelLikeTemperatureImageView, feelLikeTemperatureLabel, feelLikeTemperatureIndexLabel)
        viewOverGif.addSubview(humidityVStackView)
        viewOverGif.addSubview(windVStackView)
        viewOverGif.addSubview(feelLikeTemperatureVStackView)
        viewOverGif.addSubview(currentWeatherTemperatureLabel)
        viewOverGif.addSubview(celsiusLabel)
        viewOverGif.addSubview(fahrenheitLabel)
        viewOverGif.addSubview(currentWeatherConditionLabel)
        viewOverGif.addSubview(currentWeatherIcon)
        viewOverGif.addSubview(currentCityNameLabel)
        viewOverGif.addSubview(collectionView)
    }
    
    private func setUpLayout() {
        scrollView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomViewSeparatorLine.snp.top)
        }
        viewOverGif.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }
        bottomViewSeparatorLine.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(45)
        }
        bottomView.snp.makeConstraints {
            $0.top.equalTo(bottomViewSeparatorLine.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        mapButton.snp.makeConstraints {
            $0.width.equalTo(25)
            $0.height.equalTo(23)
            $0.top.equalToSuperview().inset(10)
            $0.leading.equalToSuperview().inset(24)
        }
        weatherListButton.snp.makeConstraints {
            $0.width.equalTo(25)
            $0.height.equalTo(23)
            $0.top.equalToSuperview().inset(10)
            $0.trailing.equalToSuperview().inset(24)
        }
        windVStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(30)
        }
        humidityVStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(48)
            $0.centerY.equalToSuperview().offset(30)
        }
        feelLikeTemperatureVStackView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(40)
            $0.centerY.equalToSuperview().offset(30)
        }
        humidityImageView.snp.makeConstraints {
            $0.width.equalTo(30)
            $0.height.equalTo(35)
        }
        windImageView.snp.makeConstraints {
            $0.width.equalTo(30)
            $0.height.equalTo(35)
        }
        feelLikeTemperatureImageView.snp.makeConstraints {
            $0.width.equalTo(35)
            $0.height.equalTo(35)
        }
        currentWeatherTemperatureLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(windVStackView.snp.top).offset(-35)
        }
        celsiusLabel.snp.makeConstraints {
            $0.top.equalTo(currentWeatherTemperatureLabel.snp.top).offset(10)
            $0.leading.equalTo(currentWeatherTemperatureLabel.snp.trailing).offset(2)
        }
        fahrenheitLabel.snp.makeConstraints {
            $0.top.equalTo(currentWeatherTemperatureLabel.snp.top).offset(10)
            $0.leading.equalTo(currentWeatherTemperatureLabel.snp.trailing).offset(2)
        }
        currentWeatherConditionLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(currentWeatherTemperatureLabel.snp.top).offset(-16)
        }
        currentWeatherIcon.snp.makeConstraints {
            $0.width.equalTo(75)
            $0.height.equalTo(75)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(currentWeatherConditionLabel.snp.top)
        }
        currentCityNameLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(currentWeatherIcon.snp.top).offset(-20)
        }
        collectionView.snp.makeConstraints {
            $0.height.equalTo(200)
            $0.top.equalTo(windVStackView.snp.bottom).offset(35)
            $0.leading.trailing.equalToSuperview().inset(25)
            $0.bottom.equalTo(viewOverGif.snp.bottom).offset(-30)
        }
    }
    
    func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1.0))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            
            return section
        }
    }
    
    func updateBackgroundGIF(with gifName: String) {
        gifImageView?.removeFromSuperview()
        gifImageView = GIFImageView().then {
            $0.contentMode = .scaleAspectFill
            $0.animate(withGIFNamed: gifName)
            $0.alpha = 0.5 // 백그라운드 GIF의 알파값 조정
        }
        if let gifImageView = gifImageView {
            view.insertSubview(gifImageView, at: 0) // gifImageView를 메인 뷰의 맨 아래에 추가
            gifImageView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
    }
    
    func updateForecastData(latitude: Double, longitude: Double) {

        WeatherManager.shared.getForecastWeather(latitude: latitude, longitude: longitude) { [weak self] result in
            switch result {
            case .success(let data):
                // 현재 시각
                let now = Date()
                var selectedData = [(cityname: String, time: String, weatherIcon: String, weatherdescription: String, temperature: Double, wind: String, humidity: Int, tempMin: Double, tempMax: Double, feelsLike: Double, rainfall: Double)]()

                // DateFormatter 설정
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

                // 가장 가까운 과거 시간 찾기
                var closestPastIndex = -1
                for (index, forecast) in data.enumerated() {
                    if let date = dateFormatter.date(from: forecast.time), date <= now {
                        closestPastIndex = index
                    } else {
                        break // 이미 과거 시간 중 가장 가까운 시간을 찾았으므로 반복 중단
                    }
                }

                // 가장 가까운 과거 시간부터 8개 데이터 선택
                if closestPastIndex != -1 {
                    let startIndex = closestPastIndex
                    let endIndex = min(startIndex + 8, data.count)
                    selectedData = Array(data[startIndex..<endIndex])
                }

                self?.forecastData = selectedData

                // 데이터 로딩 후 UI 업데이트
                DispatchQueue.main.async {
                    let cityNameInKorean = NSLocalizedString(self?.forecastData[0].cityname ?? "", comment: "")
                    self?.currentCityNameLabel.text = cityNameInKorean
                    let iconUrlString = "https://openweathermap.org/img/wn/\(self?.forecastData[0].weatherIcon ?? "")@2x.png" // 아이콘 URL 스트링
                    self?.downloadWeatherIconImage(from: iconUrlString) { image in
                        self?.currentWeatherIcon.image = image
                    }
                    self?.currentWeatherTemperatureLabel.text = String(self?.forecastData[0].temperature ?? 0)
                    self?.currentWeatherConditionLabel.text = self?.forecastData[0].weatherdescription ?? ""
                    self?.humidityPercentageLabel.text = "\(self?.forecastData[0].humidity ?? 0)%"
                    self?.windSpeedLabel.text = self?.forecastData[0].wind ?? ""
                    self?.feelLikeTemperatureIndexLabel.text = String(self?.forecastData[0].feelsLike ?? 0)
                    self?.tempMin = self?.forecastData[0].tempMin ?? 0
                    self?.tempMax = self?.forecastData[0].tempMax ?? 0
                    self?.collectionView.reloadData()
                }

                // 선택된 데이터 로그 출력
                for forecast in selectedData {
                    print("CityName: \(forecast.cityname)")
                    print("Time: \(forecast.time)")
                    print("Weather Icon: \(forecast.weatherIcon)")
                    print("Weather Description\(forecast.weatherdescription)")
                    print("Temperature: \(forecast.temperature)°C")
                    print("Wind Speed: \(forecast.wind)")
                    print("Humidity: \(forecast.humidity)%")
                    print("Temp Min: \(forecast.tempMin)")
                    print("Temp Max: \(forecast.tempMax)")
                    print("Feels Like: \(forecast.feelsLike)")
                    print("Rainfall: \(forecast.rainfall)ml")
                    print("----------")
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func downloadWeatherIconImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
    
    @objc func mapButtonTapped() {
        let mapVC = MapViewController()
        mapVC.modalPresentationStyle = .fullScreen
        present(mapVC, animated: true, completion: nil)
    }
    
    @objc func weatherListButtonTapped() {
        let weatherListVC = WeatherListViewController()
        weatherListVC.modalPresentationStyle = .fullScreen
        let cityNameInKorean = NSLocalizedString(self.forecastData[0].cityname, comment: "")
        let time = self.forecastData[0].time
        let weatherDescirption = self.forecastData[0].weatherdescription
        let temperature = self.forecastData[0].temperature
        let tempMax = self.tempMax
        let tempMin = self.tempMin
        
        weatherListVC.weatherDataList.append(WeatherInfo(cityName: cityNameInKorean, time: time, weatherDescription: weatherDescirption, temperature: temperature, tempMax: tempMax, tempMin: tempMin))
        present(weatherListVC, animated: true, completion: nil)
    }
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(forecastData.count, 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherCollectionViewCell", for: indexPath) as? WeatherCollectionViewCell else {
            fatalError("Unable to dequeue WeatherCollectionViewCell")
        }
        
        // forecastData에서 해당 indexPath에 맞는 데이터 가져오기
        let forecast = forecastData[indexPath.row]
        
        // 시간
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = dateFormatter.date(from: forecast.time) {
            dateFormatter.dateFormat = "HH"
            var timeString = dateFormatter.string(from: date)
            if timeString == "00" {
                timeString = "0"
            }
            cell.timeLabel.text = "\(timeString)시"
        }
        
        // 날씨 아이콘
        let iconUrlString = "https://openweathermap.org/img/wn/\(forecast.weatherIcon)@2x.png" // 아이콘 URL 스트링
        downloadWeatherIconImage(from: iconUrlString) { image in
            cell.weatherIconImageView.image = image
        }
        
        // 기온
        cell.temperatureLabel.text = "\(forecast.temperature)°C"
        
        // 풍속
        let windSpeedString = String(forecast.wind).dropLast(4) // "m/s" 제외하고 숫자만 추출
        cell.windSpeedLabel.text = "\(windSpeedString)"
        
        return cell
    }
}

extension UIStackView {
    func addArrangedSubviews(_ views: UIView...) {
        for view in views {
            self.addArrangedSubview(view)
        }
    }
}
