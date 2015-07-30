//: Playground - noun: a place where people can play
import Foundation
import UIKit
import MoonKit

enum CustomError: ErrorType {
  case ThingOneGotFucked
  case ThingTwoGotFucked
}

let error = CustomError.ThingOneGotFucked

let nserror = error as NSError


String(String)
