//
//  InfoGrfViewController.swift
//  Calc
//
//  Created by Dzmitry Herasiuk on 26.12.2018.
//  Copyright © 2018 Dzmitry Herasiuk. All rights reserved.
//

import UIKit

class InfoGrfViewController: GrfViewController {

    private struct Info {
        static let infoSegueIdentifier = "Show info"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Info.infoSegueIdentifier:
            if let infoVC = segue.destination as? InfoViewController {
                if let ppc = infoVC.popoverPresentationController {
                    ppc.delegate = self
                }
                
                infoVC.minYtext = grfView.info.description
            }
        default:
            break
        }
    }
}

extension InfoGrfViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
