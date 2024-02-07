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
    
    let iconTest = UIImageView().then {
        $0.image = UIImage(named: "Wind")
    }
    
    let viewOverGif = UIView().then {
        $0.backgroundColor = .white.withAlphaComponent(0)
    }
    
    // GIFImageView 인스턴스를 클래스 레벨에서 관리합니다.
    var gifImageView: GIFImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateBackgroundGIF(with: "CleanSky")
        
        // 메인 뷰에 viewOverGif 추가
        view.addSubview(viewOverGif)
        // viewOverGif 위에 iconTest 추가
        viewOverGif.addSubview(iconTest)
        
        // viewOverGif의 제약 조건 설정
        viewOverGif.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        // iconTest의 제약 조건 설정
        iconTest.snp.makeConstraints {
            $0.width.equalTo(50)
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().inset(100)
            $0.centerX.equalToSuperview()
        }
    }
    
    func updateBackgroundGIF(with gifName: String) {
        // 기존 GIFImageView가 있다면 제거합니다.
        gifImageView?.removeFromSuperview()
        
        // Then을 사용하여 GIFImageView를 초기화하고 속성을 설정합니다.
        gifImageView = GIFImageView().then {
            $0.contentMode = .scaleAspectFill
            $0.animate(withGIFNamed: gifName)
            $0.alpha = 0.8 // 백그라운드 GIF의 알파값 조정
        }
        
        // 안전하게 unwrap 후 뷰에 추가하고, SnapKit을 사용하여 제약을 설정합니다.
        if let gifImageView = gifImageView {
            view.insertSubview(gifImageView, at: 0) // gifImageView를 메인 뷰의 맨 아래에 추가
            gifImageView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
    }
}
