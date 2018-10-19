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
    @IBOutlet weak var history: UILabel!
    @IBOutlet weak var decimalSeparator: UIButton! {
        didSet {
            decimalSeparator.setTitle(CalculatorFormatter.sharedInstanse.decimalSeparator ?? ".", for: .normal)
        }
    }
    
    var userIsInTheTypingOfMiddleANumber: Bool = false
    var brain = CalculatorBrain()
    var dysplayValue: Double? {
        get {
            if let text = dysplay.text {
                return CalculatorFormatter.sharedInstanse.number(from: text)?.doubleValue
            }
            return nil
        }
        set {
            if newValue == nil {
                dysplay.text = " "
            } else {
                dysplay.text = NSNumber(value: newValue!).stringValue
            }
            userIsInTheTypingOfMiddleANumber = false
            history.text = brain.description == "" ? " " : "\(brain.description) ="
        }
    }
    
    @IBAction func appdendDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheTypingOfMiddleANumber {
            if !(digit == decimalSeparator.currentTitle! && (dysplay.text?.contains(decimalSeparator.currentTitle!))!) {
                dysplay.text = dysplay.text! + digit
            }
        } else {
            dysplay.text = digit
            userIsInTheTypingOfMiddleANumber = true
        }
    }
    
    @IBAction func removeLastDigit() {
        dysplay.text = String((dysplay.text?.dropLast())!)
        if dysplay.text == "" {
            dysplay.text = " "
        }
    }
    
    @IBAction func operate(_ sender: UIButton) {
        if userIsInTheTypingOfMiddleANumber {
            enter()
        }
        let operation = sender.currentTitle!
        dysplayValue = brain.performOperation(operation)
    }
    
    @IBAction func changeSignOperate(_ sender: UIButton) {
        if userIsInTheTypingOfMiddleANumber {
            if dysplay.text?.first == "-" {
                dysplay.text?.remove(at: (dysplay.text?.startIndex)!)
            } else {
                dysplay.text = "-" + dysplay.text!
            }
        } else {
            operate(sender)
        }
    }
    
    @IBAction func enter() {
        userIsInTheTypingOfMiddleANumber = false
        
        if let value = dysplayValue {
            dysplayValue = brain.pushOperand(value)
        } else {
            dysplayValue = nil
        }
    }
    
    @IBAction func reset(_ sender: UIButton) {
        brain.clearAll()
        dysplayValue = nil
    }
    
    @IBAction func setValueVariable(_ sender: UIButton) {
        if let value = dysplayValue, let symbol = sender.currentTitle?.dropFirst() {
            brain.setVariable(String(symbol), value: value)
            
            dysplayValue = brain.evaluate()
        }
    }
    
    @IBAction func pushVariable(_ sender: UIButton) {
        if userIsInTheTypingOfMiddleANumber {
            enter()
        }
        dysplayValue = brain.pushOperand(sender.currentTitle!)
    }
}


//extension UIButton {
//    override open func layoutSubviews() {
//        super.layoutSubviews()
//        self.layer.borderColor = UIColor.black.cgColor
//        self.layer.cornerRadius = 3
//        self.layer.borderWidth = 1
//    }
//}
