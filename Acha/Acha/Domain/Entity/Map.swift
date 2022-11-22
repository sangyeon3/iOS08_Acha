//
//  Map.swift
//  Acha
//
//  Created by  sangyeon on 2022/11/14.
//

import Foundation

// MARK: - Map
struct Map: Decodable {
    let mapID: Int
    let name: String
    let centerCoordinate: Coordinate
    let coordinates: [Coordinate]
    let records: [Int]?

    enum CodingKeys: String, CodingKey {
        case mapID = "mapId"
        case name, centerCoordinate, coordinates, records
    }
}

// MARK: - Coordinate
struct Coordinate: Decodable {
    let latitude, longitude: Double
}
