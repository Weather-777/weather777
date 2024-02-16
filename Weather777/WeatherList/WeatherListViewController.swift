//
//  WeatherListViewController.swift
//  Weather777
//
//  Created by Jason Yang on 2/5/24.
//

import UIKit
import MapKit
import CoreLocation
import SwiftUI


struct WeatherInfo
{
    var cityName: String
    var time: String
    var weatherDescription: String
    var temperature: Double
    var tempMax: Double
    var tempMin: Double
}

class WeatherListViewController: UIViewController
{
    let cityListManager = CityListManager.shared
    
    var temperatureUnits: String = "C"
    var checkdCelsiusAction: UIMenuElement.State = .on
    var checkedFahrenheitAction: UIMenuElement.State = .off
    
    lazy var locationData: [CLLocationCoordinate2D] = []
    var weatherDataList: [WeatherInfo] = []
    
// MARK: - UI 구성
    let weatherLabel: UILabel =
    {
        let label = UILabel()
        label.text = "날씨"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 32)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    lazy var settingButton: UIButton =
    {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .medium)
        button.setImage(UIImage(systemName: "ellipsis.circle", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.setTitleColor(.clear, for: .normal)
        
        let edit = UIAction(title: "목록 편집", image: UIImage(systemName: "pencil"), state: .off, handler: { _ in print("목록 편집") })
        let C = UIAction(title: "섭씨", image: UIImage(named: "°C"), state: checkdCelsiusAction, handler: { _ in
            self.temperatureUnits = "C"
            self.checkdCelsiusAction = .on
            self.checkedFahrenheitAction = .off
            self.updateMenu()
        })
        let F = UIAction(title: "화씨", image: UIImage(named: "°F"), state: checkedFahrenheitAction, handler: { _ in
            self.temperatureUnits = "F"
            self.checkdCelsiusAction = .off
            self.checkedFahrenheitAction = .on
            self.updateMenu()
        })
        
        let line = UIMenu(title: "", options: .displayInline, children: [C, F])
        let menu = UIMenu(title: "", children: [edit, line])
        
        button.menu = menu
        
        button.showsMenuAsPrimaryAction = true
        button.changesSelectionAsPrimaryAction = false
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()

    lazy var locationSearchBar: UISearchBar =
    {
        let searchBar = UISearchBar()
        
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "도시 또는 공항 검색", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightText])
        searchBar.barTintColor = UIColor.clear
        searchBar.searchTextField.textColor = .white
        
        searchBar.autocorrectionType = .no
        searchBar.spellCheckingType = .no
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "취소"
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        return searchBar
    }()
    
    let weatherListTableView: UITableView =
    {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
// MARK: - Life Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        
        locationSearchBar.delegate = self
        
        weatherListTableView.dataSource = self
        weatherListTableView.delegate = self
        
        let weatherListnib = UINib(nibName: "WeatherListTableViewCell", bundle: nil)
        weatherListTableView.register(weatherListnib, forCellReuseIdentifier: "WeatherListTableViewCell")
        weatherListTableView.separatorStyle = .singleLine
        
        registerObserver()
        addSubView()
        setLayout()
        
    }
    
    override func viewWillAppear(_ animated: Bool) 
    {
        
        showList()
    }
    
// MARK: - 레이아웃 지정
        func addSubView()
        {
            view.addSubview(weatherLabel)
            view.addSubview(settingButton)
            view.addSubview(locationSearchBar)
            view.addSubview(weatherListTableView)
        }
        
        func setLayout()
        {
            NSLayoutConstraint.activate([
                weatherLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                weatherLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            
                settingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
                settingButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
                settingButton.widthAnchor.constraint(equalToConstant: 30),
                settingButton.heightAnchor.constraint(equalToConstant: 30),
            
                locationSearchBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                locationSearchBar.topAnchor.constraint(equalTo: weatherLabel.bottomAnchor, constant: 20),
                locationSearchBar.widthAnchor.constraint(equalToConstant: 384),
                locationSearchBar.heightAnchor.constraint(equalToConstant: 30),
            
                weatherListTableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                weatherListTableView.topAnchor.constraint(equalTo: locationSearchBar.bottomAnchor, constant: 15),
                weatherListTableView.widthAnchor.constraint(equalToConstant: 370),
                weatherListTableView.heightAnchor.constraint(equalToConstant: 600)
            ])
        }
    
// MARK: - Notification
    func registerObserver()
    {
       NotificationCenter.default.addObserver(
         self,
         selector: #selector(appendLocationData),
         name: NSNotification.Name("sendLocationData"),
         object: nil
       )
        
        NotificationCenter.default.addObserver(
          self,
          selector: #selector(dismissView),
          name: NSNotification.Name("dismissView"),
          object: nil
        )
     }
    
    @objc func appendLocationData(notification: NSNotification) 
    {
        if let sendWeatherData = notification.object as? [WeatherInfo]
        {
            for data in sendWeatherData
            {
                let weatherInfo = WeatherInfo(cityName: data.cityName, time: data.time, weatherDescription: data.weatherDescription, temperature: data.temperature, tempMax: data.tempMax, tempMin: data.tempMin)
                weatherDataList.append(weatherInfo)
            }
            UIView.animate(withDuration: 0.5)
            {
                self.view.frame.origin.y = 0
                self.locationSearchBar.isHidden = false
                self.weatherLabel.isHidden = false
                self.settingButton.isHidden = false
            }
            
        }
        else
        {
            print("Received object is not of type WeatherInfo")
        }
        weatherListTableView.reloadData()
    }
    
    @objc func dismissView(notification: NSNotification)
    {
        UIView.animate(withDuration: 0.5)
        {
            self.view.frame.origin.y = 0
            self.locationSearchBar.isHidden = false
            self.weatherLabel.isHidden = false
            self.settingButton.isHidden = false
        }
    }
    
// MARK: - 저장된 위경도 값을 이용해 테이블 뷰에 표현할 데이터 append
        func updateWetherInfo(latitude: Double, longitude: Double) {
            let latitude = latitude
            let longitude = longitude
            
            print("날씨 정보 함수")
            
            WeatherManager.shared.getForecastWeather(latitude: latitude, longitude: longitude) { [weak self] result in
                switch result {
                case .success(let data):
                    DispatchQueue.main.async { // 비동기 작업을 메인 스레드에서 처리하도록 함
                        let now = Date()
                        var selectedData = [(cityname: String, time: String, weatherIcon: String, weatherdescription: String, temperature: Double, wind: String, humidity: Int, tempMin: Double, tempMax: Double, feelsLike: Double, rainfall: Double)]()
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        
                        var closestPastIndex = -1
                        for (index, forecast) in data.enumerated() {
                            if let date = dateFormatter.date(from: forecast.time), date <= now {
                                closestPastIndex = index
                            } else {
                                break
                            }
                        }
                        
                        if closestPastIndex != -1 {
                            let startIndex = closestPastIndex
                            let endIndex = min(startIndex + 8, data.count)
                            selectedData = Array(data[startIndex..<endIndex])
                        }
                        
                        if let firstSelectData = selectedData.first {
                            let cityName = NSLocalizedString(firstSelectData.cityname, comment: "")
                            var cutTime = ""
                            let calendar = Calendar.current
                            if let date = dateFormatter.date(from: dateFormatter.string(from: now))
                            {
                                let hour = calendar.component(.hour, from: date)
                                let minute = calendar.component(.minute, from: date)
                                
                                // 시간과 분이 한 자리 숫자인 경우 앞에 0을 붙임
                                let formattedHour = hour < 10 ? "0\(hour)" : "\(hour)"
                                let formattedMinute = minute < 10 ? "0\(minute)" : "\(minute)"
                                
                                cutTime = "\(formattedHour) : \(formattedMinute)"
                            }
                            let weatherDescription = firstSelectData.weatherdescription
                            let temperature = firstSelectData.temperature
                            let tempMax = firstSelectData.tempMax
                            let tempMin = firstSelectData.tempMin
                                
                            let weatherInfo = WeatherInfo(cityName: cityName, time: cutTime, weatherDescription: weatherDescription, temperature: temperature, tempMax: tempMax, tempMin: tempMin)
                            
                            // 여기에 weatherDataList에 추가하는 코드를 추가
                            self?.weatherDataList.append(weatherInfo)
                            
                            // 추가한 데이터를 화면에 업데이트
                            self?.weatherListTableView.reloadData()
                        }
                    }
                    
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }

        func showList()
        {
            // CityListManager의 readAll() 메서드를 사용하여 저장된 데이터를 불러옵니다.
            let manager = CityListManager.shared
            let storedData = manager.readAll()

            for coord in storedData
            {
                print("UserDefaults \(coord.lat), \(coord.lon)")
                weatherDataList.removeAll()
                updateWetherInfo(latitude: coord.lat, longitude: coord.lon)
            }
            weatherListTableView.reloadData()
        }
    
// MARK: - settingButton의 UIMenu와 변경된 온도 단위를 tableView에 적용
    func updateMenu()
    {
        if temperatureUnits == "C"
        {
            checkdCelsiusAction = .on
            checkedFahrenheitAction = .off
        }
        
        else
        {
            checkdCelsiusAction = .off
            checkedFahrenheitAction = .on
        }
        
        let edit = UIAction(title: "목록 편집", image: UIImage(systemName: "pencil"), state: .off, handler: { _ in print("목록 편집") })
        let C = UIAction(title: "섭씨", image: UIImage(named: "°C"), state: checkdCelsiusAction, handler: { _ in
            self.temperatureUnits = "C"
            self.updateMenu()
        })
        let F = UIAction(title: "화씨", image: UIImage(named: "°F"), state: checkedFahrenheitAction, handler: { _ in
            self.temperatureUnits = "F"
            self.updateMenu()
        })
        
        let line = UIMenu(title: "", options: .displayInline, children: [C, F])
        let menu = UIMenu(title: "", children: [edit, line])
        settingButton.menu = menu
    
        weatherListTableView.reloadData()
    }
}

// MARK: - SearchBar extension
extension WeatherListViewController: UISearchBarDelegate
{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        UIView.animate(withDuration: 0.2)
        {
            self.locationSearchBar.isHidden = true
            self.view.frame.origin.y = -80
            self.weatherLabel.isHidden = true
            self.settingButton.isHidden = true
        }
        
        let VC = SearchViewController()
        
        VC.modalPresentationStyle = .automatic
        VC.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        present(VC, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
}

// MARK: - TableView extension
extension WeatherListViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return weatherDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherListTableViewCell", for: indexPath) as! WeatherListTableViewCell
    
        cell.backgroundColor = .clear
        cell.backgroundImage.image = UIImage(named: "weatherListCellBackground")
        cell.locationLabel.text = indexPath.row == 0 ?  "나의 위치" : weatherDataList[indexPath.row].cityName
        cell.timeOrCityLabel.text = indexPath.row == 0 ? weatherDataList[indexPath.row].cityName : weatherDataList[indexPath.row].time
        cell.weatherLabel.text = weatherDataList[indexPath.row].weatherDescription
        
        let temperature = temperatureUnits == "C" ? round(weatherDataList[indexPath.row].temperature) : round((weatherDataList[indexPath.row].temperature * 1.8) + 32)
        cell.temperatureLabel.text = "\(Int(temperature))°"
                
        let highTemperature = temperatureUnits == "C" ? round(weatherDataList[indexPath.row].tempMax) : round((weatherDataList[indexPath.row].tempMax * 1.8) + 32)
        cell.highTemperatureLabel.text = "최고\(Int(highTemperature))°"
                
        let lowTemperature = temperatureUnits == "C" ? round(weatherDataList[indexPath.row].tempMin) : round(weatherDataList[indexPath.row].tempMin * 1.8) + 32
        cell.lowTemperatureLabel.text = "최저 \(Int(lowTemperature))°"

        print("\(indexPath.row) cell \n \(weatherDataList[indexPath.row])")
        print(locationData.count)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) 
    {
        if editingStyle == .delete
        {
            UserDefaults.standard.removeObject(forKey: "Coord")
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let VC = MainViewController()
        
        let manager = CityListManager.shared
        let locations = manager.readAll()

        VC.currentLatitude = locations[indexPath.row].lat
        VC.currentLongitude = locations[indexPath.row].lon
        
        VC.modalPresentationStyle = .fullScreen
        present(VC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 120
    }
}
