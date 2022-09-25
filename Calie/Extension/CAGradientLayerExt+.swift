//
//  CAGradientLayerExt+.swift
//  Calie
//
//  Created by Mac mini on 2022/09/25.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import UIKit


// MARK: - Gradient
extension CAGradientLayer {
    enum Point {
        case topLeft
        case centerLeft
        case bottomLeft
        case topCenter
        case center
        case bottomCenter
        case topRight
        case centerRight
        case bottomRight
        var point: CGPoint {
            switch self {
            case .topLeft:
                return CGPoint(x: 0, y: 0)
            case .centerLeft:
                return CGPoint(x: 0, y: 0.5)
            case .bottomLeft:
                return CGPoint(x: 0, y: 1.0)
            case .topCenter:
                return CGPoint(x: 0.5, y: 0)
            case .center:
                return CGPoint(x: 0.5, y: 0.5)
            case .bottomCenter:
                return CGPoint(x: 0.5, y: 1.0)
            case .topRight:
                return CGPoint(x: 1.0, y: 0.0)
            case .centerRight:
                return CGPoint(x: 1.0, y: 0.5)
            case .bottomRight:
                return CGPoint(x: 1.0, y: 1.0)
            }
        }
    }
    convenience init(start: Point, end: Point, colors: [CGColor], type: CAGradientLayerType) {
        self.init()
        self.startPoint = start.point
        self.endPoint = end.point
        self.colors = colors
        self.locations = (0..<colors.count).map(NSNumber.init)
        self.type = type
    }
}




public class EdgeShadowLayer: CAGradientLayer {

    public enum Edge {
        case Top
        case Left
        case Bottom
        case Right
    }

    public init(forView view: UIView,
                edge: Edge = Edge.Top,
                shadowRadius radius: CGFloat = 20.0,
                toColor: UIColor = UIColor.white,
                fromColor: UIColor = UIColor.black) {
        super.init()
        self.colors = [fromColor.cgColor, toColor.cgColor]
        self.shadowRadius = radius

        let viewFrame = view.frame

        switch edge {
            case .Top:
                startPoint = CGPoint(x: 0.5, y: 0.0)
                endPoint = CGPoint(x: 0.5, y: 1.0)
                self.frame = CGRect(x: 0.0, y: 0.0, width: viewFrame.width, height: shadowRadius)
            case .Bottom:
                startPoint = CGPoint(x: 0.5, y: 1.0)
                endPoint = CGPoint(x: 0.5, y: 0.0)
                self.frame = CGRect(x: 0.0, y: viewFrame.height - shadowRadius, width: viewFrame.width, height: shadowRadius)
            case .Left:
                startPoint = CGPoint(x: 0.0, y: 0.5)
                endPoint = CGPoint(x: 1.0, y: 0.5)
                self.frame = CGRect(x: 0.0, y: 0.0, width: shadowRadius, height: viewFrame.height)
            case .Right:
                startPoint = CGPoint(x: 1.0, y: 0.5)
                endPoint = CGPoint(x: 0.0, y: 0.5)
                self.frame = CGRect(x: viewFrame.width - shadowRadius, y: 0.0, width: shadowRadius, height: viewFrame.height)
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
