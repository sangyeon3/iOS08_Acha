//
//  RealtimeDatabaseNetworkService.swift
//  Acha
//
//  Created by 조승기 on 2022/11/27.
//

import Foundation
import RxSwift

protocol RealtimeDatabaseNetworkService {
    func fetch<T: Decodable>(path: String) -> Single<T>
}
