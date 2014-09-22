// Playground - noun: a place where people can play

import Foundation
import UIKit

let string = "abcdefghijklmnopqrstuvwxyz"

string[advance(string.startIndex, 6)]

string[advance(string.endIndex, -6)]


string[string.startIndex..<advance(string.endIndex, -6)]