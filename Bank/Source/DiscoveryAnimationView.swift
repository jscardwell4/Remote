//
//  DiscoveryAnimationView.swift
//  Remote
//
//  Created by Jason Cardwell on 8/1/15.
//  Copyright © 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import MoonKit

final class DiscoveryAnimationView: UIView {

  /// The total number of frames to include in the beam animation
  var totalAnimationFrames = 60

  /// The current frame for the beam animation
  var animationFrame = 0 {
    didSet {
      animationFrame = animationFrame % totalAnimationFrames
      if animationFrame != oldValue { setNeedsDisplay() }
    }
  }

  /// Changes to this value toggle animation on and off
  var animating = false {
    didSet {
      guard oldValue != animating else { return }
      switch animating {
        case true:
          assert(animationTimer == nil)
          animationTimer = createAnimationTimer()
        case false:
          assert(animationTimer != nil)
          dispatch_source_cancel(animationTimer!)
          animationTimer = nil
      }
    }
  }

  /// Triggers increment of `animationFrame` value
  private var animationTimer: dispatch_source_t?

  /**
  createAnimationTimer

  - returns: dispatch_source_t?
  */
  private func createAnimationTimer() -> dispatch_source_t? {
    guard let timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue()) else { return nil }

    dispatch_source_set_timer(timer, dispatch_walltime(nil, 0), UInt64(Double(1/30.0) * Double(NSEC_PER_SEC)), 0)
    dispatch_source_set_event_handler(timer) { [weak self] in self?.animationFrame++ }
    dispatch_resume(timer)
    return timer
  }

  /**
  initWithFrame:

  - parameter frame: CGRect
  */
  override init(frame: CGRect) {
    beamWidth = beamPath.bounds.width
    super.init(frame: frame)
    backgroundColor = UIColor.clearColor()
  }

  /**
  init:

  - parameter aDecoder: NSCoder
  */
  required init?(coder aDecoder: NSCoder) { beamWidth = beamPath.bounds.width; super.init(coder: aDecoder) }

  private let dishPath: UIBezierPath = {
    let dishPath = UIBezierPath()
    dishPath.moveToPoint(CGPoint(x: 43.47, y: 88.1))
    dishPath.addLineToPoint(CGPoint(x: 45.47, y: 59.86))
    dishPath.addCurveToPoint(CGPoint(x: 49.45, y: 55.05),
              controlPoint1: CGPoint(x: 47.73, y: 59.43),
              controlPoint2: CGPoint(x: 49.45, y: 57.44))
    dishPath.addCurveToPoint(CGPoint(x: 44.6, y: 50.17),
              controlPoint1: CGPoint(x: 49.45, y: 52.36),
              controlPoint2: CGPoint(x: 47.27, y: 50.17))
    dishPath.addCurveToPoint(CGPoint(x: 39.85, y: 54.18),
              controlPoint1: CGPoint(x: 42.22, y: 50.17),
              controlPoint2: CGPoint(x: 40.25, y: 51.9))
    dishPath.addLineToPoint(CGPoint(x: 11.82, y: 56.19))
    dishPath.addLineToPoint(CGPoint(x: 1, y: 45.29))
    dishPath.addCurveToPoint(CGPoint(x: 54.29, y: 99),
              controlPoint1: CGPoint(x: 1, y: 90.05),
              controlPoint2: CGPoint(x: 9.88, y: 99))
    dishPath.addLineToPoint(CGPoint(x: 43.47, y: 88.1))
    dishPath.closePath()
    dishPath.moveToPoint(CGPoint(x: 14.09, y: 58.48))
    dishPath.addLineToPoint(CGPoint(x: 40.01, y: 56.61))
    dishPath.addCurveToPoint(CGPoint(x: 40.44, y: 57.52),
              controlPoint1: CGPoint(x: 40.12, y: 56.92),
              controlPoint2: CGPoint(x: 40.26, y: 57.23))
    dishPath.addLineToPoint(CGPoint(x: 26.79, y: 71.28))
    dishPath.addLineToPoint(CGPoint(x: 14.09, y: 58.48))
    dishPath.closePath()
    dishPath.moveToPoint(CGPoint(x: 41.21, y: 85.81))
    dishPath.addLineToPoint(CGPoint(x: 28.5, y: 73.01))
    dishPath.addLineToPoint(CGPoint(x: 42.17, y: 59.24))
    dishPath.addCurveToPoint(CGPoint(x: 43.06, y: 59.66),
              controlPoint1: CGPoint(x: 42.45, y: 59.4),
              controlPoint2: CGPoint(x: 42.76, y: 59.56))
    dishPath.addLineToPoint(CGPoint(x: 41.21, y: 85.81))
    dishPath.closePath()
    return dishPath
  }()


  private let beamPath: UIBezierPath = {
    let beamPath = UIBezierPath()
    beamPath.moveToPoint(CGPoint(x: 30, y: 35.45))
    beamPath.addCurveToPoint(CGPoint(x: 58.02, y: 43.9),
              controlPoint1: CGPoint(x: 30, y: 35.45),
              controlPoint2: CGPoint(x: 45.18, y: 33.95))
    beamPath.addCurveToPoint(CGPoint(x: 67.16, y: 69.23),
              controlPoint1: CGPoint(x: 68.87, y: 55.74),
              controlPoint2: CGPoint(x: 67.16, y: 69.23))
    return beamPath
  }()

  private let beamWidth: CGFloat

  /**
  Draws a dish and beam for the current `animationFrame`

  - parameter rect: CGRect
  */
  override func drawRect(rect: CGRect) {

    let context = UIGraphicsGetCurrentContext()
    let fillColor = UIColor.blackColor()

    CGContextSaveGState(context)
    CGContextTranslateCTM(context, 0, h - 100)

    fillColor.setFill()
    dishPath.fill()

    let totalDistance = bounds.maxX + beamWidth - beamPath.bounds.maxX
    let distancePerFrame = totalDistance / CGFloat(totalAnimationFrames)
    let distanceThisFrame = CGFloat(animationFrame) * distancePerFrame

    CGContextTranslateCTM(context, distanceThisFrame, -distanceThisFrame)


    fillColor.setStroke()
    beamPath.lineWidth = 7
    beamPath.stroke()

    CGContextRestoreGState(context)

  }

  /**
  intrinsicContentSize

  - returns: CGSize
  */
  override func intrinsicContentSize() -> CGSize { return CGSize(square: 100) }

}

