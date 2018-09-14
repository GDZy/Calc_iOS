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
    @IBOutlet weak var decimalSeparator: UIButton!
    
    var userIsInTheTypingOfMiddleANumber: Bool = false
    var operandStack = Array<Double>()
    var dysplayValue: Double {
        set {
            dysplay.text = numberFormatter().string(from: NSNumber(value: newValue))!
            userIsInTheTypingOfMiddleANumber = false
        }
        get {
            return numberFormatter().number(from: dysplay.text!)!.doubleValue
    
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        decimalSeparator.setTitle(numberFormatter().decimalSeparator, for: .normal)
        dysplayValue = 0
        history.text = " "
        operandStack = []
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
        addHistory(text: operation)
        switch operation {
        case "×": pereformOperation { $0 * $1 }
        case "÷": pereformOperation { $1 / $0 }
        case "+": pereformOperation { $0 + $1 }
        case "-": pereformOperation { $1 - $0 }
        case "sin": pereformOperation { sin($0) }
        case "cos": pereformOperation { cos($0) }
        case "sqrt": pereformOperation { sqrt($0) }
        case "𝜋": performOperation { Double.pi }
        default:
            break
        }
    }
    
    @nonobjc private func performOperation(operation: () -> Double) {
        dysplayValue = operation()
        addStack()
    }
    
    private func pereformOperation(operation: (Double) -> Double) {
        if operandStack.count >= 1 {
            dysplayValue = operation(operandStack.removeLast())
            addStack()
        }
    }
    
    private func pereformOperation(operation: (Double, Double) -> Double)  {
        if operandStack.count >= 2 {
            dysplayValue = operation(operandStack.removeLast(), operandStack.removeLast())
            addStack()
        }
    }
    
    @IBAction func enter() {
        addHistory(text: dysplay.text!)
        
        userIsInTheTypingOfMiddleANumber = false
        
        addStack()
    }
    
    @IBAction func reset(_ sender: UIButton) {
        viewDidLoad()
    }
    
    private func addStack() {
        operandStack.append(dysplayValue)
        print("stack = \(operandStack)")
    }
    
    private func numberFormatter() -> NumberFormatter {
        let numberFormatterLoc = NumberFormatter()
        numberFormatterLoc.numberStyle = .decimal
        numberFormatterLoc.maximumIntegerDigits = 5
        numberFormatterLoc.notANumberSymbol = "Error"
        numberFormatterLoc.groupingSeparator = " "
        return numberFormatterLoc
    }
    
    private func addHistory(text: String) {
        history.text = history.text! + " " + text
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
