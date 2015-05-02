//
//  ConnectionStatusButtonView.swift
//  Remote
//
//  Created by Jason Cardwell on 11/07/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit
import DataModel
import Networking

public final class ConnectionStatusButtonView: ButtonView {

  private var receptionist: MSNotificationReceptionist!

  private var connected: Bool = false

  /** initializeIVARs */
  override func initializeIVARs() {
    super.initializeIVARs()
    connected = ConnectionManager.isWifiAvailable()
    receptionist = MSNotificationReceptionist(
      observer: self,
      forObject: nil,
      notificationName: CMConnectionStatusNotification,
      queue: NSOperationQueue.mainQueue(),
      handler: {
        (receptionist: MSNotificationReceptionist!) -> Void in
          if let v = receptionist.observer as? ConnectionStatusButtonView {
            let currentlyConnected = v.connected
            if let wifiAvailable = receptionist.notification.userInfo?[CMConnectionStatusWifiAvailableKey] as? Bool {
              if currentlyConnected != wifiAvailable { v.connected = !currentlyConnected; v.setNeedsDisplay() }
            }
          }
      })
  }

  /**
  drawRect:

  :param: rect CGRect
  */
  override public func drawRect(rect: CGRect) {
    let iconColor: UIColor
    if let color = button.iconSet?.normal?.color { iconColor = color }
    else { iconColor = Painter.defaultBackgroundColor }
    Painter.drawWifiStatus(color: iconColor, connected: connected, frame: rect)
  }
}
