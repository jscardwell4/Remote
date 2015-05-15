//
//  Elysio.swift
//  Remote
//
//  Created by Jason Cardwell on 5/9/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import class Foundation.NSBundle
import class Foundation.NSURL
import class UIKit.UIFont
import CoreText
import func MoonKit.compressedMap
import func MoonKit.MSLogError
import func MoonKit.descriptionForError
import func MoonKit.toString

public final class Elysio: NSObject {

  private static var fontsRegistered = false

  /** initialize */
  public override class func initialize() { if self === Elysio.self && !fontsRegistered { registerFonts() } }

  /** registerFonts */
  public class func registerFonts() {
    if !fontsRegistered {
      fontsRegistered = true
      let styles = ["Hairline", "Thin", "Light", "Regular", "Medium", "Bold", "Black"]
      let fontNames = flatMap(styles) { ["Elysio-\($0)", "Elysio-\($0)Italic"] }
      let bundle = NSBundle(forClass: self)
      let fontURLs = compressedMap(fontNames) { bundle.URLForResource($0, withExtension: "otf") }
      var errors: Unmanaged<CFArray>?
      CTFontManagerRegisterFontsForURLs(fontURLs, CTFontManagerScope.None, &errors)
      if let errorsArray = errors?.takeRetainedValue() as? NSArray,
        errors = errorsArray as? [NSError]
      {
        let error = NSError(domain: "CTFontManagerErrorDomain",
                            code: 1,
                            underlyingErrors: errors,
                            userInfo: [NSLocalizedDescriptionKey:"Errors encountered registering 'Elysio' fonts"])
        MSLogError("\(toString(descriptionForError(error)))")
      }
    }
  }

  /**
  hairlineFontWithSize:

  :param: size CGFloat

  :returns: UIFont
  */
  public class func hairlineFontWithSize(size: CGFloat) -> UIFont {
    if !fontsRegistered { registerFonts() }
    assert(fontsRegistered)
    let font = UIFont(name: "Elysio-Hairline", size: size)
    assert(font != nil)
    return font!
  }

  /**
  thinFontWithSize:

  :param: size CGFloat

  :returns: UIFont
  */
  public class func thinFontWithSize(size: CGFloat) -> UIFont {
    if !fontsRegistered { registerFonts() }
    assert(fontsRegistered)
    let font = UIFont(name: "Elysio-Thin", size: size)
    assert(font != nil)
    return font!
  }

  /**
  lightFontWithSize:

  :param: size CGFloat

  :returns: UIFont
  */
  public class func lightFontWithSize(size: CGFloat) -> UIFont {
    if !fontsRegistered { registerFonts() }
    assert(fontsRegistered)
    let font = UIFont(name: "Elysio-Light", size: size)
    assert(font != nil)
    return font!
  }

  /**
  regularFontWithSize:

  :param: size CGFloat

  :returns: UIFont
  */
  public class func regularFontWithSize(size: CGFloat) -> UIFont {
    if !fontsRegistered { registerFonts() }
    assert(fontsRegistered)
    let font = UIFont(name: "Elysio-Regular", size: size)
    assert(font != nil)
    return font!
  }

  /**
  mediumFontWithSize:

  :param: size CGFloat

  :returns: UIFont
  */
  public class func mediumFontWithSize(size: CGFloat) -> UIFont {
    if !fontsRegistered { registerFonts() }
    assert(fontsRegistered)
    let font = UIFont(name: "Elysio-Medium", size: size)
    assert(font != nil)
    return font!
  }

  /**
  boldFontWithSize:

  :param: size CGFloat

  :returns: UIFont
  */
  public class func boldFontWithSize(size: CGFloat) -> UIFont {
    if !fontsRegistered { registerFonts() }
    assert(fontsRegistered)
    let font = UIFont(name: "Elysio-Bold", size: size)
    assert(font != nil)
    return font!
  }

  /**
  blackFontWithSize:

  :param: size CGFloat

  :returns: UIFont
  */
  public class func blackFontWithSize(size: CGFloat) -> UIFont {
    if !fontsRegistered { registerFonts() }
    assert(fontsRegistered)
    let font = UIFont(name: "Elysio-Black", size: size)
    assert(font != nil)
    return font!
  }

  /**
  hairlineItalicFontWithSize:

  :param: size CGFloat

  :returns: UIFont
  */
  public class func hairlineItalicFontWithSize(size: CGFloat) -> UIFont {
    if !fontsRegistered { registerFonts() }
    assert(fontsRegistered)
    let font = UIFont(name: "Elysio-HairlineItalic", size: size)
    assert(font != nil)
    return font!
  }

  /**
  thinItalicFontWithSize:

  :param: size CGFloat

  :returns: UIFont
  */
  public class func thinItalicFontWithSize(size: CGFloat) -> UIFont {
    if !fontsRegistered { registerFonts() }
    assert(fontsRegistered)
    let font = UIFont(name: "Elysio-ThinItalic", size: size)
    assert(font != nil)
    return font!
  }

  /**
  lightItalicFontWithSize:

  :param: size CGFloat

  :returns: UIFont
  */
  public class func lightItalicFontWithSize(size: CGFloat) -> UIFont {
    if !fontsRegistered { registerFonts() }
    assert(fontsRegistered)
    let font = UIFont(name: "Elysio-LightItalic", size: size)
    assert(font != nil)
    return font!
  }

  /**
  regularItalicFontWithSize:

  :param: size CGFloat

  :returns: UIFont
  */
  public class func regularItalicFontWithSize(size: CGFloat) -> UIFont {
    if !fontsRegistered { registerFonts() }
    assert(fontsRegistered)
    let font = UIFont(name: "Elysio-RegularItalic", size: size)
    assert(font != nil)
    return font!
  }

  /**
  mediumItalicFontWithSize:

  :param: size CGFloat

  :returns: UIFont
  */
  public class func mediumItalicFontWithSize(size: CGFloat) -> UIFont {
    if !fontsRegistered { registerFonts() }
    assert(fontsRegistered)
    let font = UIFont(name: "Elysio-MediumItalic", size: size)
    assert(font != nil)
    return font!
  }

  /**
  boldItalicFontWithSize:

  :param: size CGFloat

  :returns: UIFont
  */
  public class func boldItalicFontWithSize(size: CGFloat) -> UIFont {
    if !fontsRegistered { registerFonts() }
    assert(fontsRegistered)
    let font = UIFont(name: "Elysio-BoldItalic", size: size)
    assert(font != nil)
    return font!
  }

  /**
  blackItalicFontWithSize:

  :param: size CGFloat

  :returns: UIFont
  */
  public class func blackItalicFontWithSize(size: CGFloat) -> UIFont {
    if !fontsRegistered { registerFonts() }
    assert(fontsRegistered)
    let font = UIFont(name: "Elysio-BlackItalic", size: size)
    assert(font != nil)
    return font!
  }

}