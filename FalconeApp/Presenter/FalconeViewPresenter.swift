//
//  FalconeViewPresenter.swift
//  FalconeApp
//
//  Created by praveen on 3/10/19.
//  Copyright © 2019 hmm. All rights reserved.
//

import Foundation
import SVProgressHUD

protocol FalconeViewDelegate: class {

    func onFindFalconeSuccess(response: FindFalconeResponse)

    func onFindFalconeFailure()

    func reloadView()
}

class FalconeViewPresenter {

    let api: FalconeApi

    var vehiclesArray = [Vehicle]()

    var token: Token?

    var planetsArray = [Planet]()

    static let allowedPlanetSelectionCount = 4

    var selectedPlanetArray = [Int : Planet]()

    var selectedVehicleArray = [Int : Vehicle]()

    weak var falconeViewDelegate: FalconeViewDelegate?

    init(api: FalconeApi, falconeViewDelegate: FalconeViewDelegate?) {
        self.api = api
        self.falconeViewDelegate = falconeViewDelegate
    }
    
    func getPlanetsArray() -> [Planet] {
        return planetsArray
    }
    
    func getVehiclesArray() -> [Vehicle] {
        return vehiclesArray
    }

    func getSelectedPlanetArray() -> [Int : Planet] {
        return selectedPlanetArray
    }

    func getSelectedVehicleArray() -> [Int : Vehicle] {
        return selectedVehicleArray
    }
    
    func updateSelectedVehicleArray(key: Int, value: Vehicle) {
        selectedVehicleArray[key] = value
    }
    
    func updateSelectedPlanetArray(key: Int, value: Planet) {
        selectedPlanetArray[key] = value
    }

    func removeSelectedVehicle(key: Int) {
        selectedVehicleArray.removeValue(forKey: key)
    }

    func onViewLoaded() {
        invokeApis()
    }

    func invokeApis() {
        SVProgressHUD.show()
        getPlanets()
        getVehicles()
    }

    func onFindFalconeButtonTapped() {
        SVProgressHUD.show()
        getToken()
    }

    func getToken() {
        api.getToken(successHandler: { (successResponse, _) in
            if let successResponse = successResponse {
                do {
                    let token = try JSONDecoder().decode(Token.self, from: (successResponse as? Data)!)
                    self.findFalconeApi(token: token.token!)
                } catch {
                    print(error)
                    SVProgressHUD.dismiss()
                }
            }
        }, failureHandler: { (_,_) in
            SVProgressHUD.dismiss()
        })
    }

    func findFalconeApi(token: String) {
        var apiPlanets = [String]()
        for (_, value) in selectedPlanetArray.enumerated() {
            apiPlanets.append(value.value.name! )
        }
        
        var apiVehicles = [String]()
        for (_, value) in selectedVehicleArray.enumerated() {
            apiVehicles.append(value.value.name! )
        }
        
        let request = FindFalconeRequest(token: token, planetNames: apiPlanets, vehicleNames: apiVehicles)
        
        api.findFalcone(request: request, successHandler: { (successResponse, _) in
            SVProgressHUD.dismiss()
            if let successResponse = successResponse {
                do {
                    let response = try JSONDecoder().decode(FindFalconeResponse.self, from: (successResponse as? Data)!)
                    if response.status == "success" {
                        DispatchQueue.main.async {
                            self.falconeViewDelegate?.onFindFalconeSuccess(response: response)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.falconeViewDelegate?.onFindFalconeFailure()
                        }
                    }
                } catch {
                    print(error)
                }
            }
        }, failureHandler: { (_,_) in
            SVProgressHUD.dismiss()
        })
    }

    func getVehicles() {
        api.getVehicles(successHandler: { (successResponse, _) in
            SVProgressHUD.dismiss()
            if let successResponse = successResponse {
                do {
                    let vehicles = try JSONDecoder().decode([Vehicle].self, from: (successResponse as? Data)!)
                    print(vehicles)
                    DispatchQueue.main.async {
                        self.vehiclesArray = vehicles
                        self.falconeViewDelegate?.reloadView()
                    }
                } catch {
                    print(error)
                }
            }
        }, failureHandler: { (_,_) in
            SVProgressHUD.dismiss()
        })
    }

    func getPlanets() {
        api.getPlanets(successHandler: { (successResponse, _) in
            SVProgressHUD.dismiss()
            if let successResponse = successResponse {
                do {
                    let planets = try JSONDecoder().decode([Planet].self, from: (successResponse as? Data)!)
                    print(planets)
                    DispatchQueue.main.async {
                        self.planetsArray = planets
                        self.falconeViewDelegate?.reloadView()
                    }
                } catch {
                    print(error)
                }
            }
        }, failureHandler: { (_,_) in
            SVProgressHUD.dismiss()
        })
    }

    func canVehicleBeUsed(vehicle: Vehicle, planet: Planet?) -> Bool {
        guard let planet = planet else {
            return true
        }
        return planet.distance! <= vehicle.maxDistance!
    }

    func isPlanetAlreadySelected(_ selectedPlanet: Planet) -> Bool {
        var selectedPlanetArray = self.getSelectedPlanetArray()
        for planet in selectedPlanetArray.values {
            if planet.name == selectedPlanet.name {
                return true
            }
        }
        return false
    }

    func getVehicleCount(vehicle: Vehicle, row: Int, section: Int) -> Int {
        let totalNumber = vehicle.totalNumber ?? 0
        var sectionArray = [Int]()
        let selectedVehicleArray = self.getSelectedVehicleArray()
        for (_, value) in selectedVehicleArray.enumerated() {
            if value.value.name == vehicle.name {
                sectionArray.append(value.key)
            }
        }
        if sectionArray.contains(section) {
            sectionArray.sort()
            let index = sectionArray.index(where: { $0 == section })
            return totalNumber - index!
        } else {
            return totalNumber - sectionArray.count
        }
    }
}
