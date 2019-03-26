//
//  FalconeApiTests.swift
//  FalconeAppTests
//
//  Created by hgurnani on 3/21/19.
//  Copyright © 2019 hmm. All rights reserved.
//

import XCTest
@testable import FalconeApp

class DummyServiceManager: ServiceManagerProtocol {

    var url: String!
    var data: Data!

    func makeGetCall(url: String, successHandler: @escaping SuccessBlock,
                     failureHandler: @escaping FailureBlock) {
        self.url = url
        successHandler("Success", nil)
    }
    
    func makePostCall(url: String, data: Data?, successHandler: @escaping SuccessBlock,
                      failureHandler: @escaping FailureBlock) {
        self.data = data
        self.url = url
        successHandler("Success", nil)
    }
}

class FalconeApiTests: XCTestCase {

    var falconeApi: FalconeApi!

    var dummyServiceManager = DummyServiceManager()

    override func setUp() {
        falconeApi = FalconeApi(serviceManager: dummyServiceManager)
    }

    func testGetTokenShouldUseTokenEndPoint() {
        falconeApi.getToken(successHandler: {_,_ in
            
        }, failureHandler: {_,_ in })

        XCTAssertEqual("https://findfalcone.herokuapp.com/token",
                       dummyServiceManager.url)
    }

    func testGetPlanetsShouldUsePlanetsEndPoint() {
        falconeApi.getPlanets(successHandler: {_,_ in }, failureHandler: {_,_ in })

        XCTAssertEqual("https://findfalcone.herokuapp.com/planets",
                       dummyServiceManager.url)
    }

    func testGetVehiclesShouldUseVehicleEndPoint() {
        falconeApi.getVehicles(successHandler: {_,_ in }, failureHandler: {_,_ in })

        XCTAssertEqual("https://findfalcone.herokuapp.com/vehicles",
                       dummyServiceManager.url)
    }

    func testFindFalconeShouldUseFindEndPoint() throws {
        let request = FindFalconeRequest(token: "token", planetNames: [], vehicleNames: [])
        falconeApi.findFalcone(request: request, successHandler: {_,_ in},
                               failureHandler: {_,_ in})

        XCTAssertEqual("https://findfalcone.herokuapp.com/find",
                       dummyServiceManager.url)
        let encoder = JSONEncoder()
        let data = try! encoder.encode(request)
        XCTAssertEqual(data,
                       dummyServiceManager.data)
    }
}
