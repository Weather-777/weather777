//
//  MainViewController.swift
//  Weather777
//
//  Created by Jason Yang on 2/5/24.
//

import UIKit
import SwiftUI
import SnapKit
import Then
import Gifu

class MainViewController: UIViewController {
    
    // GIFImageView 인스턴스를 클래스 레벨에서 관리합니다.
    var gifImageView: GIFImageView?

    let viewOverGif = UIView().then {
        $0.backgroundColor = .white.withAlphaComponent(0)
    }
    
    let bottomViewSeparatorLine = UIView().then {
        $0.backgroundColor = .white
    }
    
    let bottomView = UIView().then {
        $0.backgroundColor = .blue
    }
    
    let mapButton = UIButton().then {
        $0.setImage(UIImage(named: "Map"), for: .normal)
    }
    
    let weatherListButton = UIButton().then {
        $0.setImage(UIImage(named: "WeatherList"), for: .normal)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateBackgroundGIF(with: "CleanSky")
        setUpViewHierarchy()
        setUpLayout()
    }
    
    func updateBackgroundGIF(with gifName: String) {
        // 기존 GIFImageView가 있다면 제거합니다.
        gifImageView?.removeFromSuperview()
        
        // Then을 사용하여 GIFImageView를 초기화하고 속성을 설정합니다.
        gifImageView = GIFImageView().then {
            $0.contentMode = .scaleAspectFill
            $0.animate(withGIFNamed: gifName)
            $0.alpha = 0.5 // 백그라운드 GIF의 알파값 조정
        }
        
        // 안전하게 unwrap 후 뷰에 추가하고, SnapKit을 사용하여 제약을 설정합니다.
        if let gifImageView = gifImageView {
            view.insertSubview(gifImageView, at: 0) // gifImageView를 메인 뷰의 맨 아래에 추가
            gifImageView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
    }
    
    private func setUpViewHierarchy() {
        view.addSubview(viewOverGif)
        viewOverGif.addSubview(bottomViewSeparatorLine)
        viewOverGif.addSubview(bottomView)
        bottomView.addSubview(mapButton)
        bottomView.addSubview(weatherListButton)
    }
    
    private func setUpLayout() {
        viewOverGif.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        bottomViewSeparatorLine.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(45)
        }
        bottomView.snp.makeConstraints {
            $0.top.equalTo(bottomViewSeparatorLine.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        mapButton.snp.makeConstraints {
            $0.width.equalTo(25)
            $0.height.equalTo(23)
            $0.top.equalToSuperview().inset(10)
            $0.leading.equalToSuperview().inset(24)
        }
        weatherListButton.snp.makeConstraints {
            $0.width.equalTo(25)
            $0.height.equalTo(23)
            $0.top.equalToSuperview().inset(10)
            $0.trailing.equalToSuperview().inset(24)
        }
    }
}
