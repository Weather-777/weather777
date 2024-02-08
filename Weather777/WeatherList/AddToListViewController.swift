//
//  AddToListViewController.swift
//  Weather777
//
//  Created by 석진 on 2/8/24.
//

import UIKit
import SwiftUI

class AddToListViewController: UIViewController 
{

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
            cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
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
        
    }
    
    @objc func addLocation()
    {
        
    }
    
}


struct PreView: PreviewProvider
{
    static var previews: some View
    {
        AddToListViewController().toPreview()
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
