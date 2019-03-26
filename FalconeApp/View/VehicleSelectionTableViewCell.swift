//
//  VehicleSelectionTableViewCell.swift
//  FalconeApp
//
//  Created by praveen on 3/2/19.
//  Copyright © 2019 hmm. All rights reserved.
//

import UIKit
import Foundation

protocol VehicleSelectionCellDelegate: class {
    func onButtonClicked(indexPath: IndexPath)
}

class VehicleSelectionTableViewCell: UITableViewCell {
 
    @IBOutlet weak var vehicleNameLabel: UILabel!
    @IBOutlet weak var selectedButton: UIButton!
    weak var delegate: VehicleSelectionCellDelegate?
    var indexPath: IndexPath?

    func configure(selected: Bool, text: String, indexPath: IndexPath,
                   delegate: VehicleSelectionCellDelegate) {
        self.vehicleNameLabel.text = text
        let image = selected ? UIImage(named: "checked") : UIImage(named: "unchecked")
        self.selectedButton.setImage(image, for: .normal)
        self.delegate = delegate
        self.indexPath = indexPath
        self.selectedButton.addTarget(self,
                                      action: #selector(onVehicleSelected),
                                      for: .touchUpInside)
    }
    
    @objc func onVehicleSelected() {
        if let indexPath = self.indexPath {
            self.delegate?.onButtonClicked(indexPath: indexPath)
        }
    }
}
