//
//  MultiGameUseCase.swift
//  Acha
//
//  Created by hong on 2022/12/06.
//

import Foundation
import RxSwift
import CoreLocation

protocol MultiGameUseCase {
    
    func timerStart() -> Observable<Int>
    func timerStop()
    
    func getLocation() -> Observable<Coordinate>
    func point() -> Observable<Int>
    var visitedLocation: Set<Coordinate> {get set}
}
