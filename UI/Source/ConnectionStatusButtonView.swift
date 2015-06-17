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
    connected = ConnectionManager.wifiAvailable
    receptionist = MSNotificationReceptionist(
      observer: self,
      forObject: ConnectionManager.self,
      notificationName: ConnectionManager.ConnectionStatusNotification,
      queue: NSOperationQueue.mainQueue(),
      handler: {
        (receptionist: MSNotificationReceptionist!) -> Void in
          if let v = receptionist.observer as? ConnectionStatusButtonView {
            let currentlyConnected = v.connected
            if let wifiAvailable = receptionist.notification.userInfo?[ConnectionManager.WifiAvailableKey] as? Bool {
              if currentlyConnected != wifiAvailable { v.connected = !currentlyConnected; v.setNeedsDisplay() }
            }
          }
      })
  }

  /**
  drawRect:

  - parameter rect: CGRect
  */
  override public func drawRect(rect: CGRect) {
    let baseRect = rect.rectByInsetting(dx: 4, dy: 4).integerRect
    let iconColor: UIColor
    if let color = button.iconSet?.normal?.color { iconColor = color }
    else { iconColor = Painter.defaultBackgroundColor }
    Painter.drawWifiStatus(color: iconColor, connected: connected, frame: baseRect)
  }
}
