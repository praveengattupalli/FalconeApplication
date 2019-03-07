//
//  FindFalconeResponse.swift
//  FalconeApp
//
//  Created by praveen on 3/5/19.
//  Copyright © 2019 hmm. All rights reserved.
//

import Foundation

struct FindFalconeResponse: Codable {
    let planetName : String?
    let status: String?
    
    enum CodingKeys: String, CodingKey {
        case planetName = "planet_name"
        case status = "status"
    }
    
    init(planetName: String?, status: String?) {
        self.planetName = planetName
        self.status = status
        
    }
}
