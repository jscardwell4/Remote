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

  /**
  initWithAutolayout:

  :param: autolayout Bool
  */
  public convenience init(autolayout: Bool) {
    self.init(frame: CGRect.zeroRect)
    setTranslatesAutoresizingMaskIntoConstraints(!autolayout)
  }

  /**
  framesDescription

  :returns: String
  */
  public func framesDescription() -> String {
  	return self.viewTreeDescriptionWithProperties(["frame"])
      .stringByReplacingRegEx("[{]\\s*\n\\s*frame = \"NSRect:\\s*([^\"]+)\";\\s*\n\\s*[}]", withString: " { frame=$1 }")
  }

  /**
  descriptionTree:

  :param: properties String ...

  :returns: String
  */
  public func descriptionTree(properties: String ...) -> String {
  	return self.viewTreeDescriptionWithProperties(properties)
  }
}
