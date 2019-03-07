//
//  Planet.swift
//  FalconeApp
//
//  Created by praveen on 3/2/19.
//  Copyright © 2019 hmm. All rights reserved.
//
import Foundation

struct Planet: Codable {
    let name : String?
    let distance : Int?

    enum CodingKeys: String, CodingKey {
        case name = "name"
        case distance = "distance"
    }
    
    init(name: String?, distance: Int?) {
        self.name = name
        self.distance = distance
    }
}
