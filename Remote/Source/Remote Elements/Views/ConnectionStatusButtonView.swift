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

class ConnectionStatusButtonView: ButtonView {

  private var receptionist: MSNotificationReceptionist!

  /** initializeIVARs */
  override func initializeIVARs() {
    super.initializeIVARs()
    button.selected = ConnectionManager.isWifiAvailable()
    receptionist = MSNotificationReceptionist(
      observer: self,
      forObject: nil,
      notificationName: CMConnectionStatusNotification,
      queue: NSOperationQueue.mainQueue(),
      handler: {
        (receptionist: MSNotificationReceptionist!) -> Void in
          if let v = receptionist.observer as? ConnectionStatusButtonView {
            let selected = v.button.selected
            if let wifiAvailable = receptionist.notification.userInfo?[CMConnectionStatusWifiAvailableKey] as? Bool {
              if selected != wifiAvailable { v.button.selected = !selected }
            }
          }
      })
  }

}
