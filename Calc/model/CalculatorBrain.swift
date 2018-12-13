//
//  CalculatorBrain.swift
//  Calc
//
//  Created by Dzmitry Herasiuk on 09.10.2018.
//  Copyright © 2018 Dzmitry Herasiuk. All rights reserved.
//

import Foundation

class CalculatorBrain: CustomStringConvertible {
    
    struct CalculatorConstant {
        static let programKey = "CalculatorBrain.CalculatorConstant.ProgramKey"
        static let variablesKey = "CalculatorBrain.CalculatorConstant.VariablesKey"
    }
    
    enum Result: CustomStringConvertible {
        case Value (Double)
        case Error (String)
        
        var description: String {
            switch self {
            case .Value(let value):
                return CalculatorFormatter.sharedInstanse.string(from: NSNumber(value: value)) ?? ""
            case .Error(let errorDescription):
                return errorDescription
            }
        }
    }
    
    private enum Op: CustomStringConvertible {
        case operand (Double)
        case variable (String)
        case constantOperation (String, () -> Double)
        case unaryOperation (String, (Double) -> Double, ((Double) -> Result?)?)
        case binaryOperation (String, Int, Bool, (Double, Double) -> Double, ((Double, Double) -> Result?)?)
        
        var description: String {
            switch self {
            case .operand(let operand):
                return "\(operand)"
            case .variable(let symbol):
                return symbol
            case .constantOperation(let symbol, _):
                return symbol
            case .unaryOperation(let symbol, _, _):
                return symbol
            case .binaryOperation(let symbol, _, _, _, _):
                return symbol
            }
        }
        
        var precedence: Int {
            switch self {
            case .binaryOperation(_, let precedence, _, _, _):
                return precedence
            default:
                return Int.max
            }
        }
        
        var commutative: Bool {
            switch self {
            case .binaryOperation(_, _, let commutative, _, _):
                return commutative
            default:
                return false
            }
        }
        
    }
    let defaultStorage = UserDefaults()
    
    private var stackOp = [Op] ()
    private var knowOperations = [String: Op] ()
    private var variableValues = [String: Double] ()
    private var variableName: String = ""
    
    var description: String {
        let (descriptionOp, _) = resultDescription(ops: stackOp)
        return descriptionOp
    }
    
    init() {
        func learnOperation(_ operation: Op) {
            knowOperations[operation.description] = operation
        }
        
        learnOperation(Op.binaryOperation("+", 1, false, { $0 + $1 }, nil))
        learnOperation(Op.binaryOperation("-", 1, true, { $1 - $0 }, nil))
        learnOperation(Op.binaryOperation("×", 2, false, { $0 * $1 }, nil))
        learnOperation(Op.binaryOperation("÷", 2, true, { $1 / $0 }, { devider, _ in return devider == 0 ? .Error("dividing by zero") : nil }))
        learnOperation(Op.unaryOperation("sin", { sin($0) }, nil))
        learnOperation(Op.unaryOperation("cos", { cos($0) }, nil))
        learnOperation(Op.unaryOperation("sqrt", { sqrt($0) }, { $0 < 0 ? .Error("sqrt from negative number") : nil}))
        learnOperation(Op.unaryOperation("±", { -$0 }, nil))
        learnOperation(Op.constantOperation("𝜋", { .pi }))
    }

    func saveProgram() {
        let presentationProgram = stackOp.map {$0.description}
        defaultStorage.set(presentationProgram, forKey: CalculatorConstant.programKey)
        defaultStorage.set(variableValues, forKey: CalculatorConstant.variablesKey)
        
    }
    
    func restoreProgram() {
        var mirrorStackOp = [Op]()
        guard let presentationStackOp = defaultStorage.object(forKey: CalculatorConstant.programKey) as? Array<String> else { return }
        for descriptionOp in presentationStackOp {
            if let op = knowOperations[descriptionOp] {
                mirrorStackOp.append(op)
            } else if let operand = CalculatorFormatter.sharedInstanse.number(from: descriptionOp)?.doubleValue {
                mirrorStackOp.append(Op.operand(operand))
            } else {
                variableName = descriptionOp
                mirrorStackOp.append(Op.variable(descriptionOp))
            }
        }
        stackOp = mirrorStackOp
        
        guard let presentationVariable = defaultStorage.object(forKey: CalculatorConstant.variablesKey) as? [String: Double] else { return }
        variableValues = presentationVariable
    }
    
    func getVariable(name: String) -> Result {
        if let variable = variableValues[name] {
            return .Value(variable)
        }
        return .Error("variable is missing")
    }
    
    func setVariable(_ symbol: String, value: Double) {
        variableValues[symbol] = value
    }
    
    func clearVariables() {
        variableValues.removeAll()
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
    
    func pushOperand (_ operand: Double) -> Result {
        stackOp.append(Op.operand(operand))
        return evaluateAndReportError()
    }

    func pushOperand (_ symbol: String) -> Double? {
        stackOp.append(Op.variable(symbol))
        return evaluate()
    }
    
    func pushOperand (_ symbol: String) -> Result {
        stackOp.append(Op.variable(symbol))
        return evaluateAndReportError()
    }
    
    func performOperation (_ symbol: String) -> Double?{
        if let operation = knowOperations[symbol] {
            stackOp.append(operation)
        }
        return evaluate()
    }
    
    func performOperation (_ symbol: String) -> Result {
        if let operation = knowOperations[symbol] {
            stackOp.append(operation)
        }
        return evaluateAndReportError()
    }
    
    func evaluateAndReportError() -> Result {
        if !stackOp.isEmpty {
            let (result, remainder) = evaluateAndReportError(ops: stackOp)
            print("\(stackOp) = \(String(describing: result)) with \(remainder) left over, \(variableValues)")
            return result
        }
        
        return .Value(0.0)
    }
    
    private func evaluateAndReportError(ops: [Op]) -> (result: Result, remain: [Op]) {
        var remainingOps = ops
        
        if !remainingOps.isEmpty {
            
            let op = remainingOps.removeLast()
            switch op {
            case .operand(let value):
                return (.Value(value), remainingOps)
          
            case .variable(let sign):
                return (getVariable(name: sign), remainingOps)
            
            case .constantOperation(_, let operation):
                return (.Value(operation()), remainingOps)
            
            case .unaryOperation(_, let operation, let testOperation):
                let operandEvaluated = evaluateAndReportError(ops: remainingOps)
              
                switch operandEvaluated.result {
                case .Value(let operand):
                    if let errorOperation = testOperation?(operand) {
                        return (errorOperation, operandEvaluated.remain)
                    }
                    return (.Value(operation(operand)), operandEvaluated.remain)
                case .Error:
                    return (operandEvaluated.result, operandEvaluated.remain)
                }
          
            case .binaryOperation(_, _, _, let operation, let operationTest):
                let op1Evaluation = evaluateAndReportError(ops: remainingOps)
                switch op1Evaluation.result {
                case .Value(let op1):
                    let op2Evaluation = evaluateAndReportError(ops: op1Evaluation.remain)
                    switch op2Evaluation.result {
                    case .Value(let op2):
                        if let operationError = operationTest?(op1, op2) {
                            return (operationError, op2Evaluation.remain)
                        }
                        return (.Value(operation(op1, op2)), op2Evaluation.remain)
                    case .Error:
                        return (op2Evaluation.result, op2Evaluation.remain)
                    }
                case .Error:
                    return (op1Evaluation.result, op1Evaluation.remain)
                }
            }
        }
        return (.Error("operand is missed"), ops)
    }
    
    func evaluateFor(variableValue: Double) -> Double? {
        setVariable(variableName, value: variableValue)
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
            case .unaryOperation(_, let operation, _):
                let operandEvaluation = evaluate(ops: remainingOp)
                if let operadn = operandEvaluation.result {
                    return (operation(operadn), operandEvaluation.remain)
                }
            case .binaryOperation(_, _, _, let operation, _):
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

