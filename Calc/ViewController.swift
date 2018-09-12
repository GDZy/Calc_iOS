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
            dysplay.text = "\(newValue)"
            userIsInTheTypingOfMiddleANumber = false
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
    
    @IBAction func operate(_ sender: UIButton) {
        if userIsInTheTypingOfMiddleANumber {
            enter()
        }
        let operation = sender.currentTitle!
        switch operation {
        case "×": preformOperation { $0 * $1 }
        case "÷": preformOperation { $1 / $0 }
        case "+": preformOperation { $0 + $1 }
        case "-": preformOperation { $1 - $0 }
        case "√": preformOperation { sqrt($0) }
        default:
            break
        }
        
    }
    
    private func preformOperation(operation: (Double, Double) -> Double)  {
        if operandStack.count >= 2 {
            dysplayValue = operation(operandStack.removeLast(), operandStack.removeLast())
            enter()
        }
    }
    
    private func preformOperation(operation: (Double) -> Double) {
        if operandStack.count >= 1 {
            dysplayValue = operation(operandStack.removeLast())
            enter()
        }
    }
    
    @IBAction func enter() {
        userIsInTheTypingOfMiddleANumber = false
        operandStack.append(dysplayValue)
        print("stack = \(operandStack)")
    }
}

