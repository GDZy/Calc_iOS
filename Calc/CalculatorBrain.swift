//
//  CalculatorBrain.swift
//  Calc
//
//  Created by Dzmitry Herasiuk on 09.10.2018.
//  Copyright © 2018 Dzmitry Herasiuk. All rights reserved.
//

import Foundation

class CalculatorBrain: CustomStringConvertible {
    
    private enum Op: CustomStringConvertible {
        case operand (Double)
        case variable (String)
        case constantOperation (String, () -> (Double))
        case unaryOperation (String, (Double) -> (Double))
        case binaryOperation (String, Int, Bool, (Double, Double) -> (Double))
        
        var description: String {
            switch self {
            case .operand(let operand):
                return "\(operand)"
            case .variable(let symbol):
                return symbol
            case .constantOperation(let symbol, _):
                return symbol
            case .unaryOperation(let symbol, _):
                return symbol
            case .binaryOperation(let symbol, _,_, _):
                return symbol
            }
        }
        
        var precedence: Int {
            switch self {
            case .binaryOperation(_, let precedence, _, _):
                return precedence
            default:
                return Int.max
            }
        }
        
        var commutative: Bool {
            switch self {
            case .binaryOperation(_, _, let commutative, _):
                return commutative
            default:
                return false
            }
        }
        
    }
    
    private var stackOp = [Op] ()
    private var knowOperations = [String: Op] ()
    private var variableValues = [String: Double] ()
    
    func getVariable(name: String) -> Double? {
        return variableValues[name]
    }
    
    func setVariable(_ symbol: String, value: Double) {
        variableValues[symbol] = value
    }
    
    func clearVariables() {
        variableValues.removeAll()
    }
    
    var description: String {
        let (descriptionOp, _) = resultDescription(ops: stackOp)
        return descriptionOp
    }
    
    init() {
        func learnOperation(_ operation: Op) {
            knowOperations[operation.description] = operation
        }
        
        learnOperation(Op.binaryOperation("+", 1, false, { $0 + $1 }))
        learnOperation(Op.binaryOperation("-", 1, true, { $1 - $0 }))
        learnOperation(Op.binaryOperation("×", 2, false, { $0 * $1 }))
        learnOperation(Op.binaryOperation("÷", 2, true, { $1 / $0 }))
        learnOperation(Op.unaryOperation("sin", { sin($0) }))
        learnOperation(Op.unaryOperation("cos", { cos($0) }))
        learnOperation(Op.unaryOperation("sqrt", { sqrt($0) }))
        learnOperation(Op.unaryOperation("±", { -$0 }))
        learnOperation(Op.constantOperation("𝜋", { .pi }))
    }
    
    func clearStack() {
        stackOp.removeAll()
    }
    
    func clearAll() {
        clearStack()
        clearVariables()
    }
    
    func popStack() -> Double? {
        if !stackOp.isEmpty {
            stackOp.removeLast()
            return evaluate()
        }
        return nil
    }
    
    func pushOperand (_ operand: Double) -> Double?{
        stackOp.append(Op.operand(operand))
        return evaluate()
    }
    
    func pushOperand(_ symbol: String) -> Double? {
        stackOp.append(Op.variable(symbol))
        return evaluate()
    }
    
    func performOperation (_ symbol: String) -> Double?{
        if let operation = knowOperations[symbol] {
            stackOp.append(operation)
        }
        return evaluate()
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(ops: stackOp)
        print("\(stackOp) = \(String(describing: result)) with \(remainder) left over, \(variableValues)")
        print(description)
        return result
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remain: [Op]) {
        var remainingOp = ops
        
        if !remainingOp.isEmpty {
            let op = remainingOp.removeLast()
            switch op {
            case .operand(let operand):
                return (operand, remainingOp)
            case .variable(let symbol):
                if let value = variableValues[symbol] {
                    return (value, remainingOp)
                }
            case .constantOperation(_, let operation):
                return (operation(), remainingOp)
            case .unaryOperation(_, let operation):
                let operandEvaluation = evaluate(ops: remainingOp)
                if let operadn = operandEvaluation.result {
                    return (operation(operadn), operandEvaluation.remain)
                }
            case .binaryOperation(_, _, _, let operation):
                let op1Evaluation = evaluate(ops: remainingOp)
                let op2Evaluation = evaluate(ops: op1Evaluation.remain)
                if let op1 = op1Evaluation.result, let op2 = op2Evaluation.result {
                    return (operation(op1, op2), op2Evaluation.remain)
                }
            }
        }
        return (nil, remainingOp)
    }

    private func resultDescription(ops: [Op]) -> (result: String, remain: [Op]) {
        var (bitDescription, remain, _) = description(ops: ops)
        bitDescription = bitDescription == "?" ? "" : bitDescription
        
        if !remain.isEmpty {
            let (currentDescription, currentRemain) = resultDescription(ops: remain)
            return ("\(currentDescription), \(bitDescription)", currentRemain)
        }
        return (bitDescription, remain)
    }
    
    
    private func description(ops: [Op]) -> (result: String, remain: [Op], precedence: Int) {
        var remainingOp = ops
        if !remainingOp.isEmpty {
            let op = remainingOp.removeLast()
            switch op {
            case .operand, .variable, .constantOperation:
                return (op.description, remainingOp, op.precedence)
            case .unaryOperation:
                let operandEvaluated = description(ops: remainingOp)
                let text = op.description + "(\(operandEvaluated.result))"
                return(text, operandEvaluated.remain, op.precedence)
            case .binaryOperation:
                var (op1Result, op1Remain, op1Precedenc ) = description(ops: remainingOp)
                if (op.precedence > op1Precedenc && op.commutative) || (op.precedence == op1Precedenc && op.commutative) {
                    op1Result = "(\(op1Result))"
                }
                
                var (op2Result, op2Remain, op2Precedenc ) = description(ops: op1Remain)
                if op.precedence > op2Precedenc {
                    op2Result = "(\(op2Result))"
                }
                let text = op2Result + " \(op.description) " + op1Result
                return (text, op2Remain, op.precedence)
            }
        }
        return ("?", remainingOp, Int.max)
    }
}

class CalculatorFormatter: NumberFormatter {
    
    static let sharedInstanse =  CalculatorFormatter()
    
    override init() {
        super.init()
        self.locale = NSLocale.current
        self.numberStyle = .decimal
        self.maximumIntegerDigits = 10
        self.notANumberSymbol = "Error"
        self.groupingSeparator = " "
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}

