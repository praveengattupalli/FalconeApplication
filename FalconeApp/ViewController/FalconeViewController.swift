//
//  FalconeViewController.swift
//  FalconeApp
//
//  Created by praveen on 3/2/19.
//  Copyright © 2019 hmm. All rights reserved.
//

import UIKit
import SVProgressHUD

class FalconeViewController: UIViewController {

    @IBOutlet weak var timeTakenLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    let api = FalconeApi()
    var vehiclesArray = [Vehicle]()
    var token: Token?
    var planetsArray = [Planet]()
    static let allowedPlanetSelectionCount = 4
    var selectedPlanetArray = [Int : Planet]()
    var selectedVehicleArray = [Int : Vehicle]()
    lazy var footerButton: UIButton = {
        let footerButton = UIButton(frame: CGRect(x: 0, y: 0, width: 140, height: 40))
        return footerButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        invokeApis()
        configureUi()
        self.navigationItem.title = "Find Falcone"
        
        let footerView = UIView(frame: CGRect(x: 120, y: 110, width: 150, height: 40))

        footerButton.setTitle("Find Falcone", for: .normal)
        footerButton.setTitleColor(UIColor.blue, for: .normal)
        footerButton.layer.borderColor = UIColor.darkGray.cgColor
        footerButton.layer.borderWidth = 1
        footerButton.addTarget(self, action: #selector(findFalconeButtonTapped), for: .touchUpInside)
        footerButton.isEnabled = false
        footerView.addSubview(footerButton)
        tableView.tableFooterView = footerView
        footerButton.layer.cornerRadius = 8
    }

    @objc func findFalconeButtonTapped() {
        SVProgressHUD.show()
        getToken()
    }

    func getToken() {
        api.getToken(successHandler: { (successResponse, _) in
            if let successResponse = successResponse {
                do {
                    let token = try JSONDecoder().decode(Token.self, from: (successResponse as? Data)!)
                    self.token = token
                    self.findFalconeApi(token: token.token!)
                } catch {
                    print(error)
                    SVProgressHUD.dismiss()
                }
            }
        }, failureHandler: { (_,_) in
            //Failure
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
        
        let encoder = JSONEncoder()
        var data: Data
        do {
            data = try encoder.encode(request)
        } catch {
            print(error)
            SVProgressHUD.dismiss()
            return
        }
        api.findFalcone(data: data, successHandler: { (successResponse, _) in
            SVProgressHUD.dismiss()
            if let successResponse = successResponse {
                do {
                    let response = try JSONDecoder().decode(FindFalconeResponse.self, from: (successResponse as? Data)!)
                    if response.status == "success" {
                        DispatchQueue.main.async {
                            self.showSuccessViewController(response: response)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.showFailureViewController()
                        }
                    }
                } catch {
                    print(error)
                }
            }
        }, failureHandler: { (_,_) in
            //Failure
            SVProgressHUD.dismiss()
        })
    }
    
    func showSuccessViewController(response: FindFalconeResponse) {
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SuccessViewController") as? SuccessViewController {
            viewController.response = response
            viewController.success = true
            viewController.timeTaken =  String(getTimeTaken())
            if let navigator = self.navigationController {
                navigator.pushViewController(viewController, animated: true)
            } else{
                let navigation  = UINavigationController(rootViewController:viewController)
                self.present(navigation, animated: true, completion: nil)
            }
        }
    }
    
    func showFailureViewController() {
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SuccessViewController") as? SuccessViewController {
            viewController.success = false
            viewController.timeTaken =  String(getTimeTaken())
            if let navigator = self.navigationController {
                navigator.pushViewController(viewController, animated: true)
            } else{
                let navigation  = UINavigationController(rootViewController:viewController)
                self.present(navigation, animated: true, completion: nil)
            }
        }
    }
    
    func invokeApis() {
        SVProgressHUD.show()
        getPlanets()
        getVehicles()
    }
    
    func configureUi() {
        tableView.estimatedRowHeight = 100
        tableView.delegate = self
        tableView.dataSource = self
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
                        self.tableView.reloadData()
                    }
                } catch {
                    print(error)
                }
            }
        }, failureHandler: { (_,_) in
            //Failure
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
                        self.tableView.reloadData()
                    }
                } catch {
                    print(error)
                }
            }
        }, failureHandler: { (_,_) in
            //Failure
            SVProgressHUD.dismiss()
        })
    }
}

extension FalconeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedPlanetArray[section] != nil {
            return vehiclesArray.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 16
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "VehicleSelectionTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? VehicleSelectionTableViewCell  else {
            return UITableViewCell()
        }
        let vehicle = vehiclesArray[indexPath.row]
        let planet = selectedPlanetArray[indexPath.section]
        let name = vehicle.name ?? ""
        //let number = String(vehicle.totalNumber ?? 0)
        let vehicleCount = getVehicleCount(vehicle: vehicle, row: indexPath.row, section: indexPath.section)
        let vehicleSelected = selectedVehicleArray[indexPath.section]
        let selected = vehicle.name == vehicleSelected?.name
        cell.configure(selected: selected,
                       text: name + " (" + String(vehicleCount) + ")",
                       indexPath: indexPath, delegate: self)
        if !canVehicleBeUsed(vehicle: vehicle, planet: planet) || vehicleCount == 0 {
            cell.backgroundColor = UIColor.hexStringToUIColor(hex: "C0C0C0")
            cell.isUserInteractionEnabled = false
        } else {
            cell.backgroundColor = UIColor.white
            cell.isUserInteractionEnabled = true
        }
        cell.delegate = self
        
        
        return cell
    }
    
    func getTimeTaken() -> Int {
        var timeTaken = 0
        for (_, value) in selectedPlanetArray.enumerated() {
            let section = value.key
            let planet = value.value
            let vehicle = selectedVehicleArray[section]
            if vehicle != nil {
                let speed = vehicle?.speed!
                let distance = planet.distance!
                let time = distance / speed!
                timeTaken += time
            }
        }
        return timeTaken
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        return planetsArray.count == 0  ? 0 : FalconeViewController.allowedPlanetSelectionCount
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let label = UILabel()
        let selectedPlanet = selectedPlanetArray[section]
        if selectedPlanet != nil {
            label.text = selectedPlanet?.name
        } else {
            label.text = "Select Vehicle"
        }
        view.frame = CGRect(x: 16, y: 0, width: UIScreen.main.bounds.width, height: 40)
        label.frame = CGRect(x: 110, y: 0, width: 140, height: 40)
        let  gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showDirectionPopup))
        label.textAlignment = .center
        label.addGestureRecognizer(gestureRecognizer)
        label.tag = section
        view.isUserInteractionEnabled = true
        label.isUserInteractionEnabled = true
        view.addSubview(label)
        
        let image = UIImage(named: "down-arrow")
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 246, y: 12,
                                 width: 18, height: 18)
        view.addSubview(imageView)
        view.backgroundColor = UIColor.white
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1.0
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.didSelectRow(indexPath: indexPath)
    }
    
    func didSelectRow(indexPath: IndexPath) {
        let vehicle = vehiclesArray[indexPath.row]
        selectedVehicleArray[indexPath.section] = vehicle
        self.tableView.reloadData()
        self.updateTimeTakenLabel()
        tableView.deselectRow(at: indexPath, animated: true)
        if selectedPlanetArray.count == 4 {
            footerButton.isEnabled = true
        } else {
            footerButton.isEnabled = false
        }
    }
    
    func updateTimeTakenLabel() {
        let timeTaken = getTimeTaken()
        timeTakenLabel.text = "Time Taken: " + String(timeTaken)
    }
    
    @objc func showDirectionPopup(_ sender: UITapGestureRecognizer) {
        
        let tag = sender.view?.tag
        
        let controller = ArrayChoiceTableViewController(planetsArray, labels: { (planet: Planet) -> String in
            return planet.name ?? ""
        }, onSelect: { (planet) in
            print("")
            if self.isPlanetAlreadySelected(planet) {
                self.showAlert(message: "Cannot select the same planet")
                return
            }
            self.selectedPlanetArray[tag!] = planet
            self.selectedVehicleArray.removeValue(forKey: tag!)
            self.tableView.reloadData()
            self.updateTimeTakenLabel()
        })
        controller.preferredContentSize = CGSize(width: UIScreen.main.bounds.width,
                                                 height: 300)
        showPopup(controller, sourceView: sender.view!)
    }
    
    func isPlanetAlreadySelected(_ selectedPlanet: Planet) -> Bool {
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
    
    func canVehicleBeUsed(vehicle: Vehicle, planet: Planet?) -> Bool {
        guard let planet = planet else {
            return true
        }
        return planet.distance! <= vehicle.maxDistance!
    }
    
    private func showPopup(_ controller: UIViewController, sourceView: UIView) {
        let presentationController = AlwaysPresentAsPopover.configurePresentation(forController: controller)
        presentationController.sourceView = sourceView
        presentationController.sourceRect = sourceView.bounds
        presentationController.permittedArrowDirections = [.down, .up]
        self.present(controller, animated: true)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(okayAction)
        self.present(alert, animated: true, completion: nil)
    }
}

class TestData {
    
    var vehicles = [Vehicle]()
    var planets = [Planet]()
    
    init() {
        let vehicleOne = Vehicle(name: "Space pod", totalNumber: 2,
                                 speed: 2, maxDistance: 200)
        
        let vehicleTwo = Vehicle(name: "Space rocket", totalNumber: 1, speed: 4,
                                 maxDistance: 300)
        
        let vehicleThree = Vehicle(name: "Space shuttle", totalNumber: 1,
                                   speed: 5, maxDistance: 400)
        
        let vehicleFour = Vehicle(name: "Space ship", totalNumber: 2,
                                 speed: 10, maxDistance: 600)
        
        vehicles.append(vehicleOne)
        vehicles.append(vehicleTwo)
        vehicles.append(vehicleThree)
        vehicles.append(vehicleFour)
        
        let planetOne = Planet(name: "Donlon", distance: 100)
        let planetTwo = Planet(name: "Enchai", distance: 200)
        let planetThree = Planet(name: "Jebing", distance: 300)
        let planetFour = Planet(name: "Sapir", distance: 400)
        let planetFive = Planet(name: "Lerbin", distance: 500)
        let planetSix = Planet(name: "Pingasor", distance: 600)
        
        planets.append(planetOne)
        planets.append(planetTwo)
        planets.append(planetThree)
        planets.append(planetFour)
        planets.append(planetFive)
        planets.append(planetSix)
    }
    
}

extension FalconeViewController: VehicleSelectionCellDelegate {
    
    func onButtonClicked(indexPath: IndexPath) {
        self.didSelectRow(indexPath: indexPath)
    }
}

extension UIColor {
    class func hexStringToUIColor (hex: String) -> UIColor {
        var string = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (string.hasPrefix("#")) {
            string.remove(at: string.startIndex)
        }
        
        if ((string.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue: UInt32 = 0
        Scanner(string: string).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
