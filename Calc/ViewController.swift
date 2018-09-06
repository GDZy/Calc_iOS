//
//  ViewController.swift
//  Calc
//
//  Created by Dzmitry Herasiuk on 13.08.2018.
//  Copyright © 2018 Dzmitry Herasiuk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var dysplay: UILabel!
    var userIsInTheTypingOfMiddleANumber: Bool = false
    var operandStack = Array<Double>()
    var dysplayValue: Double {
        set {
            userIsInTheTypingOfMiddleANumber = false
            dysplay.text = "\(newValue)"
        }
        get {
            return NumberFormatter().number(from: dysplay.text!)!.doubleValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func appdendDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheTypingOfMiddleANumber {
            dysplay.text = dysplay.text! + digit
        } else {
            dysplay.text = digit
            userIsInTheTypingOfMiddleANumber = true
        }
    }
    
    @IBAction func enter() {
        userIsInTheTypingOfMiddleANumber = false
        operandStack.append(dysplayValue)
        print("stack = \(operandStack)")
    }
}

