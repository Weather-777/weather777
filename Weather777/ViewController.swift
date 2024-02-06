//
//  ViewController.swift
//  Weather777
//
//  Created by Jason Yang on 2/5/24.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - UI Properties
    // Then은 기호에 따라 사용, 상단 탭 File - Add Package Dependencies - 우측 Url창 - 설치 주소 : https://github.com/devxoul/Then
    let testLabel: UILabel = {
        let label = UILabel()
        label.text = "7팀 화이팅입니다.😃 "
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUI()
        setAddSubView()
        setLayout()
        // Do any additional setup after loading the view.
    }
}


extension ViewController {
    func setUI() {
        // 배경색 지정
        view.backgroundColor = .white
    }
    
    func setAddSubView() {
        view.addSubview(testLabel)
    }
    
    func setLayout() {
        // SnapKit은 기호에 따라 사용, 상단 탭 File - Add Package Dependencies - 우측 Url창 - 설치 주소 : https://github.com/SnapKit/SnapKit.git
        NSLayoutConstraint.activate([
            testLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            testLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

