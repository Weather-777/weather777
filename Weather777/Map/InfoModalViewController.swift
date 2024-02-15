//
//  InfoModalViewController.swift
//  Weather777
//
//  Created by 박민정 on 2/12/24.
//

import UIKit
import SwiftUI
import SnapKit
import MapKit

//지역별 정보 가지고 있는 모달 VC
class InfoModalViewController: UIViewController {
    
    var type: InfoType?
    var searchweatherData: [(title: String, coordinate: CLLocationCoordinate2D)] = []
    
    //MARK: - UI Component
    var infoImage: UIImageView = {
        let image = UIImageView()
        image.tintColor = .white
        image.contentMode = .scaleAspectFit
        
        return image
    }()
    
    var infotypeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        
        return label
    }()
    
    var yourLocationsLabel: UILabel = {
        let label = UILabel()
        label.text = "Your Locations"
        label.textColor = .white
        
        return label
    }()
    
    lazy var cancelBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.tintColor = .white
        
        button.addTarget(self, action: #selector(finishModal), for: .touchUpInside)
        
        return button
    }()
    
    var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        
        addView()
        addViewContraints()
        setInfotype()
        setupTableView()
    }
    
    func addView() {
        view.addSubview(infoImage)
        view.addSubview(infotypeLabel)
        view.addSubview(yourLocationsLabel)
        view.addSubview(cancelBtn)
        view.addSubview(tableView)
    }
    
    func addViewContraints() {
        infoImage.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).inset(20)
            make.leading.equalTo(view.snp.leading).inset(20)
            make.size.equalTo(40)
        }
        
        infotypeLabel.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).inset(20)
            make.leading.equalTo(infoImage.snp.trailing).inset(-10)
            make.height.equalTo(20)
        }
        
        yourLocationsLabel.snp.makeConstraints { make in
            make.top.equalTo(infotypeLabel.snp.bottom).inset(-5)
            make.leading.equalTo(infoImage.snp.trailing).inset(-10)
            make.height.equalTo(20)
        }
        
        cancelBtn.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).inset(20)
            make.trailing.equalTo(view.snp.trailing).inset(20)
            make.size.equalTo(40)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(yourLocationsLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview()
        }
    }
    
    func setInfotype() {
        switch type {
        case .precipitation:
            infoImage.image = UIImage(systemName: "umbrella")
            infotypeLabel.text = "강수량"
        case .temperature:
            infoImage.image = UIImage(systemName: "thermometer.medium")
            infotypeLabel.text = "온도"
        case .airquality:
            infoImage.image = UIImage(systemName: "aqi.medium")
            infotypeLabel.text = "대기질"
        case .none:
            return
        }
    }
    
    @objc func finishModal() {
        dismiss(animated: true)
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(InfoTableViewCell.self, forCellReuseIdentifier: "InfoCell")
        
        tableView.layer.cornerRadius = 10
        tableView.layer.masksToBounds = true
    }
}

extension InfoModalViewController: UITableViewDataSource, UITableViewDelegate {
    
    //테이블 항목 수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchweatherData.count 
    }
    
    //셀 구성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath) as! InfoTableViewCell
        cell.titleLabel.text = searchweatherData[indexPath.row].title
        //정보 종류에 따른 detaillabel
        switch type {
        case .precipitation:
            cell.detailLabel.text = "강수량 detail information"
        case .temperature:
            cell.detailLabel.text = "온도 detail information"
        case .airquality:
            cell.detailLabel.text = "대기질 detail information"
        case .none:
            cell.detailLabel.text = "detail information"
        }
        return cell
    }
    
    //셀 선택 시
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //해당 지역 annotation으로 이동하기
    }
}

class InfoTableViewCell: UITableViewCell {
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        
        return label
    }()
    
    var detailLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(titleLabel)
        addSubview(detailLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        
        detailLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
