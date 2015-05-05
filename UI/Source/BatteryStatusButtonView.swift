//
//  BatteryStatusButtonView.swift
//  Remote
//
//  Created by Jason Cardwell on 11/07/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit
import DataModel

public final class BatteryStatusButtonView: ButtonView {

	var batteryFrame: ImageView?
	var batteryPlug: ImageView?
	var batteryLightning: ImageView?
	var batteryFill: ImageView?

  private(set) var batteryLevel: Float = -1
  private(set) var batteryState: UIDeviceBatteryState = .Unknown
  private var batteryLevelReceptionist: MSNotificationReceptionist!
  private var batteryStateReceptionist: MSNotificationReceptionist!

	/** initializeIVARs */
	override func initializeIVARs() {
		super.initializeIVARs()
		let device = UIDevice.currentDevice()
		batteryLevel = device.batteryLevel
		batteryState = device.batteryState
		device.batteryMonitoringEnabled = true
	}

	/** registerForChangeNotification */
	override func registerForChangeNotification() {
		super.registerForChangeNotification()
		let device = UIDevice.currentDevice()
		let queue = NSOperationQueue.mainQueue()
		batteryLevelReceptionist = MSNotificationReceptionist(
			observer: self,
			forObject: device,
			notificationName: UIDeviceBatteryLevelDidChangeNotification,
			queue: queue,
			handler: {
				(receptionist: MSNotificationReceptionist!) -> Void in
					if let v = receptionist.observer as? BatteryStatusButtonView {
						v.batteryLevel = device.batteryLevel
						v.setNeedsDisplay()
					}
			})
		batteryStateReceptionist = MSNotificationReceptionist(
			observer: self,
			forObject: device,
			notificationName: UIDeviceBatteryStateDidChangeNotification,
			queue: queue,
			handler: {
				(receptionist: MSNotificationReceptionist!) -> Void in
					if let v = receptionist.observer as? BatteryStatusButtonView {
						v.batteryState = device.batteryState
						v.setNeedsDisplay()
					}
			})

	}

	/** initializeViewFromModel */
	override func initializeViewFromModel() {
		super.initializeViewFromModel()
    let icons = button.iconSet
    batteryFrame     = icons?[UIControlState.Normal.rawValue] as? ImageView
    batteryPlug      = icons?[UIControlState.Selected.rawValue] as? ImageView
    batteryLightning = icons?[UIControlState.Disabled.rawValue] as? ImageView
    batteryFill      = icons?[UIControlState.Highlighted.rawValue] as? ImageView
	}

	/**
	intrinsicContentSize

	:returns: CGSize
	*/
  override public func intrinsicContentSize() -> CGSize {
    if let iconSize = button.icon?.image?.size where iconSize > RemoteElementView.MinimumSize { return iconSize }
    else { return RemoteElementView.MinimumSize }
  }


	/**
	drawRect:

	:param: rect CGRect
	*/
	override public func drawRect(rect: CGRect) {

    let baseRect = rect.rectByInsetting(dx: 4, dy: 4).integerRect

	  if batteryLevel == -1 {
	  	let device = UIDevice.currentDevice()
	    batteryLevel = device.batteryLevel
	    batteryState = device.batteryState
	  }

    let baseColor: UIColor
    if let color = button.iconSet?.normal?.color { baseColor = color }
    else { baseColor = Painter.defaultBackgroundColor }

    let hasPower = [.Charging, .Full] ∋ batteryState

    let chargeLevel = CGFloat(batteryLevel)

    Painter.drawBatteryStatus(color: baseColor, hasPower: hasPower, chargeLevel: chargeLevel, frame: baseRect)

/*
	  let insetRect = rect.rectByInsetting(dx: 2.0, dy: 2.0)
	  let frameIconSize = batteryFrame?.image?.size ?? CGSize.zeroSize
	  let frameSize = insetRect.size.contains(frameIconSize) ? frameIconSize : frameIconSize.aspectMappedToSize(insetRect.size, binding: true)
	  let frameRect = CGRect(x: insetRect.midX - frameSize.width / 2.0,
                           y: insetRect.midY - frameSize.height / 2.0,
	                         width: frameSize.width,
	                         height: frameSize.height)

	  batteryFrame?.colorImage?.drawInRect(frameRect)

	  let padding = frameSize.width * 0.06
	  let paintSize = CGSize(width: frameSize.width - 4 * padding, height: frameSize.height - 3 * padding)
	  var paintRect = CGRect(x: frameRect.origin.x + padding, y: frameRect.origin.y + 1.5 * padding,
	                         width: paintSize.width, height: paintSize.height)

	  paintRect.size.width *= CGFloat(batteryLevel)

	  let path = UIBezierPath(rect: paintRect)

	  batteryFill.color?.setFill()
	  path.fill()

	  if batteryState == .Full {
	    batteryPlug.colorImage?.drawInRect(frameRect.rectByInsetting(dx: padding, dy: padding))
	  } else if batteryState == .Charging {
	    let lightningIconSize = batteryLightning.image?.size ?? CGSize.zeroSize
      let lightningSize = paintSize.contains(lightningIconSize) ? lightningIconSize : lightningIconSize.aspectMappedToSize(paintSize, binding: true)
	    let lightningRect = CGRect(origin: CGPoint(x: frameRect.midX - lightningSize.width / 2.0, y: frameRect.midY - lightningSize.height / 2.0), size: lightningSize)
	    batteryLightning.colorImage?.drawInRect(lightningRect)
	  }

*/
  }

}
