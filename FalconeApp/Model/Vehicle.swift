//
//  Vehicle.swift
//  FalconeApp
//
//  Created by praveen on 3/2/19.
//  Copyright © 2019 hmm. All rights reserved.
//

import Foundation

struct Vehicle: Codable {
    let name : String?
    let totalNumber : Int?
    let speed: Int?
    let maxDistance: Int?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case totalNumber = "total_no"
        case speed = "speed"
        case maxDistance = "max_distance"
    }
    
    init(name: String?, totalNumber: Int?, speed: Int?, maxDistance: Int?) {
        self.name = name
        self.totalNumber = totalNumber
        self.speed = speed
        self.maxDistance = maxDistance
    }
}
