// Playground - noun: a place where people can play

import Foundation
import UIKit
import MoonKit

UIFont.fontFamilyAvailable("FontAwesome")

let checkbox = LabeledCheckbox(title: "Highlighted", font: nil, autolayout: false)
checkbox.frame = CGRect(size: CGSize(width: 200, height: 34))
checkbox.backgroundColor = UIColor.whiteColor()
checkbox.setNeedsDisplay()
checkbox.checked = true