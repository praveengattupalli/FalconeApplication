//
//  FindFalconeRequest.swift
//  FalconeApp
//
//  Created by praveen on 3/5/19.
//  Copyright © 2019 hmm. All rights reserved.
//

import Foundation

struct FindFalconeRequest: Codable {
    let token : String?
    let planetNames: [String]
    let vehicleNames: [String]
    
    enum CodingKeys: String, CodingKey {
        case token = "token"
        case planetNames = "planet_names"
        case vehicleNames = "vehicle_names"
    }
    
    init(token: String?, planetNames: [String], vehicleNames: [String]) {
        self.planetNames = planetNames
        self.token = token
        self.vehicleNames = vehicleNames
    }
}
