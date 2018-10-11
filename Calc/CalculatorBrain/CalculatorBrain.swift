//
//  CalculatorBrain.swift
//  Calc
//
//  Created by Dzmitry Herasiuk on 09.10.2018.
//  Copyright © 2018 Dzmitry Herasiuk. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private enum Op: CustomStringConvertible {
        case operand (Double)
        case variable (String)
        case constantOperation(String, () -> (Double))
        case unaryOperation (String, (Double) -> (Double))
        case binaryOperation (String, (Double, Double) -> (Double))
        
        var description: String {
            switch self {
            case .operand(let operand):
                return "\(operand)"
            case .variable(let symbol):
                return symbol
            case .constantOperation(let symbol, _):
                return symbol
            case .binaryOperation(let symbol, _):
                return symbol
            case.unaryOperation(let symbol, _):
                return symbol
            }
        }
    }
    
    private var stackOp = [Op] ()
    private var knowOps = [String: Op] ()
    var variableValues = [String: Double] ()
    
    init() {
        func addOperation(_ operation: Op) {
            knowOps[operation.description] = operation
        }
        
        addOperation(Op.binaryOperation("+", { $0 + $1 } ))
        addOperation(Op.binaryOperation("-", { $1 - $0 } ))
        addOperation(Op.binaryOperation("*", { $0 + $1 } ))
        addOperation(Op.binaryOperation("/", { $1 / $0 } ))
        addOperation(Op.unaryOperation("sqrt", { $0 } ))
        addOperation(Op.unaryOperation("sin", { sin($0) } ))
        addOperation(Op.unaryOperation("cos", { cos($0) } ))
        addOperation(Op.unaryOperation("±", { -$0 } ))
        addOperation(Op.constantOperation("𝜋", { .pi } ))
    }
        
    func pushOperand (operand: Double) -> Double? {
        stackOp.append(Op.operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        stackOp.append(Op.variable(symbol))
        return evaluate()
    }
    
    func performOperation (symbol: String) -> Double? {
        if let operationOp = knowOps[symbol] {
            stackOp.append(operationOp)
        }
        return evaluate()
    }
    
    private func evaluate() -> Double? {
        let (result, remainderOps) = evaluate(ops: stackOp)
        print("\(stackOp) = \(String(describing: result)) with \(remainderOps) left over")
        return (result)
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .operand(let operand):
                return (operand, remainingOps)
            case .variable(let symbol):
                if let value = variableValues[symbol] {
                    return (value, remainingOps)
                }
            case .constantOperation(_ , let operation):
                return (operation(), remainingOps)
            case .unaryOperation(_, let operation):
                let operandEvaluation = evaluate(ops: remainingOps)
                if let operanad = operandEvaluation.result {
                    return (operation(operanad), operandEvaluation.remainingOps)
                }
            case .binaryOperation(_, let operation):
                let op1Evaluation = evaluate(ops: remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(ops: op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return(operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            }
        }
        return(nil, ops)
    }
    
}
