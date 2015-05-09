//
//  Elysio.swift
//  Remote
//
//  Created by Jason Cardwell on 5/9/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import CoreText
import MoonKit

public final class Elysio: NSObject {

  private static var fontsRegistered = false

  public class func registerFonts() {
    if !fontsRegistered {
      fontsRegistered = true
      let styles = ["Hairline", "Thin", "Light", "Regular", "Bold", "Black"]
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
}