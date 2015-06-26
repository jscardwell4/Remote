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
    if let moonkit = NSBundle.allFrameworks().filter({$0.bundleIdentifier == "com.moondeerstudios.MoonKit"}).first,
      fontPath = moonkit.pathForResource("FontAwesome", ofType: "otf"),
      fontData = NSData(contentsOfFile: fontPath),
      provider = CGDataProviderCreateWithCFData(fontData),
      font = CGFontCreateWithDataProvider(provider)
    {
      if !CTFontManagerRegisterGraphicsFont(font, nil) {
        MSLogError("failed to register 'FontAwesome' font with font manager")
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

  - parameter family: String

  - returns: Bool
  */
  public class func fontFamilyAvailable(family: String) -> Bool {
    return UIFont.familyNames().contains(family)
  }

}

extension UIFont: JSONValueConvertible {
  public var jsonValue: JSONValue { return "\(fontName)@\(pointSize)".jsonValue }
}

extension UIFont /*: JSONValueInitializable */ {
  public convenience init?(_ jsonValue: JSONValue?) {
    if let string = String(jsonValue) {
      let captures = disperse2(string.matchFirst("^([^@]*)@?([0-9]*\\.?[0-9]*)"))

      if let name = captures.0 where UIFont.familyNames() as [String] ∋ name {

        let size: CGFloat

        if captures.1 != nil {
          var s: Float = 0.0
          let scanner = NSScanner(string: captures.1!)
          if scanner.scanFloat(&s) { size = CGFloat(s) }
          else { self.init(); return nil }
        }
        else if captures.1 == nil { size = UIFont.systemFontSize() }
        else { self.init(); return nil }

        self.init(name: name, size: size)

      } else { self.init(); return nil }
      
    } else { self.init(); return nil }
  }
}

