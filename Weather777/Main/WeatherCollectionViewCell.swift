//
//  WeatherCollectionViewCell.swift
//  Weather777
//
//  Created by Dave on 2/14/24.
//

import UIKit
import SnapKit
import Then

class WeatherCollectionViewCell: UICollectionViewCell {
    
    let timeLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = UIFont(name: "Roboto-Regular", size: 15)
        $0.text = "오전 23시"
        $0.textColor = .white
    }
    let weatherIconImageView = UIImageView().then {
        $0.contentMode = .scaleToFill
    }
    let temperatureLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = UIFont(name: "Roboto-Regular", size: 15)
        $0.text = "22º"
        $0.textColor = .white
    }
    let windSpeedLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = UIFont(name: "Roboto-Regular", size: 15)
        $0.text = "1-5"
        $0.textColor = .white
    }
    let meterPerSecondLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = UIFont(name: "Roboto-Regular", size: 15)
        $0.text = "m/s"
        $0.textColor = .white
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        let stackViewFirst = UIStackView(arrangedSubviews: [timeLabel, weatherIconImageView, temperatureLabel]).then {
            $0.axis = .vertical
            $0.distribution = .equalSpacing
            $0.alignment = .center
            $0.spacing = 4
        }
        let stackViewSecond = UIStackView(arrangedSubviews: [windSpeedLabel, meterPerSecondLabel]).then {
            $0.axis = .vertical
            $0.distribution = .equalSpacing
            $0.alignment = .center
            $0.spacing = 0.5
        }
        addSubview(stackViewFirst)
        addSubview(stackViewSecond)
        stackViewFirst.snp.makeConstraints {
            $0.top.equalToSuperview().inset(24)
            $0.leading.trailing.equalToSuperview().inset(10)
        }
        weatherIconImageView.snp.makeConstraints {
            $0.width.equalTo(60)
            $0.height.equalTo(60)
        }
        stackViewSecond.snp.makeConstraints {
            $0.top.equalTo(stackViewFirst.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(10)
        }
    }
}
