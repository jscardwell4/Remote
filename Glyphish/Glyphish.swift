//
//  Glyphish.swift
//  Remote
//
//  Created by Jason Cardwell on 5/9/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import class Foundation.NSBundle
import class UIKit.UIImage
import class UIKit.UIFont
import CoreText

public final class Glyphish {

  private static var fontRegistered = false

  public static let bundle = NSBundle(forClass: Glyphish.self)

  /**
  imageNamed:

  :param: named String

  :returns: UIImage?
  */
  public class func imageNamed(named: String) -> UIImage? {
    return UIImage(named: named, inBundle: bundle, compatibleWithTraitCollection: nil)
  }

  /**
  fontWithSize:

  :param: size CGFloat

  :returns: UIFont
  */
  public class func fontWithSize(size: CGFloat) -> UIFont {
    if !fontRegistered && CTFontManagerRegisterFontsForURL(bundle.URLForResource("glyphish", withExtension: "ttf"), .None, nil) {
      fontRegistered = true
    }
    assert(fontRegistered)
    return UIFont(name: "Glyphish", size: size)!
  }

}
