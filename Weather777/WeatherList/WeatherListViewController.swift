//
//  WeatherListViewController.swift
//  Weather777
//
//  Created by Jason Yang on 2/5/24.
//

import UIKit
import SwiftUI

class WeatherListViewController: UIViewController
{
    
    
    var location = 0
    var weather = "맑음"
    var time = "17:00"
    var temperature = 7
    var highTemperature = 10
    var lowTemperature = 3
    
    
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
    
    let settingButton: UIButton =
    {
        let button = UIButton()
        button.setImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
        button.tintColor = .white
        button.setTitleColor(.clear, for: .normal)
        
        let edit = UIAction(title: "목록 편집", image: UIImage(systemName: "pencil"), handler: { _ in print("목록 편집") })
        let C = UIAction(title: "섭씨", image: UIImage(named: "°C"), handler: { _ in print("섭씨 설정") })
        let F = UIAction(title: "화씨", image: UIImage(named: "°F"), handler: { _ in print("화씨 설정") })
        let line = UIMenu(title: "", options: .displayInline, children: [C, F])
        
        let menu = UIMenu(title: "", children: [edit, line])
        
        
        button.menu = menu
        
        button.showsMenuAsPrimaryAction = true
        button.changesSelectionAsPrimaryAction = true
        
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
        weatherListTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
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
            locationSearchBar.widthAnchor.constraint(equalToConstant: 370),
            locationSearchBar.heightAnchor.constraint(equalToConstant: 30),
     
        
            weatherListTableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            weatherListTableView.topAnchor.constraint(equalTo: locationSearchBar.bottomAnchor, constant: 20),
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell 
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        return cell
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
