//
//  CityListManager.swift
//  Weather777
//
//  Created by 박민정 on 2/15/24.
//

import Foundation

//Weather에 대한 CRUD 관리 매니저
final class CityListManager {

    static var shared: CityListManager = .init()

    private let key = "Coord"

    private init() { }

    var datas: [Coord] {
        //R
        get {
            if let savedData = UserDefaults.standard.data(forKey: key),
               let decodedData = try? JSONDecoder().decode([Coord].self, from: savedData) {
                return decodedData
            }
            return []
        }
        //C -> 데이터에 저장된 값들
        set {
            if let encodedData = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encodedData, forKey: key)
            }
        }
    }
    
    //U
    func add(_ coord: Coord) {
        
        var coordList = datas
        
        coordList.append(coord)
        
        guard let data = try?
                JSONEncoder().encode(coordList)
        else{
            return
        }
        
        UserDefaults.standard.setValue(data, forKey: key)
    }
    
    func update(coordId: Int) {
        
        let coordList = datas
        
        guard coordList.firstIndex(where: { $0.id == coordId }) != nil
        else {
            return
        }
    }
    
    //D
    func delete(coordId: Int) {
        
        var coordList = datas
        
        coordList.removeAll { data in
            data.id == coordId
        }
        
        //TODO 지워진 상태
        guard let data = try?
                JSONEncoder().encode(coordList)
        else{
            return
        }
        UserDefaults.standard.setValue(data, forKey: key)
    }
    
    //데이터 전체 불러오기
    func readAll() -> [Coord] {
        guard let coordListData = UserDefaults.standard.data(forKey: key),
              let coordList = try? JSONDecoder().decode([Coord].self, from: coordListData)
        else{
            return []
        }
        return coordList
    }
}
