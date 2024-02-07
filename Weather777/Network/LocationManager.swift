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
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    //MARK: - CLLocationManagerDelegate
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location.coordinate
        onLocationUpdate?(currentLocation!)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error)")
    }
    
    public func setLocation(latitude: Double, longitude: Double) {
        currentLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    
}

