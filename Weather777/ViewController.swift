//
//  ViewController.swift
//  Weather777
//
//  Created by Jason Yang on 2/5/24.
//

import UIKit
import SnapKit
import Then

class ViewController: UIViewController {
    
    // MARK: - UI Properties
    // Then은 기호에 따라 사용, 상단 탭 File - Add Package Dependencies - 우측 Url창 - 설치 주소 : https://github.com/devxoul/Then
    let testLabel = UILabel().then {
        $0.text = "7팀 화이팅입니다.😃 "
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
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
        testLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
}
