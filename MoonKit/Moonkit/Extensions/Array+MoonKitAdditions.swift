//
//  Array+MoonKitAdditions.swift
//  Remote
//
//  Created by Jason Cardwell on 12/20/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation

extension Array {
  func compressedMap<U>(transform: (T) -> U?) -> [U] { return MoonKit.compressedMap(self, transform) }
}

//