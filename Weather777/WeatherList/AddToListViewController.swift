//
//  AddToListViewController.swift
//  Weather777
//
//  Created by 석진 on 2/8/24.
//

import UIKit
import MapKit
import SwiftUI


class AddToListViewController: UIViewController
{
    var location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 37.5670135, longitude: 126.9783740)
    var index = "데이터"
    
    lazy var cancelButton: UIButton =
    {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    lazy var addButton: UIButton =
    {
        let button = UIButton()
        button.setTitle("추가", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(addLocation), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    lazy var printButton: UIButton =
    {
        let button = UIButton()
        button.setTitle("출력", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(printInfo), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
// MARK: - Life Cycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        
        addSubView()
        setLayout()
        
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        NotificationCenter.default.post(
            name: Notification.Name("sendData"),
            object: location
        )
    }
    
// MARK: - 레이아웃 지정
    func addSubView()
    {
        view.addSubview(cancelButton)
        view.addSubview(addButton)
        view.addSubview(printButton)
    }

    func setLayout()
    {
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            cancelButton.widthAnchor.constraint(equalToConstant: 40),
            cancelButton.heightAnchor.constraint(equalToConstant: 20),
            
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            addButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            addButton.widthAnchor.constraint(equalToConstant: 40),
            addButton.heightAnchor.constraint(equalToConstant: 30),
            
            printButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            printButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            printButton.widthAnchor.constraint(equalToConstant: 40),
            printButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
        
// MARK: - 버튼 동작
    @objc func printInfo()
    {
        print(location)
    }
    
    @objc func closeView()
    {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func addLocation()
    {
        dismiss(animated: true, completion: nil)
    }
    
}
