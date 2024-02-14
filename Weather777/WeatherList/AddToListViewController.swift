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

    weak var weatherListVC: WeatherListViewController?
    
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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        weatherListVC = parent as? WeatherListViewController
        
        self.view.backgroundColor = .black
        
        addSubView()
        setLayout()
    }
    
    
    func addSubView()
    {
        view.addSubview(cancelButton)
        view.addSubview(addButton)

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
            addButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    @objc func closeView()
    {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func addLocation()
    {
        weatherListVC?.data.append(index)
        weatherListVC?.weatherListTableView.reloadData()
        print("추가 \(index)")
    }
    
}


//struct PreView: PreviewProvider
//{
//    static var previews: some View
//    {
//        AddToListViewController().toPreview()
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
