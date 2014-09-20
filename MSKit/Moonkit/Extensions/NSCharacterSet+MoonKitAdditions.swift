//
//  NSCharacterSet+MoonKitAdditions.swift
//  MSKit
//
//  Created by Jason Cardwell on 9/17/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation

private let EmptyCharacterSet: NSCharacterSet = NSCharacterSet(charactersInString:"")

extension NSCharacterSet {

  convenience init(character:Character) { self.init(charactersInString:String(character)) }

  class var emptyCharacterSet: NSCharacterSet { return EmptyCharacterSet }

}

func + (lhs: NSCharacterSet, rhs: NSCharacterSet) -> NSCharacterSet {
  var lbytes = [UInt8](count: 8192, repeatedValue: 0)
  lhs.bitmapRepresentation.getBytes(&lbytes)
  var rbytes = [UInt8](count: 8192, repeatedValue: 0)
  rhs.bitmapRepresentation.getBytes(&rbytes)

  let bytes = [(UInt8, UInt8)](Zip2<[UInt8], [UInt8]>(lbytes, rbytes)).map {$0 | $1}
  return NSCharacterSet(bitmapRepresentation: NSData(bytes:bytes, length:bytes.count))
}