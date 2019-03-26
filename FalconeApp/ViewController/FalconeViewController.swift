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

    let api = FalconeApi(serviceManager: ServiceManager())

    lazy var footerButton: UIButton = {
        let footerButton = UIButton(frame: CGRect(x: 0, y: 0, width: 140, height: 40))
        return footerButton
    }()

    var presenter: FalconeViewPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter = FalconeViewPresenter(api: api,
                                              falconeViewDelegate: self)
        presenter.onViewLoaded()
        configureUi()
        self.navigationItem.title = Constants.findFalcone

        let footerView = buildFindButtonView()
        tableView.tableFooterView = footerView
    }
    
    func buildFindButtonView() -> UIView {
        let footerView = UIView(frame: CGRect(x: 120, y: 110, width: 150, height: 50))
        footerButton.setTitle(Constants.findFalcone, for: .normal)
        footerButton.setTitleColor(UIColor.blue, for: .normal)
        footerButton.layer.borderColor = UIColor.darkGray.cgColor
        footerButton.layer.borderWidth = 1
        footerButton.addTarget(self, action: #selector(onFindFalconeButtonTapped), for: .touchUpInside)
        footerButton.isEnabled = false
        footerButton.layer.cornerRadius = 8
        footerView.addSubview(footerButton)
        return footerView
    }

    @objc func onFindFalconeButtonTapped() {
        presenter.onFindFalconeButtonTapped()
    }

    func showSuccessViewController(response: FindFalconeResponse) {
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SuccessViewController") as? SuccessViewController {
            viewController.response = response
            viewController.success = true
            viewController.timeTaken =  String(getTimeTaken())
            if let navigator = self.navigationController {
                navigator.pushViewController(viewController, animated: true)
            } else{
                let navigation = UINavigationController(rootViewController:viewController)
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
            } else {
                let navigation  = UINavigationController(rootViewController:viewController)
                self.present(navigation, animated: true, completion: nil)
            }
        }
    }
 
    func configureUi() {
        tableView.estimatedRowHeight = 100
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension FalconeViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let selectedPlanetArray = presenter.getSelectedPlanetArray()
        if selectedPlanetArray[section] != nil {
            return presenter.getVehiclesArray().count
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
        let vehiclesArray = presenter.getVehiclesArray()
        let selectedPlanetArray = presenter.getSelectedPlanetArray()
        let selectedVehicleArray = presenter.getSelectedVehicleArray()
        let vehicle = vehiclesArray[indexPath.row]
        let planet = selectedPlanetArray[indexPath.section]
        let name = vehicle.name ?? ""
        let vehicleCount = self.presenter.getVehicleCount(vehicle: vehicle,
                                                          row: indexPath.row,
                                                          section: indexPath.section)
        let vehicleSelected = selectedVehicleArray[indexPath.section]
        let selected = vehicle.name == vehicleSelected?.name
        cell.configure(selected: selected,
                       text: name + " (" + String(vehicleCount) + ")",
                       indexPath: indexPath, delegate: self)
        if !self.presenter.canVehicleBeUsed(vehicle: vehicle, planet: planet) || vehicleCount == 0 {
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
        let selectedPlanetArray = presenter.getSelectedPlanetArray()
        let selectedVehicleArray = presenter.getSelectedVehicleArray()
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
        let planetsArray = presenter.getPlanetsArray()
        return planetsArray.count == 0  ? 0 : FalconeViewPresenter.allowedPlanetSelectionCount
    }

    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        let view = buildHeaderView()
        let label = buildPlanetNameLabel()
        let imageView = buildArrowImage()
        
        let selectedPlanetArray = presenter.getSelectedPlanetArray()
        let selectedPlanet = selectedPlanetArray[section]
        if selectedPlanet != nil {
            label.text = selectedPlanet?.name
        } else {
            label.text = "Select Vehicle"
        }
        label.tag = section

        view.addSubview(label)
        view.addSubview(imageView)
        return view
    }

    func buildHeaderView() -> UIView {
        let view = UIView()
        view.frame = CGRect(x: 16, y: 0, width: UIScreen.main.bounds.width, height: 40)
        view.isUserInteractionEnabled = true
        view.backgroundColor = UIColor.white
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1.0
        return view
    }
    
    func buildArrowImage() -> UIImageView {
        let image = UIImage(named: "down-arrow")
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 246, y: 12,
                                 width: 18, height: 18)
        return imageView
    }
    
    func buildPlanetNameLabel() -> UILabel {
        let label = UILabel()
        label.frame = CGRect(x: 110, y: 0, width: 140, height: 40)
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showDirectionPopup))
        label.textAlignment = .center
        label.addGestureRecognizer(gestureRecognizer)
        label.isUserInteractionEnabled = true
        return label
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.didSelectRow(indexPath: indexPath)
    }

    func didSelectRow(indexPath: IndexPath) {
        let selectedPlanetArray = presenter.getSelectedPlanetArray()
        let vehiclesArray = presenter.getVehiclesArray()
        
        let vehicle = vehiclesArray[indexPath.row]
        presenter.updateSelectedVehicleArray(key: indexPath.section, value: vehicle)
        
        self.tableView.reloadData()
        self.updateTimeTakenLabel()
        tableView.deselectRow(at: indexPath, animated: true)
        footerButton.isEnabled = (selectedPlanetArray.count == 4)
    }

    func updateTimeTakenLabel() {
        let timeTaken = getTimeTaken()
        timeTakenLabel.text = "Time Taken: " + String(timeTaken)
    }

    @objc func showDirectionPopup(_ sender: UITapGestureRecognizer) {
        let tag = sender.view?.tag
        let planetsArray = presenter.getPlanetsArray()
        let controller = ArrayChoiceTableViewController(planetsArray, labels: { (planet: Planet) -> String in
            return planet.name ?? ""
        }, onSelect: { (planet) in
            print("")
            if self.presenter.isPlanetAlreadySelected(planet) {
                self.showAlert(message: "Cannot select the same planet")
                return
            }
            
            self.presenter.updateSelectedPlanetArray(key: tag!, value: planet)
            self.presenter.removeSelectedVehicle(key: tag!)
            
            self.tableView.reloadData()
            self.updateTimeTakenLabel()
        })
        controller.preferredContentSize = CGSize(width: UIScreen.main.bounds.width,
                                                 height: 300)
        showPopup(controller, sourceView: sender.view!)
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

extension FalconeViewController: VehicleSelectionCellDelegate {
    
    func onButtonClicked(indexPath: IndexPath) {
        self.didSelectRow(indexPath: indexPath)
    }
}

extension FalconeViewController: FalconeViewDelegate {

    func onFindFalconeSuccess(response: FindFalconeResponse) {
        self.showSuccessViewController(response: response)
    }

    func onFindFalconeFailure() {
        self.showFailureViewController()
    }

    func reloadView() {
        self.tableView.reloadData()
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

        return UIColor(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                       green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                       blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                       alpha: CGFloat(1.0)
        )
    }
}


