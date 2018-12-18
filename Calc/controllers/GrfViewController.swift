//
//  GrfViewController.swift
//  Calc
//
//  Created by Dzmitry Herasiuk on 11.12.2018.
//  Copyright © 2018 Dzmitry Herasiuk. All rights reserved.
//

import UIKit

class GrfViewController: UIViewController {

    @IBOutlet weak var grfView: GrfView! {
        didSet {
            grfView.addGestureRecognizer(UIPinchGestureRecognizer(target: grfView, action: #selector(grfView.changeScale(_:))))
            grfView.datasource = self
        }
    }
    
    typealias PropertyList = AnyObject
    var program: PropertyList? {
        didSet {
            brain.program = program
            brain.setVariable("M", value: 0)
            title = brain.description.components(separatedBy: ",").last ?? ""
        }
    }
    
    private let brain = CalculatorBrain()
}

extension GrfViewController: GrfViewDatasource {
    
    func getYfor(x: CGFloat) -> CGFloat? {
        brain.setVariable("M", value: Double(x))
        guard let y = brain.evaluate() else { return nil }
        return CGFloat(y)
    }
}
