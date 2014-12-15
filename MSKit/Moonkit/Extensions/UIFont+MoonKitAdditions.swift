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

  public class func loadFontAwesome() {
    if let moonkit = NSBundle.allFrameworks().filter({$0.bundleIdentifier == "com.moondeerstudios.MoonKit"}).first as? NSBundle {
      if let fontPath = moonkit.pathForResource("FontAwesome", ofType: "otf") {
        if let fontData = NSData(contentsOfFile: fontPath) {
          let provider = CGDataProviderCreateWithCFData(fontData)
          let font = CGFontCreateWithDataProvider(provider)
          if !CTFontManagerRegisterGraphicsFont(font, nil) {
            MSLogError("failed to register 'FontAwesome' font with font manager")
          }
        }
      }
    }
  }

  /** initialize */
  public override class func initialize() {
    if self === UIFont.self {
      let seconds = Int64(2 * Double(NSEC_PER_SEC))
      let when = dispatch_time(DISPATCH_TIME_NOW, seconds)
      dispatch_after(when, dispatch_get_main_queue()) { self.loadFontAwesome() }
    }
  }

  /**
  fontFamilyAvailable:

  :param: family String

  :returns: Bool
  */
  public class func fontFamilyAvailable(family: String) -> Bool {
    let families = UIFont.familyNames() as? [String]
    if families == nil { fatalError("could not downcast family names") }
    return contains(families!, family)
  }

}

