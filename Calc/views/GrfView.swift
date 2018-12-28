//
//  GrfView.swift
//  Calc
//
//  Created by Dzmitry Herasiuk on 11.12.2018.
//  Copyright © 2018 Dzmitry Herasiuk. All rights reserved.
//

import UIKit

enum Axis: String {
    case x
    case y
}

struct Coordinate {
    var value: CGFloat
    var axis: Axis
    var occurrenceNumber: Int
}

struct Info {
    var description: String {
        let formatter = CalculatorFormatter.sharedInstanse
        var miY = "minY = \(formatter.string(for: minY.value)!) \nnumb = \(formatter.string(for: minY.occurrenceNumber)!)\n"
        var maY = "maxY = \(formatter.string(for: maxY.value)!) \nnumb = \(formatter.string(for: maxY.occurrenceNumber)!)"
        return "\(miY)\n\(maY)"
    }
    
    var minY = Coordinate(value: 0, axis: .y, occurrenceNumber: 0)
    var maxY = Coordinate(value: 0, axis: .y, occurrenceNumber: 0)
    var step: Int = 0
    
    mutating func calculate (y: CGFloat?) {
        guard let _y = y else { return }
        
        if step == 0 {
            minY.value = _y
            maxY.value = _y
        }
        
        if _y < minY.value { minY.value = _y; minY.occurrenceNumber = step }
        if _y > maxY.value { maxY.value = _y; maxY.occurrenceNumber = step }
        
        step += 1
    }
}


protocol GrfViewDatasource: AnyObject {
    func getYfor(x: CGFloat) -> CGFloat?
}

@IBDesignable
class GrfView: UIView {

    weak var datasource: GrfViewDatasource?

    private var isShowHashmarks = true {
        didSet { setNeedsDisplay() }
    }
    private lazy var axesDrawer = AxesDrawer(contentScaleFactor: contentScaleFactor)
    private let defaultStorage = UserDefaults()
    
    var info = Info()

    @IBInspectable
    var scale: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var origenGrf: CGPoint = CGPoint.zero {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        axesDrawer.drawAxes(in: bounds, origin: origenGrf, pointsPerUnit: scale, isShowHashmarks: isShowHashmarks)
        
        let grfPath = getGrfPath()
    
        let (stepGrf, countSteps) = getDrawingStepAndCoutsStep()
        
        let initialGrfX = -origenGrf.x / scale
        var nextGrfX = initialGrfX
        var isFirstValue = true
        
        info = Info()
        
        for _ in 0...countSteps {
            let grfPoint = getGrfPoint(x: nextGrfX)
            
            info.calculate(y: grfPoint?.y)
            
            if let screenPoint = convertCoordinate(point: grfPoint) {
                if isFirstValue {
                    grfPath.move(to: screenPoint)
                } else {
                    grfPath.addLine(to: screenPoint)
                }
                isFirstValue = false
            } else {
                isFirstValue = true
            }
            
            nextGrfX += stepGrf
        }
        
        grfPath.stroke()
    }
    
    private func getGrfPath() -> UIBezierPath {
        let path = UIBezierPath()
        path.lineWidth = 1
        UIColor.red.set()
        return path
    }
    
    private func getDrawingStepAndCoutsStep() -> (CGFloat, Int) {
        let pixelsInWidth = bounds.width * contentScaleFactor
        let unitsWidth = bounds.width / scale
        return (unitsWidth / pixelsInWidth, Int(pixelsInWidth))
    }
    
    private func getGrfPoint(x: CGFloat) -> CGPoint? {
        guard let y = datasource?.getYfor(x: x) else { return nil }
        return CGPoint(x: x, y: y)
    }
    
    private func convertCoordinate(point: CGPoint?) -> CGPoint? {
        guard let p = point else { return nil }
        let pX = p.x * scale + origenGrf.x
        let pY = -p.y * scale + origenGrf.y
        return CGPoint(x: pX, y: pY)
    }
    
    @IBAction func moveOrigenGrf(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            isShowHashmarks = false
        case .changed:
            let offsetOrigenGrf = gesture.translation(in: self)
            origenGrf.x += offsetOrigenGrf.x
            origenGrf.y += offsetOrigenGrf.y
            gesture.setTranslation(.zero, in: self)
        case .ended:
            isShowHashmarks = true
        default:
            break
        }
    }
    
    @IBAction func setOrigenGrf(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            origenGrf = gesture.location(in: self)
        }
    }
    
    @objc func changeScale(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .changed {
            scale *= gesture.scale
            gesture.scale = 1
        }
    }
}
