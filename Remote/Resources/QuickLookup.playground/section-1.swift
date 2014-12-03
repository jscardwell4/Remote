// Playground - noun: a place where people can play

import Foundation
import UIKit
import MoonKit

var i = 3
var blocks: [(Void) -> Int] = [{i + 1}, {i + 2}, {i + 3}]
blocks

var a = Array(enumerate([{i + 1}, {i + 2}, {i + 3}]))
var lazyBlocks = lazy(a)

countElements(lazyBlocks.array)

var mappedLazyBlocks = lazyBlocks.map { (index, element) -> Int in
  return index
}

mappedLazyBlocks.array

i = 12

countElements(mappedLazyBlocks.array)

mappedLazyBlocks.array

mappedLazyBlocks[2]

blocks.append({i - 12})

mappedLazyBlocks.array
