//
//  WeatherListViewController.swift
//  Weather777
//
//  Created by Jason Yang on 2/5/24.
//

import UIKit
import SwiftUI
import MapKit

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
    
    var search = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
    let data = ["1", "2","3"]
    
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
    
    let searchResultTableView: UITableView =
    {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        
        return tableView
    }()
    
    // MARK: - viewDidLoad
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        
        addSubView()
        setLayout()
        
        search.delegate = self
        search.resultTypes = .address
        
        weatherListTableView.dataSource = self
        weatherListTableView.delegate = self
        searchResultTableView.dataSource = self
        searchResultTableView.delegate = self
        
        let weatherListnib = UINib(nibName: "WeatherListTableViewCell", bundle: nil)
        weatherListTableView.register(weatherListnib, forCellReuseIdentifier: "WeatherListTableViewCell")
        let searchListnib = UINib(nibName: "SearchResultTableViewCell", bundle: nil)
        searchResultTableView.register(searchListnib, forCellReuseIdentifier: "SearchResultTableViewCell")
        
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
        view.addSubview(searchResultTableView)
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
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) 
    {
        search.queryFragment = searchText
    }
}

// MARK: - MKLocalSearchCompleterDelegate
extension WeatherListViewController: MKLocalSearchCompleterDelegate
{
    // 자동완성 완료 시에 결과를 받는 함수
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter)
    {
        // completer.results를 통해 검색한 결과를 searchResults에 담아줍니다
        searchResults = completer.results
        searchResultTableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) 
    {
        // 에러 확인
        print(error.localizedDescription)
    }
}

// MARK: - TableView extension
extension WeatherListViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int 
    {
        if tableView == searchResultTableView
        {
            return searchResults.count
        }
        
        else
        {
            return data.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell 
    {
        
        if tableView == searchResultTableView
        {
           let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultTableViewCell", for: indexPath) as! SearchResultTableViewCell
                    
            cell.locationLabel.text = searchResults[indexPath.row].title
            cell.backgroundColor = .clear
            
            return cell
        }
        
        else
        
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
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) 
    {
        if tableView == searchResultTableView
        {
            let addToListVC = AddToListViewController()
            present(addToListVC, animated: true, completion: nil)
        }
        
        else
        {
            let addToListVC = MainViewController()
            addToListVC.modalPresentationStyle = .fullScreen
            present(addToListVC, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView == searchResultTableView
        {
            return 30
        }
        
        else
        {
            return 120
        }
    }
    
    
}


struct PreView: PreviewProvider
{
    static var previews: some View 
    {
        WeatherListViewController().toPreview()
    }
}


#if DEBUG
extension UIViewController {
    private struct Preview: UIViewControllerRepresentable 
    {
        let viewController: UIViewController

        func makeUIViewController(context: Context) -> UIViewController
        {
            return viewController
        }

        func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }
    }

    func toPreview() -> some View
    {
        Preview(viewController: self)
    }
}
#endif
