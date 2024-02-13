//
//  MapViewController.swift
//  Weather777
//
//  Created by Jason Yang on 2/5/24.
//

import UIKit
import MapKit
import SwiftUI
import SnapKit

//강수량, 온도, 대기질 type
enum InfoType {
    case precipitation
    case temperature
    case airquality
}

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    //처음 화면 로드 시 강수량 디폴트
    var type: InfoType = .precipitation
    
    //임의로 지역 배열- 지역명과 좌표만 저장되어 있는 형태
    var searchweatherData: [(title: String, coordinate: CLLocationCoordinate2D)] = [("1", CLLocationCoordinate2D(latitude: 37.2719952, longitude: 127.4348221)), ("2", CLLocationCoordinate2D(latitude: 37.58218213889754, longitude: 127.0594372509795))]
    
    // MARK: - UIProperties
    var mapView: MKMapView = {
        let view = MKMapView()
        view.showsUserLocation = true
        view.isZoomEnabled = true
        view.isRotateEnabled = true
        view.mapType = MKMapType.standard
        
        return view
    }()
    
    var completeBtn: UIButton = {
        let button = UIButton()
        button.setTitle("완료", for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor.gray
        
        button.addTarget(self, action: #selector(goToMainView), for: .touchUpInside)
        
        return button
    }()
    
    var infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.backgroundColor = UIColor.gray
        label.clipsToBounds = true
        label.layer.cornerRadius = 5
        label.textAlignment = .center
        
        return label
    }()
    
    var centerLocateBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "location"), for: .normal)
        button.tintColor = .white
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.backgroundColor = UIColor.gray
        
        //버튼의 상단부분만 둥글게 만들어주는 mask
        let maskPath = UIBezierPath(roundedRect: button.bounds, byRoundingCorners: [.topLeft,.topRight], cornerRadii: CGSize(width: 5.0, height: 5.0))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        button.layer.mask = maskLayer
        
        button.addTarget(self, action: #selector(goToMyLocation), for: .touchUpInside)
        
        return button
    }()
    
    var myLocationsInfoBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        button.frame = CGRect(x: 330, y: 100, width: 40, height: 40)
        button.backgroundColor = UIColor.gray
        button.tintColor = .white
        
        //버튼의 하단부분만 둥글게 만들어주는 mask
        let maskPath = UIBezierPath(roundedRect: button.bounds, byRoundingCorners: [.bottomLeft,.bottomRight], cornerRadii: CGSize(width: 5.0, height: 5.0))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        button.layer.mask = maskLayer
        
        button.addTarget(self, action: #selector(showLocationInfo), for: .touchUpInside)
        
        return button
    }()
    
    var infoSectionBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "square.stack.3d.up"), for: .normal)
        button.frame = CGRect(x: 330, y: 150, width: 40, height: 40)
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor.gray
        button.tintColor = .white
        
        button.addTarget(self, action: #selector(changeInfo), for: .touchUpInside)
        
        return button
    }()
    
    //stackView에 3가지 버튼을 추가한 뷰 구현
    var infoSectionDropdownView: UIStackView = {
        let view = UIStackView()
        view.backgroundColor = .gray
        view.axis = .vertical
        view.distribution = .fillEqually
        view.layer.cornerRadius = 5
        view.isHidden = true
        view.frame = CGRect(x: 230, y: 190, width: 120, height: 120)
        
        let button1 = UIButton(type: .system)
        button1.setTitle("강수량", for: .normal)
        button1.setImage(UIImage(systemName: "umbrella"), for: .normal)
        button1.titleEdgeInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0)
        button1.imageEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 10)
        button1.contentHorizontalAlignment = .leading
        button1.backgroundColor = .gray
        button1.layer.cornerRadius = 5
        button1.tintColor = .white
        button1.tag = 0
        button1.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        view.addArrangedSubview(button1)
        
        let button2 = UIButton(type: .system)
        button2.setTitle("온도", for: .normal)
        button2.setImage(UIImage(systemName: "thermometer.medium"), for: .normal)
        button2.titleEdgeInsets = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 0)
        button2.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        button2.contentHorizontalAlignment = .leading
        button2.backgroundColor = .gray
        button2.layer.cornerRadius = 5
        button2.tintColor = .white
        button2.tag = 1
        button2.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        view.addArrangedSubview(button2)
        
        let button3 = UIButton(type: .system)
        button3.setTitle("대기질", for: .normal)
        button3.setImage(UIImage(systemName: "aqi.medium"), for: .normal)
        button3.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        button3.imageEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 15)
        button3.contentHorizontalAlignment = .leading
        button3.backgroundColor = .gray
        button3.layer.cornerRadius = 5
        button3.tintColor = .white
        button3.tag = 2
        button3.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        view.addArrangedSubview(button3)
        
        return view
    }()

    //LocationManager 호출
    var locationManager = LocationManager.shared
    //Weathermanager 호출
    var weatherManager = WeatherManager.shared
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //초기 rootView를 mapView로 지정
        view = mapView
        mapView.delegate = self
        mapView.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: CustomAnnotationView.identifier)
        
        //유저 위치 보여주기
//        mapView.showsUserLocation = true
        
        addView()
        addViewConstraints()
        setRegion()
        setInfoView()
        createAnnotaion(locations: searchweatherData)
        
    }
    
    //MARK: - AddSubView
    func addView() {
        //완료 버튼
        view.addSubview(completeBtn)
        //현재 정보
        view.addSubview(infoLabel)
        //위치 조정 버튼
        view.addSubview(centerLocateBtn)
        //현재 지역, 관심 지역 날씨 정보 리스트 팝업 버튼
        view.addSubview(myLocationsInfoBtn)
        //날씨 정보 선택(강수랑, 온도, 대기질) 버튼
        view.addSubview(infoSectionBtn)
        //날씨 정보 선택 버튼 선택 시 나타나는 드롭다운 뷰
        view.addSubview(infoSectionDropdownView)
    }
    
    //MARK: - View Constraints
    func addViewConstraints() {
        completeBtn.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).inset(60)
            make.leading.equalTo(view.snp.leading).inset(20)
            make.height.equalTo(40)
            make.width.equalTo(70)
        }
        
        infoLabel.snp.makeConstraints { make in
            make.top.equalTo(completeBtn.snp.bottom).inset(-10)
            make.leading.equalTo(view.snp.leading).inset(20)
            make.height.equalTo(30)
            make.width.equalTo(70)
        }
        
        centerLocateBtn.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).inset(60)
            make.trailing.equalTo(view.snp.trailing).inset(20)
            make.size.equalTo(40)
        }
        
        myLocationsInfoBtn.snp.makeConstraints { make in
            make.top.equalTo(centerLocateBtn.snp.bottom)
            make.trailing.equalTo(view.snp.trailing).inset(20)
            make.size.equalTo(40)
        }
        
        infoSectionBtn.snp.makeConstraints { make in
            make.top.equalTo(myLocationsInfoBtn.snp.bottom).inset(-20)
            make.trailing.equalTo(view.snp.trailing).inset(20)
            make.size.equalTo(40)
        }
        
        infoSectionDropdownView.snp.makeConstraints { make in
            make.top.equalTo(infoSectionBtn.snp.bottom)
            make.trailing.equalTo(view.snp.trailing).inset(50)
            make.height.equalTo(120)
            make.width.equalTo(130)
        }
    }
    
    //지역 설정
    func setRegion() {
        guard let currentLocation = locationManager.currentLocation else { return }
        let center = CLLocationCoordinate2D(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        
        mapView.setRegion(region, animated: true)
    }
    
    //지역별 정보 모달
    func showInfoModal() {
        let vc = InfoModalViewController()
        vc.type = self.type
        vc.searchweatherData = self.searchweatherData
        
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.largestUndimmedDetentIdentifier = .medium
        }
        self.present(vc, animated: true)
    }
    
    //정보 타입 설정에 따른 레이블 지정
    func setInfoView() {
        //화면 텍스트
        switch type {
        case .precipitation:
            infoLabel.text = "강수량"
        case .temperature:
            infoLabel.text = "온도"
        case .airquality:
            infoLabel.text = "대기질"
        }
        //이후에 타입에 따라 화면에 애니메이션 구성
    }
}


//MARK: - objc func of buttons
extension MapViewController {
    
    @objc func goToMainView() {
        //이전 메인 뷰로 돌아가기(present로 mapView열림)
        dismiss(animated: true)
    }
    
    @objc func goToMyLocation() {
        //현재 위치(지역)으로 돌아감
        setRegion()
    }
    
    @objc func showLocationInfo() {
        showInfoModal()
    }
    
    @objc func changeInfo() {
        //infoSection 버튼 나타내기, 숨기기 적용
        infoSectionDropdownView.isHidden.toggle()
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        // 버튼 태그에 따라 정보 타입 결정
        switch sender.tag {
        case 0:
            type = .precipitation
        case 1:
            type = .temperature
        case 2:
            type = .airquality
        default:
            return
        }
        //변경되면 레이블 값 update하기 위해 함수 호출
        setInfoView()
        infoSectionDropdownView.isHidden.toggle()
    }
}

//MARK: - AnnotationDelegate
extension MapViewController {
    // 사용자 정의 어노테이션 추가
    func createAnnotaion(locations: [(title: String, coordinate: CLLocationCoordinate2D)]) {
        for searchData in locations {
            let title = searchData.title
            let coordinate = searchData.coordinate
            let temperature = "2°C"
            
            addCustomPin(title: title, temperature: temperature, coordinate: coordinate)
        }
    }
    //맵에 핀 생성
    func addCustomPin(title: String,temperature: String, coordinate: CLLocationCoordinate2D) {
        let pin = CustomAnnotation(title: title, temperature: temperature, coordinate: coordinate)
        mapView.addAnnotation(pin)
    }
}

extension MapViewController {
    // 사용자 정의 어노테이션 뷰를 반환하는 메서드
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? CustomAnnotation else {
            return nil
        }

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: CustomAnnotationView.identifier) as? CustomAnnotationView

        if annotationView == nil {
            annotationView = CustomAnnotationView(annotation: annotation, reuseIdentifier: CustomAnnotationView.identifier)
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }
}
