//
//  GrfView.swift
//  Calc
//
//  Created by Dzmitry Herasiuk on 11.12.2018.
//  Copyright © 2018 Dzmitry Herasiuk. All rights reserved.
//

import UIKit

protocol GrfViewDatasource: AnyObject {
    func getYfor(x: CGFloat) -> CGFloat?
}

@IBDesignable
class GrfView: UIView {

    struct GrfConstant {
        static let scaleKey = "GrfConstantKey.scale"
        static let origenGrfKey = "GrfConstantKey.origenGrf"
        static let defaultScale: CGFloat = 100
    }
    
    weak var datasource: GrfViewDatasource?

    private var isShowHashmarks = true {
        didSet { setNeedsDisplay() }
    }
    private lazy var axesDrawer = AxesDrawer(contentScaleFactor: contentScaleFactor)
    private let defaultStorage = UserDefaults()

    @IBInspectable
    var scale: CGFloat = 100 {
        didSet {
            // where save Scale to storage?
            setNeedsDisplay()
        }
    }
    
    var origenGrf: CGPoint = CGPoint.zero {
        didSet {
            saveOrigenToStorage()
            setNeedsDisplay()
        }
    }
    
    override func awakeFromNib() {
        setInitialStateView()
    }
    
    override func draw(_ rect: CGRect) {
        axesDrawer.drawAxes(in: bounds, origin: origenGrf, pointsPerUnit: scale, isShowHashmarks: isShowHashmarks)
        
        let grfPath = getGrfPath()
    
        let (stepGrf, countSteps) = getDrawingStepAndCoutsStep()
        
        let initialGrfX = -origenGrf.x / scale
        var nextGrfX = initialGrfX
        var isFirstValue = false
        
        for _ in 0...countSteps {
            if let point = convertCoordinate(point: getGrfPoint(x: nextGrfX)) {
                if isFirstValue {
                    grfPath.addLine(to: point)
                } else {
                    grfPath.move(to: point)
                }
                isFirstValue = true
            } else {
                isFirstValue = false
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
    
    private func setInitialStateView() {
        setInitialOrigenGrf()
        setInitialScale()
    }
    
    private func setInitialOrigenGrf() {
        let pointPresentation = defaultStorage.object(forKey: GrfConstant.origenGrfKey) as? NSDictionary ?? NSDictionary()
        origenGrf = CGPoint(dictionaryRepresentation: pointPresentation) ?? .zero
    }
    
    private func setInitialScale() {
        let scalePresentation = defaultStorage.object(forKey: GrfConstant.scaleKey) as? CGFloat
        scale = scalePresentation ?? GrfConstant.defaultScale
    }
    
    private func saveAllToStorage() {
        saveOrigenToStorage()
        saveScaleToStorage()
    }
    
    private func saveScaleToStorage() {
        defaultStorage.set(scale, forKey: GrfConstant.scaleKey)
    }
    
    private func saveOrigenToStorage() {
        defaultStorage.set(origenGrf.dictionaryRepresentation, forKey: GrfConstant.origenGrfKey)
    }
}
