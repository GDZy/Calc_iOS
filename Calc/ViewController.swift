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
    }
    
    var dysplayResult: CalculatorBrain.Result = .Value(0.0) {
        didSet {
            dysplay.text = dysplayResult.description
                
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
        if userIsInTheTypingOfMiddleANumber {
            if dysplay.text!.count > 1 {
                dysplay.text = String((dysplay.text?.dropLast())!)
            } else {
                dysplay.text = "0"
            }
        } else {
            let _ = brain.popStack()
            dysplayResult = brain.evaluateAndReportError()
        }
    }
    
    @IBAction func operate(_ sender: UIButton) {
        if userIsInTheTypingOfMiddleANumber {
            enter()
        }
        let operation = sender.currentTitle!
        dysplayResult = brain.performOperation(operation)
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
            dysplayResult = brain.pushOperand(value)
        } else {
            dysplayResult = brain.evaluateAndReportError()
        }
    }
    
    @IBAction func reset(_ sender: UIButton) {
        brain.clearAll()
        dysplayResult = brain.evaluateAndReportError()
    }
    
    @IBAction func setValueVariable(_ sender: UIButton) {
        if let value = dysplayValue, let symbol = sender.currentTitle?.dropFirst() {
            brain.setVariable(String(symbol), value: value)
            
            dysplayResult = brain.evaluateAndReportError()
        }
    }
    
    @IBAction func pushVariable(_ sender: UIButton) {
        if userIsInTheTypingOfMiddleANumber {
            enter()
        }
        dysplayResult = brain.pushOperand(sender.currentTitle!)
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
