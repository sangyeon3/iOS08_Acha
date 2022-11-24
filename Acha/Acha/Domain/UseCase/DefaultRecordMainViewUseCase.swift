//
//  DefaultRecordViewUseCase.swift
//  Acha
//
//  Created by 배남석 on 2022/11/21.
//

import Foundation
import Firebase
import RxSwift

final class DefaultRecordMainViewUseCase: RecordMainViewUseCase {
    private let ref: DatabaseReference!
    private let repository: RecordRepository
    private let disposeBag = DisposeBag()
    
    var recordData = BehaviorSubject<[RecordViewRecord]>(value: [])
    var mapData = BehaviorSubject<[Map]>(value: [])
    var allDates = PublishSubject<[String]>()
    var weekDatas = PublishSubject<[RecordViewChartData]>()
    var headerRecord = PublishSubject<RecordViewHeaderRecord>()
    var mapAtRecordId = PublishSubject<Map>()
    var recordsAtDate = PublishSubject<[String: [RecordViewRecord]]>()
    
    init(repository: RecordRepository) {
        ref = Database.database().reference()
        self.repository = repository
        
        loadMapData()
        loadRecordData()
    }
    
    func loadMapData() {
        self.repository.fetchMapData()
            .subscribe { maps in
                self.mapData.onNext(maps)
            }.disposed(by: self.disposeBag)
    }
    
    func loadRecordData() {
        self.repository.fetchRecordData()
            .subscribe(onNext: { records in
                self.recordData.onNext(records)
            }).disposed(by: self.disposeBag)
    }
        
    func fetchTotalDataAtDay() -> Observable<[String: DayTotalRecord]> {
        guard let records = try? self.recordData.value() else {
            return Observable.error(FirebaseServiceError.fetchError)
        }
        var totalDataAtDay = [String: DayTotalRecord]()
        records.forEach {
            if totalDataAtDay[$0.createdAt] != nil {
                totalDataAtDay[$0.createdAt]?.distance += $0.distance
                totalDataAtDay[$0.createdAt]?.calorie += $0.calorie
            } else {
                totalDataAtDay[$0.createdAt] = DayTotalRecord(distance: $0.distance,
                                                              calorie: $0.calorie)
            }
        }
        
        return Observable.create { emitter in
            emitter.onNext(totalDataAtDay)
            
            return Disposables.create()
        }
    }
    
    func getRecordsAtDate() {
        guard let records = try? self.recordData.value() else { return }
        var recordsAtDate = [String: [RecordViewRecord]]()
        records.forEach {
            if recordsAtDate[$0.createdAt] != nil {
                recordsAtDate[$0.createdAt]?.append($0)
            } else {
                recordsAtDate[$0.createdAt] = [$0]
            }
        }
        
        self.recordsAtDate.onNext(recordsAtDate)
    }
    
    func getAllDates() {
        guard let records = try? self.recordData.value() else { return }
        var allDates = [String]()
        
        records.forEach {
            if !allDates.contains($0.createdAt) {
                allDates.append($0.createdAt)
            }
        }
        
        allDates.sort {
            let firstCreateAt = $0.components(separatedBy: "-").map { Int($0)! }
            let secondCreateAt = $1.components(separatedBy: "-").map { Int($0)! }
            
            if firstCreateAt[0] == secondCreateAt[0] {
                if firstCreateAt[1] == secondCreateAt[1] {
                    return firstCreateAt[2] > secondCreateAt[2]
                }
                return firstCreateAt[1] > secondCreateAt[1]
            }
            return firstCreateAt[0] > secondCreateAt[0]
        }
        self.allDates.onNext(allDates)
    }

    func getWeekDatas() {
        self.fetchTotalDataAtDay()
            .subscribe(onNext: {
                let startDay = Date(timeIntervalSinceNow: -(86400 * 6))
                var weekDatas = Array(repeating: RecordViewChartData(number: 0, distance: 0), count: 7)
                
                for index in 0...6 {
                    let day = startDay.addingTimeInterval(Double(index) * 86400)
                    let dayString = day.convertToStringFormat(format: "yyyy-MM-dd")
                    guard let weekDayIndex = Int(day.convertToStringFormat(format: "e")) else { return }
                    weekDatas[index].number = weekDayIndex
                    
                    if let totalData = $0[dayString] {
                        weekDatas[index].distance = totalData.distance
                    }
                }
                self.weekDatas.onNext(weekDatas)
            }).disposed(by: self.disposeBag)
    }
    
    func getHeaderRecord(date: String) {
        self.fetchTotalDataAtDay()
            .subscribe {
                guard let totalDataAtDay = $0.element,
                      let totalData = totalDataAtDay[date] else { return }
                let headerRecord = RecordViewHeaderRecord(date: date,
                                                          distance: totalData.distance,
                                                          kcal: totalData.calorie)
                self.headerRecord.onNext(headerRecord)
            }.disposed(by: self.disposeBag)
    }
    
    func getmapAtRecordId(mapId: Int) {
        guard let maps = try? self.mapData.value() else { return }
        let map = maps.filter { $0.mapID == mapId }[0]
        self.mapAtRecordId.onNext(map)
    }
}
