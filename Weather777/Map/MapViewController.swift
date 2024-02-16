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

struct MapInfo {
    var cityname: String
    var temperature: Double
    var wind: String
}

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    //처음 화면 로드 시 강수량 디폴트
    var type: InfoType = .precipitation
    
    //userdefault 저장된 값 호출
    private var coordList: [Coord] = CityListManager.shared.readAll()
    
    //MapView에서만 사용될 데이터 배열
    var configMapInfo: [MapInfo] = []
    var weatherDataList: [WeatherInfo] = []
    
    var forecastData: [(cityname:String, time: String, weatherIcon: String, weatherdescription: String, temperature: Double, wind: String, humidity: Int, tempMin: Double, tempMax: Double, feelsLike: Double, rainfall: Double)] = []
    
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
    
    lazy var completeBtn: UIButton = {
        let button = UIButton()
        button.setTitle("완료", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor.white
        
        button.addTarget(self, action: #selector(goToMainView), for: .touchUpInside)
        
        return button
    }()
    
    var infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.backgroundColor = UIColor.white
        label.clipsToBounds = true
        label.layer.cornerRadius = 5
        label.textAlignment = .center
        
        return label
    }()
    
    lazy var centerLocateBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "location"), for: .normal)
        button.tintColor = .black
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.backgroundColor = UIColor.white
        
        //버튼의 상단부분만 둥글게 만들어주는 mask
        let maskPath = UIBezierPath(roundedRect: button.bounds, byRoundingCorners: [.topLeft,.topRight], cornerRadii: CGSize(width: 5.0, height: 5.0))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        button.layer.mask = maskLayer
        
        button.addTarget(self, action: #selector(goToMyLocation), for: .touchUpInside)
        
        return button
    }()
    
    lazy var myLocationsInfoBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        button.frame = CGRect(x: 330, y: 100, width: 40, height: 40)
        button.backgroundColor = UIColor.white
        button.tintColor = .black
        
        //버튼의 하단부분만 둥글게 만들어주는 mask
        let maskPath = UIBezierPath(roundedRect: button.bounds, byRoundingCorners: [.bottomLeft,.bottomRight], cornerRadii: CGSize(width: 5.0, height: 5.0))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        button.layer.mask = maskLayer
        
        button.addTarget(self, action: #selector(showLocationInfo), for: .touchUpInside)
        
        return button
    }()
    
    lazy var infoSectionBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "square.stack.3d.up"), for: .normal)
        button.tintColor = .black
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor.white
        
        let precipitation = UIAction(title: "강수량", image: UIImage(systemName: "umbrella"), state: .off, handler: { _ in
            self.type = .precipitation
            self.setInfoView()
        })
        let temperature = UIAction(title: "온도", image: UIImage(systemName: "thermometer.medium"), state: .off, handler: { _ in
            self.type = .temperature
            self.setInfoView()
        })
        let airquality = UIAction(title: "대기질", image: UIImage(systemName: "aqi.medium"), state: .off, handler: { _ in
            self.type = .airquality
            self.setInfoView()
        })
        
        let menu = UIMenu(title: "", options: .displayInline, children: [precipitation, temperature, airquality])
        
        button.menu = menu
        button.showsMenuAsPrimaryAction = true
        button.changesSelectionAsPrimaryAction = false
        
        return button
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //초기 rootView를 mapView로 지정
        view = mapView
        mapView.delegate = self
        mapView.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: CustomAnnotationView.identifier)
        
        print(coordList)
        addView()
        addViewConstraints()
        addAnnotation()
        setInfoView()
        
    }
    
    //MARK: - AddSubView
    private func addView() {
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
    }
    
    //MARK: - View Constraints
    private func addViewConstraints() {
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
    }
    //지역 설정
    private func setRegion() {
        guard let currentLocation = LocationManager.shared.currentLocation else { return }
        let center = CLLocationCoordinate2D(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        
        mapView.setRegion(region, animated: true)
    }
    //지역별 정보 모달
    private func showInfoModal() {
        let vc = InfoModalViewController()
        vc.type = self.type
        
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.largestUndimmedDetentIdentifier = .medium
        }
        self.present(vc, animated: true)
    }
    //정보 타입 설정에 따른 레이블 지정
    private func setInfoView() {
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
    //annotation 생성
    private func addAnnotation() {
        for coord in coordList {
            // 각 좌표값에 대한 annotation 생성
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: coord.lat, longitude: coord.lon)
            annotation.title = "관심지역"
            annotation.subtitle = "내가 관심있는 지역은"
            
            // 맵뷰에 annotation 추가
            mapView.addAnnotation(annotation)
        }
    }
    
//    func configInfo() {
//        configMapInfo.removeAll() // 이 부분은 유지
//        
//        let group = DispatchGroup()
//        
//        for coord in coordList {
//            group.enter() // DispatchGroup에 진입을 알립니다.
//            convertCoord(latitude: coord.lat, longitude: coord.lon) { mapInfo in
//                // 비동기 작업 완료 시 configMapInfo에 정보를 추가합니다.
//                self.configMapInfo.append(mapInfo)
//                group.leave() // DispatchGroup에서 나감을 알립니다.
//            }
//        }
//        
//        // 모든 비동기 작업이 완료될 때까지 대기합니다.
//        group.notify(queue: .main) {
//            // 여기에 필요한 처리를 추가할 수 있습니다.
//        }
//    }
    //저장소의 좌표값에 따라 값 가져온 배열 만들기
//    private func convertCoord(latitude: Double, longitude: Double, completion: @escaping (MapInfo) -> Void) {
//        let latitude = latitude
//        let longitude = longitude
//        
//        WeatherManager.shared.getForecastWeather(latitude: latitude, longitude: longitude) { [weak self] result in
//            switch result {
//            case .success(let data):
//                DispatchQueue.main.async {
//                    let now = Date()
//                    var selectedData = [(cityname: String, time: String, weatherIcon: String, weatherdescription: String, temperature: Double, wind: String, humidity: Int, tempMin: Double, tempMax: Double, feelsLike: Double, rainfall: Double)]()
//                    
//                    // DateFormatter 설정
//                    let dateFormatter = DateFormatter()
//                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//                    
//                    // 가장 가까운 과거 시간 찾기
//                    var closestPastIndex = -1
//                    for (index, forecast) in data.enumerated() {
//                        if let date = dateFormatter.date(from: forecast.time), date <= now {
//                            closestPastIndex = index
//                        } else {
//                            break // 이미 과거 시간 중 가장 가까운 시간을 찾았으므로 반복 중단
//                        }
//                    }
//                    
//                    // 가장 가까운 과거 시간부터 8개 데이터 선택
//                    if closestPastIndex != -1 {
//                        let startIndex = closestPastIndex
//                        let endIndex = min(startIndex + 8, data.count)
//                        selectedData = Array(data[startIndex..<endIndex])
//                    }
//                    
//                    self?.forecastData = selectedData
//                    
//                    let appenddata = MapInfo(cityname: self?.forecastData[0].cityname ?? "", temperature: self?.forecastData[0].temperature ?? 0, wind: self?.forecastData[0].wind ?? "")
//                    self?.configMapInfo.append(appenddata)
//                    
//                    let mapInfo = MapInfo(cityname: selectedData[0].cityname, temperature: selectedData[0].temperature, wind: selectedData[0].wind)
//                    completion(mapInfo)
//                }
//                
//            case .failure(let error):
//                print("Error: \(error)")
//            }
//        }
//    }
    
//    func registerObserver() {
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(appendLocationData),
//            name: NSNotification.Name("sendLocationData"),
//            object: nil
//        )
//    }
//    @objc func appendLocationData(notification: NSNotification) {
//        if let sendWeatherData = notification.object as? [WeatherInfo]
//        {
//            for data in sendWeatherData
//            {
//                let weatherInfo = WeatherInfo(cityName: data.cityName, time: data.time, weatherDescription: data.weatherDescription, temperature: data.temperature, tempMax: data.tempMax, tempMin: data.tempMin)
//                weatherDataList.append(weatherInfo)
//            }
//        }
//        else {
//            print("Received object is not of type WeatherInfo")
//        }
//    }
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
}

////MARK: - AnnotationDelegate
//extension MapViewController {
//    // 사용자 정의 어노테이션 추가
//    func createAnnotaion(locations: [Coord], Info: [WeatherInfo]?) {
//        // Info 배열이 nil인 경우 또는 비어 있는 경우 함수 종료
//            guard let info = Info, !info.isEmpty else {
//                print(1)
//                return
//            }
//
//            for searchData in locations {
//                guard let index = searchData.id else { continue }
//                
//                // Info 배열의 인덱스 0에 해당하는 요소가 있는지 확인
//                guard info.indices.contains(0) else {
//                    print(2)
//                    continue
//                }
//                
//                let title = info[index].cityName
//                let coordinate = CLLocationCoordinate2D(latitude: searchData.lat, longitude: searchData.lon)
//                let temperature = info[index].temperature
//                
//                addCustomPin(title: title, temperature: temperature, coordinate: coordinate)
//            }
//    }
//    //맵에 핀 생성
//    func addCustomPin(title: String,temperature: Double, coordinate: CLLocationCoordinate2D) {
//        let pin = CustomAnnotation(title: title, temperature: temperature, coordinate: coordinate)
//        mapView.addAnnotation(pin)
//    }
//}
//
//extension MapViewController {
//    // 사용자 정의 어노테이션 뷰를 반환하는 메서드
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        guard let annotation = annotation as? CustomAnnotation else {
//            return nil
//        }
//
//        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: CustomAnnotationView.identifier) as? CustomAnnotationView
//
//        if annotationView == nil {
//            annotationView = CustomAnnotationView(annotation: annotation, reuseIdentifier: CustomAnnotationView.identifier)
//        } else {
//            annotationView?.annotation = annotation
//        }
//        return annotationView
//    }
//}
