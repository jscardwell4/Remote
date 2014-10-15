//
//  UIView+MoonKitAdditions.swift
//  MSKit
//
//  Created by Jason Cardwell on 10/14/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {

  public convenience init(autolayout: Bool) {
    self.init(frame: CGRectZero)
    setTranslatesAutoresizingMaskIntoConstraints(!autolayout)
  }

}