//
//  AnnotationView.swift
//  Weather777
//
//  Created by 박민정 on 2/9/24.
//

//관심지역 dummyData
//지역의 위경도, 날씨, 날씨 아이콘

import UIKit
import MapKit
import SnapKit

//커스텀 Annotation - 지역명, 현재 온도, 날씨 아이콘, 좌표 지정
class CustomAnnotation: NSObject, MKAnnotation {
    //지역명
    var title: String?
    //지역 현재 온도
    var temperature: Double?
    //위경도
    @objc dynamic var coordinate: CLLocationCoordinate2D
    
    init(
        title: String?,
        temperature: Double?,
        coordinate: CLLocationCoordinate2D
    ){
        self.title = title
        self.temperature = temperature
        self.coordinate = coordinate
        
        super.init()
    }
}

class CustomAnnotationView: MKAnnotationView {
    
    static let identifier = "CustomAnnotationView"

    lazy var backgroundView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .black
        label.textAlignment = .center
        
        return label
    }()
    
    lazy var regionLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .black
        label.textAlignment = .center
        
        return label
    }()
    
    lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [temperatureLabel, regionLabel])
        view.spacing = 5
        view.axis = .vertical
        view.backgroundColor = .white
        view.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        view.layer.cornerRadius = view.frame.height / 2
        
        return view
    }()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        bounds.size = CGSize(width: 50, height: 50)
        centerOffset = CGPoint(x: 0, y: -frame.size.height / 2)
        
        configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //뷰 안 제약조건 생성
    func configUI() {
        self.addSubview(backgroundView)
        backgroundView.addSubview(stackView)
        
        backgroundView.snp.makeConstraints { make in
            make.width.height.equalTo(50)
        }
        
        stackView.snp.makeConstraints { make in
            make.size.equalTo(50)
        }
    }
    
    //custom cell 재사용하기 위한 함수
    override func prepareForReuse() {
        super.prepareForReuse()
        
        regionLabel.text = nil
        temperatureLabel.text = nil
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        
        guard let annotation = annotation as? CustomAnnotation else { return }
        
        temperatureLabel.text = "\(String(describing: annotation.temperature))"
        regionLabel.text = annotation.title
        
        setNeedsLayout()
    }
}
