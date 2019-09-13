//
//  BarLeftView.swift
//  safe_control_by_RFID
//
//  Created by elijah tam on 2019/8/16.
//  Copyright © 2019 elijah tam. All rights reserved.
//

import Foundation
import UIKit

enum LifeCircleColor{
    case normal
    case alert
    case critical
    case white
    
    public func getUIColor() -> UIColor{
        switch self {
        case .normal:
            return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        case .alert:
            return #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        case .critical:
            return #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        case .white:
            return #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        }
    }
}

class BarLeftView:UIView{
    var barRatio:Double = 1
    var barColor:LifeCircleColor = .white
    private let barLayer = CAShapeLayer()
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.2)
        self.layer.addSublayer(barLayer)
        barLayer.lineWidth = self.bounds.width/2
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let bezi = UIBezierPath()
        bezi.move(to: CGPoint(x: self.bounds.width/2, y: self.bounds.height))
        bezi.addLine(to: CGPoint(x: self.bounds.width/2, y: self.bounds.height*CGFloat(1 - barRatio)))
        barLayer.path = bezi.cgPath
        barLayer.strokeColor = barColor.getUIColor().cgColor
    }
    
    
    /// 設定bar長度
    func setBar(ratio:Double){
        // 修正 ratio 範圍 防止超過 0~1
        self.barRatio = ratio > 0 ? (ratio < 1 ? ratio:1):0
        //self.layoutIfNeeded()
        self.setNeedsDisplay()
        
    }
    /// 設定bar的顏色
    func setBar(color:LifeCircleColor){
        //self.barColor = color
        //self.setNeedsDisplay()
    }
}
