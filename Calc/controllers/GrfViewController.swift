//
//  GrfViewController.swift
//  Calc
//
//  Created by Dzmitry Herasiuk on 11.12.2018.
//  Copyright © 2018 Dzmitry Herasiuk. All rights reserved.
//

import UIKit

class GrfViewController: UIViewController {

    private struct Grf {
        static let scaleKey = "GrfViewController.Key.scale"
        static let origenKey = "GrfViewController.Key.origen"
    }
    
    private let defaults = UserDefaults.standard
    
    private var scale: Double {
        get { return Double(grfView?.scale ?? 100) }
        set { grfView.scale = CGFloat(newValue) }
    }
    private var origen: CGPoint {
        get { return grfView?.origenGrf ?? CGPoint(x: view.bounds.midX, y: view.bounds.midY)}
        set { grfView.origenGrf = newValue }
    }
    
    @IBOutlet weak var grfView: GrfView! {
        didSet {
            grfView.addGestureRecognizer(UIPinchGestureRecognizer(target: grfView, action: #selector(grfView.changeScale(_:))))
            grfView.datasource = self
            
            scale = defaults.object(forKey: Grf.scaleKey) as? Double ?? 0
            if let origenPresentation = defaults.object(forKey: Grf.origenKey) as? NSDictionary {
                origen = CGPoint(dictionaryRepresentation: origenPresentation) ?? CGPoint(x: grfView.frame.midX, y: grfView.frame.midY)
            }
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super .viewWillDisappear(animated)
        
        if grfView != nil {
            defaults.set(scale, forKey: Grf.scaleKey)
            defaults.set(origen.dictionaryRepresentation, forKey: Grf.origenKey)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super .viewWillTransition(to: size, with: coordinator)
        print ("viewWillTransition", size)
        origen = CGPoint(x: size.width / 2, y: (size.height / 2))
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print ("viewDidLayoutSubviews")
        print (view.frame)
        print (grfView.frame)
    }
}

extension GrfViewController: GrfViewDatasource {
    
    func getYfor(x: CGFloat) -> CGFloat? {
        brain.setVariable("M", value: Double(x))
        guard let y = brain.evaluate(), y.isNormal || y.isZero  else { return nil }
        return CGFloat(y)
    }
}
