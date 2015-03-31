// Playground - noun: a place where people can play

import Foundation

let rawValue = "Sony/AV%20Receiver/MD%2FTape"

let pathIndex = PathIndex(rawValue: rawValue)!

pathIndex[0]
pathIndex[1]
pathIndex[2]
pathIndex[0...1]
