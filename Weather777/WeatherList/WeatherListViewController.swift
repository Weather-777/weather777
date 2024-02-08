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
    
    var location = 0
    var time = "17:00"
    var weather = "맑음"
    var temperature = 7
    var highTemperature = 10
    var lowTemperature = 3
    
    var settingValue = 1
    
    
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
        let C = UIAction(title: "섭씨", image: UIImage(named: "°C"), handler: { _ in self.settingValue = 1 })
        let F = UIAction(title: "화씨", image: UIImage(named: "°F"), handler: { _ in self.settingValue = 0 })
        let line = UIMenu(title: "", options: .displayInline, children: [C, F])
        
        let menu = UIMenu(title: "", children: [edit, line])
        
        
        button.menu = menu
        
        button.showsMenuAsPrimaryAction = true
        button.changesSelectionAsPrimaryAction = false
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()

    let locationSearchBar: UISearchBar =
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
        tableView.backgroundColor = UIColor.clear
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        
        addSubView()
        setLayout()
        
        weatherListTableView.dataSource = self
        weatherListTableView.delegate = self
        
        let nib = UINib(nibName: "WeatherListTableViewCell", bundle: nil)
        weatherListTableView.register(nib, forCellReuseIdentifier: "WeatherListTableViewCell")
        
        weatherListTableView.separatorStyle = .singleLine
        
    }
    
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
            weatherListTableView.heightAnchor.constraint(equalToConstant: 600),
        ])
    }
    
}


extension WeatherListViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int 
    {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell 
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherListTableViewCell", for: indexPath) as! WeatherListTableViewCell
        
        cell.backgroundColor = .clear
        cell.backgroundImage.image = UIImage(named: "weatherListCellBackground")
        cell.locationLabel.text = String(location)
        cell.timeOrCityLabel.text = time
        cell.weatherLabel.text = weather
        cell.temperatureLabel.text = "\(temperature)°\(settingValue)"
        cell.highTemperatureLabel.text = "최고\(highTemperature)°\(settingValue)"
        cell.lowTemperatureLabel.text = "최저 \(lowTemperature)°\(settingValue)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
            return 120
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
