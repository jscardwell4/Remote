// Playground - noun: a place where people can play

import Foundation
import UIKit

let string = "{\n  \"uu\\\"id\": \"some-nasty-uuid\""

let escaped = string.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
