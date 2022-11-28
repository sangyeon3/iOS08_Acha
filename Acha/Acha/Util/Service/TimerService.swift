//
//  TimerService.swift
//  Acha
//
//  Created by 조승기 on 2022/11/23.
//

import Foundation
import RxSwift

class TimerService: TimerServiceProtocol {
    var disposeBag = DisposeBag()
    
    func start() -> Observable<Int> {
        Observable<Int>
            .interval(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .map { $0 + 1 }
    }
    
    func start(until: Int) -> Observable<Void> {
        Observable<Int>
            .timer(.seconds(3), scheduler: MainScheduler.asyncInstance)
            .map { _ in }
    }
    
    func stop() {
        disposeBag = DisposeBag()
    }
}
