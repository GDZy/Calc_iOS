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
    
    private lazy var program: CalculatorBrain = {
        let _program = CalculatorBrain()
        _program.restoreProgram()
        return _program
    }()
}

extension GrfViewController: GrfViewDatasource {
    
    func getYfor(x: CGFloat) -> CGFloat? {
        guard let y = program.evaluateFor(variableValue: Double(x)) else { return nil }
        return CGFloat(y)
    }
}
