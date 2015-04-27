//
//  DrawingKit+Extensions.swift
//  Remote
//
//  Created by Jason Cardwell on 4/26/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import MoonKit

extension DrawingKit {

  public class func roundishBasePath(#frame: CGRect, radius: CGFloat) -> UIBezierPath {
    return UIBezierPath(roundedRect: frame.rectByInsetting(dx: 2, dy: 2), cornerRadius: radius)
  }

  public class func rectangularBasePath(#frame: CGRect) -> UIBezierPath {
    return UIBezierPath(rect: frame.rectByInsetting(dx: 2, dy: 2))
  }

  public class func ovalBasePath(#frame: CGRect) -> UIBezierPath {
    return UIBezierPath(ovalInRect: frame.rectByInsetting(dx: 2, dy: 2))
  }

  public class func diamondBasePath(#frame: CGRect) -> UIBezierPath {
    var path = UIBezierPath()
    path.moveToPoint(CGPoint(x: frame.minX + 2, y: frame.minY + 0.5 * frame.height))
    path.addLineToPoint(CGPoint(x: frame.minX + 0.5 * frame.width, y: frame.minY + 2))
    path.addLineToPoint(CGPoint(x: frame.maxX - 2, y: frame.minY + 0.5 * frame.height))
    path.addLineToPoint(CGPoint(x: frame.minX + 0.5 * frame.width, y: frame.maxY - 2))
    path.addLineToPoint(CGPoint(x: frame.minX + 2, y: frame.minY + 0.5 * frame.height))
    path.closePath()
    return path
  }

  public class func triangleBasePath(#frame: CGRect) -> UIBezierPath {
    let r = CGRect(x: frame.minX + 7.2, y: frame.minY + 9.5, width: frame.width - 13.4, height: frame.height - 25)
    var path = UIBezierPath()
    path.moveToPoint(CGPoint(x: r.minX + 0.5 * r.width, y: r.minY))
    path.addLineToPoint(CGPoint(x: r.minX + 0.75 * r.width, y: r.minY + 0.5 * r.height))
    path.addLineToPoint(CGPoint(x: r.minX + r.width, y: r.minY + r.height))
    path.addLineToPoint(CGPoint(x: r.minX + 0.5 * r.width, y: r.minY + r.height))
    path.addLineToPoint(CGPoint(x: r.minX, y: r.minY + r.height))
    path.addLineToPoint(CGPoint(x: r.minX + 0.25 * r.width, y: r.minY + 0.5 * r.height))
    path.addLineToPoint(CGPoint(x: r.minX + 0.5 * r.width, y: r.minY ))
    path.closePath()
    return path
  }
}
