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

//// MARK: - PreView
//struct PreView: PreviewProvider
//{
//    static var previews: some View
//    {
//        WeatherListViewController().toPreview()
//    }
//}
//
//
//#if DEBUG
//extension UIViewController {
//    private struct Preview: UIViewControllerRepresentable
//    {
//        let viewController: UIViewController
//
//        func makeUIViewController(context: Context) -> UIViewController
//        {
//            return viewController
//        }
//
//        func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }
//    }
//
//    func toPreview() -> some View
//    {
//        Preview(viewController: self)
//    }
//}
//#endif

struct WeatherInfo
{
    var cityName: String
    var time: String
    var weatherDescription: String
    var temperature: Double
    var tempMax: Double
    var tempMin: Double
}


class WeatherListViewController: UIViewController, CLLocationManagerDelegate
{
    let locationManager = CLLocationManager()
    
    lazy var printButton: UIButton =
    {
        let button = UIButton()
        button.setTitle("출력", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(printcity), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    @objc func printcity()
    {
        print(weatherDataList[index].cityName)
        print(weatherDataList[index].time)
        print(weatherDataList[index].weatherDescription)
        print(weatherDataList[index].temperature)
        print(weatherDataList[index].tempMax)
        print(weatherDataList[index].tempMin)
    }
    
    var temperatureUnits: String = "C"
    var checkdCelsiusAction: UIMenuElement.State = .on
    var checkedFahrenheitAction: UIMenuElement.State = .off
    
    lazy var locationData: [CLLocationCoordinate2D] = []
    var weatherDataList: [WeatherInfo] = [WeatherInfo(cityName: "", time: "", weatherDescription: "", temperature: 0, tempMax: 0, tempMin: 0)]
    var index: Int = 0
    
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

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() // 위치 권한 요청
        locationManager.startUpdatingLocation() // 위치 업데이트 시작
        
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
    
// MARK: - 레이아웃 지정
        func addSubView()
        {
            view.addSubview(weatherLabel)
            view.addSubview(settingButton)
            view.addSubview(locationSearchBar)
            view.addSubview(weatherListTableView)
            view.addSubview(printButton)
        }
        
        func setLayout()
        {
            NSLayoutConstraint.activate([
                printButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
                printButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
                printButton.widthAnchor.constraint(equalToConstant: 40),
                printButton.heightAnchor.constraint(equalToConstant: 30),
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
    
// MARK: - 현재 위치
    // 위치 권한 상태 변경 시 호출됨
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        if status == .authorizedWhenInUse
        {
            locationManager.startUpdatingLocation() // 위치 업데이트 시작
        }
    }

       // 위치 업데이트 시 호출됨
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if let location = locations.first
        {
            locationData.append(CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
//            updateWetherInfo(latitude: locationData[0].latitude, longitude: locationData[0].longitude)
            weatherListTableView.reloadData()

            print(weatherDataList[0].cityName)
            print(weatherDataList[0].time)
            print(weatherDataList[0].weatherDescription)
            print(weatherDataList[0].temperature)
            print(weatherDataList[0].tempMax)
            print(weatherDataList[0].tempMin)
            print("현재 위치: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        }
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
          selector: #selector(appendWeatherData),
          name: NSNotification.Name("sendWeatherData"),
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
        locationData.append(notification.object as! CLLocationCoordinate2D)
        UIView.animate(withDuration: 0)
        {
            self.view.frame.origin.y = 0
        }
        self.locationSearchBar.isHidden = false
      }
    
    @objc func appendWeatherData(notification: NSNotification)
    {
//        weatherDataList.append((notification.object as? [SendData]))
            if let receivedData = notification.object as? [SendData] 
            {
                for data in receivedData
                {
                    let weatherInfo = WeatherInfo(cityName: data.cityName, time: data.time, weatherDescription: data.weatherDescription, temperature: data.temperature, tempMax: data.tempMax, tempMin: data.tempMin)
                    weatherDataList.append(weatherInfo)
                }
            }
//        updateWetherInfo(latitude: locationData[index].latitude, longitude: locationData[index].longitude)
        weatherListTableView.reloadData()
        index += 1
    }
    
    @objc func dismissView(notification: NSNotification)
    {
        UIView.animate(withDuration: 0)
        {
            self.view.frame.origin.y = 0
            self.locationSearchBar.isHidden = false
        }
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
            self.view.frame.origin.y = -130
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
        return locationData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherListTableViewCell", for: indexPath) as! WeatherListTableViewCell
    
        cell.backgroundColor = .clear
        cell.backgroundImage.image = UIImage(named: "weatherListCellBackground")
        cell.locationLabel.text = indexPath.row == 0 ?  "나의 위치" : weatherDataList[indexPath.row].cityName
        cell.timeOrCityLabel.text = indexPath.row == 0 ? weatherDataList[indexPath.row].cityName : weatherDataList[indexPath.row].time
        cell.weatherLabel.text = weatherDataList[indexPath.row].weatherDescription
        
        let temperature = temperatureUnits == "C" ? weatherDataList[indexPath.row].temperature : (weatherDataList[indexPath.row].temperature * 1.8) + 32
        cell.temperatureLabel.text = "\(temperature)°\(temperatureUnits)"
                
        let highTemperature = temperatureUnits == "C" ? weatherDataList[indexPath.row].tempMax : (weatherDataList[indexPath.row].tempMax * 1.8) + 32
        cell.highTemperatureLabel.text = "최고\(highTemperature)°\(temperatureUnits)"
                
        let lowTemperature = temperatureUnits == "C" ? weatherDataList[indexPath.row].tempMin : (weatherDataList[indexPath.row].tempMin * 1.8) + 32
        cell.lowTemperatureLabel.text = "최저 \(lowTemperature)°\(temperatureUnits)"

        // weatherDataList 어떤 값이 있고 몇개가 있는지
        // 현재indexPath.row 불리고 있는 값이 몇인지
        
        print("\(indexPath.row) cell \(weatherDataList[indexPath.row])")
        print(locationData.count)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let VC = MainViewController()
//        VC.**** = locationData[indexPath.row] // 위도 경도 변수 지정
        VC.modalPresentationStyle = .fullScreen
        present(VC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 120
    }
}
