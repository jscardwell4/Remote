//
//  BankButton.swift
//  Remote
//
//  Created by Jason Cardwell on 5/20/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import UIKit
import MoonKit
import Foundation

class BankButton: UIView {

  func initializeIVARs() {
    backgroundColor = UIColor.blueColor()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    initializeIVARs()
  }

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initializeIVARs()
  }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
