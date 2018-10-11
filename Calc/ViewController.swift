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
            decimalSeparator.setTitle(numberFormatter().decimalSeparator, for: .normal)
        }
    }
    
    var userIsInTheTypingOfMiddleANumber: Bool = false
    var brain = CalculatorBrain()
    var dysplayValue: Double? {
        get {
            if let text = dysplay.text {
                return numberFormatter().number(from: text)?.doubleValue
            }
            return nil
        }
        set {
            if newValue == nil {
                dysplay.text = " "
                addHistory(text: "Error")
            } else {
                dysplay.text = NSNumber(value: newValue!).stringValue
            }
            userIsInTheTypingOfMiddleANumber = false
            history.text = brain.dysplayStack() ?? " "
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
        
        addHistory(text: operation)
        addHistory(text: "=")
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
        addHistory(text: dysplay.text!)
        
        userIsInTheTypingOfMiddleANumber = false
        
        if let value = dysplayValue {
            dysplayValue = brain.pushOperand(value)
        } else {
            dysplayValue = nil
        }
    }
    
    @IBAction func reset(_ sender: UIButton) {
        brain = CalculatorBrain()
        dysplayValue = nil
        history.text = " "
    }
    
    private func numberFormatter() -> NumberFormatter {
        let numberFormatterLoc = NumberFormatter()
        numberFormatterLoc.numberStyle = .decimal
        numberFormatterLoc.maximumIntegerDigits = 10
        numberFormatterLoc.notANumberSymbol = "Error"
        numberFormatterLoc.groupingSeparator = " "
        return numberFormatterLoc
    }
    
    private func addHistory(text: String) {
//        if history.text?.last == "=" {
//            history.text?.removeLast()
//        }
//
//        history.text? += " " + text
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
