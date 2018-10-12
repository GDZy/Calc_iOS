//
//  CalcTests.swift
//  CalcTests
//
//  Created by Dzmitry Herasiuk on 11.10.2018.
//  Copyright © 2018 Dzmitry Herasiuk. All rights reserved.
//

import XCTest
@testable import Calc

class CalcTests: XCTestCase {
    var brain: CalculatorBrain!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        brain = CalculatorBrain()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
     
        brain = nil
        
        super.tearDown()
    }
    

    func testDescription() {
        // cos(10)
        //given when then
        XCTAssertEqual(brain.pushOperand(10)!, 10)
        XCTAssertTrue(brain.performOperation("cos")! - -0.839 < 0.1 )
    }
    
    func testPushOperandVariable() {
        XCTAssertNil(brain.pushOperand("x"))
        brain.variableValues = ["x": 5.2]
        XCTAssertEqual(5.2, brain.pushOperand("x")!)
        XCTAssertEqual(10.4, brain.performOperation("+")!)
    }
    
    func testDescriptionStack() {
        // cos ↲
        _ = brain.performOperation("cos")
        XCTAssertEqual(brain.description, "cos(?)")
        
        // 3 ↲ 5 sqrt + sqrt 6 ÷
        _ = brain.pushOperand(3)
        _ = brain.pushOperand(5)
        _ = brain.performOperation("sqrt")
        _ = brain.performOperation("+")
        _ = brain.performOperation("sqrt")
        _ = brain.pushOperand(6)
        _ = brain.performOperation("÷")
        XCTAssertEqual(brain.description, "cos(?), sqrt(3.0 + sqrt(5.0)) ÷ 6.0")
    }
    
    
    
}
