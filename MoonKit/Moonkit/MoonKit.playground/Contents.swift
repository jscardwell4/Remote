//: Playground - noun: a place where people can play
import Foundation
import UIKit
import MoonKit

let indexPath = NSIndexPath(forItem: 3, inSection: 0)
let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
let item = indexPath.item
let contentSize = CGSize(width: 459, height: 30)
let cellWidths: [CGFloat] = [96.0, 26.0, 54.0, 29.0]
let cellPadding: CGFloat = 8.0
let contentPadding: CGFloat = 115.0
let widths = cellWidths[0..<item]
let padding = contentPadding + cellPadding * CGFloat(item)
let xOffset = widths.sum + padding
attributes.frame = CGRect(x: xOffset, y: 0, width: cellWidths[item], height: contentSize.height)

print(attributes.frame)

let maxAngle = CGFloat(M_PI_2)
let visibleRect = CGRect(x: 59, y: 0, width: 191, height: 30)
let distance = attributes.frame.midX - visibleRect.midX
let w = visibleRect.width / 2
let currentAngle = maxAngle * distance / w / CGFloat(M_PI_2)

var transform = CATransform3DIdentity
transform = CATransform3DTranslate(transform, -distance, 0, -w)
transform = CATransform3DRotate(transform, currentAngle, 0, 1, 0)
transform = CATransform3DTranslate(transform, 0, 0, w)

attributes.transform3D = transform
print(attributes.frame)

attributes.transform3D = CATransform3DIdentity
print(attributes.frame)