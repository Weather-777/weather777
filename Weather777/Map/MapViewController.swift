//
//  MapViewController.swift
//  Weather777
//
//  Created by Jason Yang on 2/5/24.
//

import UIKit
import MapKit
import SwiftUI
//import SnapKit

//struct PreView: PreviewProvider {
//    static var previews: some View {
//        MapViewController().toPreview()
//    }
//}
//
//#if DEBUG
//extension UIViewController {
//    private struct Preview: UIViewControllerRepresentable {
//        let viewController: UIViewController
//        
//        func makeUIViewController(context: Context) -> UIViewController {
//            return viewController
//        }
//        
//        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
//        }
//    }
//    
//    func toPreview() -> some View {
//        Preview(viewController: self)
//    }
//}
//#endif

//MARK: - MapViewController

class MapViewController: UIViewController, MKMapViewDelegate {
    
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
    
    var myLocationInfoBtn: UIButton = {
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
    
    //3가지 강수량, 온도, 대기질 나오는 드롭다운 버튼
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
        view.addArrangedSubview(button3)
        
        return view
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //초기 rootView를 mapView로 지정
        view = mapView
        mapView.delegate = self
        
        //완료 버튼
        view.addSubview(completeBtn)
        completeBtn.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).inset(60)
            make.leading.equalTo(view.snp.leading).inset(20)
            make.height.equalTo(40)
            make.width.equalTo(70)
        }
        
        //위치 조정 버튼
        view.addSubview(centerLocateBtn)
        centerLocateBtn.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).inset(60)
            make.trailing.equalTo(view.snp.trailing).inset(20)
            make.size.equalTo(40)
        }
        
        //현재 지역, 관심 지역 날씨 정보 리스트 팝업 버튼
        view.addSubview(myLocationInfoBtn)
        myLocationInfoBtn.snp.makeConstraints { make in
            make.top.equalTo(centerLocateBtn.snp.bottom)
            make.trailing.equalTo(view.snp.trailing).inset(20)
            make.size.equalTo(40)
        }
        
        //날씨 정보 선택(강수랑, 온도, 대기질) 버튼
        view.addSubview(infoSectionBtn)
        infoSectionBtn.snp.makeConstraints { make in
            make.top.equalTo(myLocationInfoBtn.snp.bottom).inset(-20)
            make.trailing.equalTo(view.snp.trailing).inset(20)
            make.size.equalTo(40)
        }
        
        //날씨 정보 선택 버튼 선택 시 나타나는 드롭다운 뷰
        view.addSubview(infoSectionDropdownView)
        infoSectionDropdownView.snp.makeConstraints { make in
            make.top.equalTo(infoSectionBtn.snp.bottom)
            make.trailing.equalTo(view.snp.trailing).inset(50)
            make.height.equalTo(120)
            make.width.equalTo(130)
        }
    }
}



//MARK: - objc func of buttons

extension MapViewController {
    
    @objc func goToMainView() {
        print(1)
    }
    
    @objc func goToMyLocation() {
        print(2)
    }
    
    @objc func showLocationInfo() {
        print(3)
    }
    
    @objc func changeInfo() {
        infoSectionDropdownView.isHidden = !infoSectionDropdownView.isHidden
    }
}
