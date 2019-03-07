//
//  Token.swift
//  FalconeApp
//
//  Created by praveen on 3/5/19.
//  Copyright © 2019 hmm. All rights reserved.
//

import Foundation

struct Token: Codable {
    let token : String?
    
    enum CodingKeys: String, CodingKey {
        case token = "token"
        
    }
    
    init(token: String?) {
        self.token = token
    }
}
