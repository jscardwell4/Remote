//
//  UIFont+MoonKitAdditions.swift
//  HomeRemote
//
//  Created by Jason Cardwell on 8/17/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit



extension UIFont {

  public class func fontFamilyAvailable(family:String) -> Bool {
    let families = UIFont.familyNames() as? [String]
    if families == nil { fatalError("could not downcast family names") }
    return contains(families!, family)
  }

}

