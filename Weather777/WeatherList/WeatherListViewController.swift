//
//  WeatherListViewController.swift
//  Weather777
//
//  Created by Jason Yang on 2/5/24.
//

import UIKit
import MapKit
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


class WeatherListViewController: UIViewController
{
    var weatherInformation: [Any] = []
    
    var location = 0
    var time = "17:00"
    var weather = "맑음"
    var temperature = 7
    var highTemperature = 10
    var lowTemperature = 3
    
    var temperatureUnits: String = "C"
    var checkdCelsiusAction: UIMenuElement.State = .on
    var checkedFahrenheitAction: UIMenuElement.State = .off
    
    var data: [String] = []
    
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
            self.updateTemperature()
            self.updateMenu()
        })
        let F = UIAction(title: "화씨", image: UIImage(named: "°F"), state: checkedFahrenheitAction, handler: { _ in
            self.temperatureUnits = "F"
            self.checkdCelsiusAction = .off
            self.checkedFahrenheitAction = .on
            self.updateTemperature()
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
            
        addSubView()
        setLayout()
            
        locationSearchBar.delegate = self
        
        weatherListTableView.dataSource = self
        weatherListTableView.delegate = self
        
        let weatherListnib = UINib(nibName: "WeatherListTableViewCell", bundle: nil)
        weatherListTableView.register(weatherListnib, forCellReuseIdentifier: "WeatherListTableViewCell")

        weatherListTableView.separatorStyle = .singleLine
    }
    
// MARK: - 온도 단위 변환 함수
    func updateTemperature()
    {
        if temperatureUnits == "C"
        {
            self.temperature = Int(round(Double(self.temperature - 32)) / 1.8)
            self.highTemperature = Int(round(Double(self.highTemperature - 32)) / 1.8)
            self.lowTemperature = Int(round(Double(self.lowTemperature - 32)) / 1.8)
        }
        
        else
        {
            self.temperature = Int(round(Double(self.temperature) * 1.8) + 32)
            self.highTemperature = Int(round(Double(self.highTemperature) * 1.8) + 32)
            self.lowTemperature = Int(round(Double(self.lowTemperature) * 1.8) + 32)
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
            self.updateTemperature()
            self.updateMenu()
        })
        let F = UIAction(title: "화씨", image: UIImage(named: "°F"), state: checkedFahrenheitAction, handler: { _ in
            self.temperatureUnits = "F"
            self.updateTemperature()
            self.updateMenu()
        })
        let line = UIMenu(title: "", options: .displayInline, children: [C, F])
        
        let menu = UIMenu(title: "", children: [edit, line])
        
        
        settingButton.menu = menu
        
        weatherListTableView.reloadData()
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
        searchBar.setShowsCancelButton(true, animated: true)
        settingButton.isHidden = true
        weatherLabel.isHidden = true
        
        let VC = SearchViewController()
        VC.modalPresentationStyle = .overCurrentContext
        VC.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        present(VC, animated: true, completion: nil)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        locationSearchBar.setShowsCancelButton(false, animated: true)
        self.view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) 
    {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        settingButton.isHidden = false
        weatherLabel.isHidden = false
    }
}

// MARK: - TableView extension
extension WeatherListViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int 
    {
            return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell 
    {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherListTableViewCell", for: indexPath) as! WeatherListTableViewCell
            
            cell.backgroundColor = .clear
            cell.backgroundImage.image = UIImage(named: "weatherListCellBackground")
            cell.locationLabel.text = String(location)
            cell.timeOrCityLabel.text = time
            cell.weatherLabel.text = weather
            cell.temperatureLabel.text = "\(temperature)°\(temperatureUnits)"
            cell.highTemperatureLabel.text = "최고\(highTemperature)°\(temperatureUnits)"
            cell.lowTemperatureLabel.text = "최저 \(lowTemperature)°\(temperatureUnits)"
            
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) 
    {
//            UIView.animate(withDuration: 0.5)
//            {
//                // label의 frame을 새로운 위치로 이동시킴
//                self.weatherLabel.frame.origin = CGPoint(x: 20,y: -100)
//                self.settingButton.frame.origin = CGPoint(x: 350, y: -100)
//                
//            }
        let VC = MainViewController()
        VC.modalPresentationStyle = .fullScreen
        settingButton.isHidden = false
        weatherLabel.isHidden = false
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
            return 120
    }
}
