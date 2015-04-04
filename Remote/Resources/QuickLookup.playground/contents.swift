// Playground - noun: a place where people can play
import Foundation
import UIKit

func isTypeBridgeable<T>(type: T.Type) -> Bool { return false}
func isTypeBridgeable<T:_ObjectiveCBridgeable>(type: T.Type) -> Bool { return true }

isTypeBridgeable(String.self)
