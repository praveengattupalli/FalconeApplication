//
//  FalconeApi.swift
//  FalconeApp
//
//  Created by praveen on 3/2/19.
//  Copyright © 2019 hmm. All rights reserved.
//

import Foundation

class FalconeApi {
    
    lazy var serviceManager = ServiceManager()
    
    func getToken(successHandler: @escaping SuccessBlock,
                  failureHandler: @escaping FailureBlock) {
        serviceManager.makePostCall(url: FalconeApiConstants.FALCONE_API_URL +
            FalconeApiConstants.GET_TOKEN_END_POINT,
                                    data: nil,
                                   successHandler: successHandler,
                                   failureHandler: failureHandler)
    }
    
    func getPlanets(successHandler: @escaping SuccessBlock,
                    failureHandler: @escaping FailureBlock) {
        serviceManager.makeGetCall(url: FalconeApiConstants.FALCONE_API_URL + FalconeApiConstants.GET_PLANETS_END_POINT, successHandler: successHandler,
                                   failureHandler: failureHandler)
    }
    
    func getVehicles(successHandler: @escaping SuccessBlock,
                    failureHandler: @escaping FailureBlock) {
        serviceManager.makeGetCall(url: FalconeApiConstants.FALCONE_API_URL + FalconeApiConstants.GET_VEHICLES_END_POINT, successHandler: successHandler,
                                   failureHandler: failureHandler)
    }
    
    func findFalcone(data: Data, successHandler: @escaping SuccessBlock,
                     failureHandler: @escaping FailureBlock) {
        serviceManager.makePostCall(url: FalconeApiConstants.FALCONE_API_URL + FalconeApiConstants.FIND_FALCONE_END_POINT,
                                    data: data,
                                    successHandler: successHandler,
                                    failureHandler: failureHandler)
    }
    
    
}
