//
//  LocationManager.swift
//  Weather777
//
//  Created by Jason Yang on 2/7/24.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    // 싱글톤 정적상수 활용
    static let shared = LocationManager()
    
    // Create a location manager. 초기화
    private let locationManager = CLLocationManager()
    
    // 위,경도 정보를 저장할 변수
    @Published var currentLocation: CLLocationCoordinate2D?
    
    // callback 위치가 업데이트되었을 때 자동 호출
    var onLocationUpdate: ((CLLocationCoordinate2D) -> Void)?
    
    override init() {
        super.init()
        
        // Configure the location manager.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // 현재 위치를 요청하는 메소드
    public func requestLocation() {
        //권한 요청하기
        locationManager.requestWhenInUseAuthorization()
        //위치 요청
        locationManager.requestLocation()
    }
    
    //MARK: - CLLocationManagerDelegate
    
    //권한 상태 확인
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            //권한 허가일 경우 현재 위치 업데이트
            manager.startUpdatingLocation()
        case .denied, .restricted:
            // alert 구현
            print("denied")
        case .notDetermined:
            //결정이 안되었을 경우 권한 요청
            manager.requestWhenInUseAuthorization()
        default:
            return
        }
    }
    
    //현재 위치를 받아오는 함수
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        //업데이트 되는 위치의 좌표를 currentLocation에 넣어줌
        currentLocation = location.coordinate
        print(location.coordinate)
    }
    
    //현재 위치를 받지 못할 경우 에러 구문 출력
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailedWithError")
    }
    
    public func setLocation(latitude: Double, longitude: Double) {
        currentLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

