//
//  SearchViewController.swift
//  Weather777
//
//  Created by 석진 on 2/13/24.
//

import UIKit
import MapKit

class SearchViewController: UIViewController
{
    weak var weatherListVC: WeatherListViewController?

    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
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
    
    let searchResultTableView: UITableView =
    {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        weatherListVC = parent as? WeatherListViewController
        self.view.backgroundColor = .black
        
        addSubView()
        setLayout()
        
        locationSearchBar.delegate = self
        locationSearchBar.becomeFirstResponder()
        searchCompleter.resultTypes = .address
        searchCompleter.delegate = self
        
        searchResultTableView.dataSource = self
        searchResultTableView.delegate = self
        
        let searchListnib = UINib(nibName: "SearchResultTableViewCell", bundle: nil)
        searchResultTableView.register(searchListnib, forCellReuseIdentifier: "SearchResultTableViewCell")

    }
    
    // MARK: - 레이아웃 지정
        func addSubView()
        {
            view.addSubview(locationSearchBar)
            view.addSubview(searchResultTableView)
        }
        
        func setLayout()
        {
            NSLayoutConstraint.activate([
                locationSearchBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                locationSearchBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
                locationSearchBar.widthAnchor.constraint(equalToConstant: 384),
                locationSearchBar.heightAnchor.constraint(equalToConstant: 30),
                
                searchResultTableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                searchResultTableView.topAnchor.constraint(equalTo: locationSearchBar.bottomAnchor, constant: 20),
                searchResultTableView.widthAnchor.constraint(equalToConstant: 370),
                searchResultTableView.heightAnchor.constraint(equalToConstant: 600)
            ])
        }
}


// MARK: - SearchBar extension
extension SearchViewController: UISearchBarDelegate
{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if searchText.isEmpty
        {
            searchResults.removeAll()
            searchResultTableView.reloadData()
        }
        searchCompleter.queryFragment = searchText
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        locationSearchBar.setShowsCancelButton(false, animated: true)
        self.view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        // SearchBar의 텍스트를 지우고, 키보드를 닫음
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        dismiss(animated: true, completion: nil)
//        settingButton.isHidden = false
//        weatherLabel.isHidden = false
    }
}

// MARK: - MKLocalSearchCompleterDelegate
extension SearchViewController: MKLocalSearchCompleterDelegate
{
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter)
    {
        searchResults = completer.results
        searchResultTableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error)
    {
        print(error.localizedDescription)
    }
}


// MARK: - TableView extension
extension SearchViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultTableViewCell", for: indexPath) as! SearchResultTableViewCell
                    
        cell.locationLabel.text = searchResults[indexPath.row].title
        cell.backgroundColor = .clear
            
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let addToListVC = AddToListViewController()
        addToListVC.modalPresentationStyle = .pageSheet
        present(addToListVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 30
    }
}
