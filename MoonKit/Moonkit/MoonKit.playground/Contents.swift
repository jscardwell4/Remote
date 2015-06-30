//: Playground - noun: a place where people can play
import Foundation
import UIKit
import MoonKit

"v1".camelcaseString
let v1 = UIView(autolayout: true)
v1.backgroundColor = UIColor.yellowColor()
v1.nametag = "v1"
v1.nametag
let v2 = UIView(autolayout: true)
v2.backgroundColor = UIColor.redColor()
v2.nametag = "v2"
let parent = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
parent.nametag = "parent"
parent.backgroundColor = UIColor.blackColor()
parent.translatesAutoresizingMaskIntoConstraints = false
parent.addSubview(v1)
parent.addSubview(v2)
// Need to fix the following case that crashes with bad access
//parent.constrain(𝗛|--8--v1--8--v2--8--|𝗛)
let identifier = createIdentifierGenerator("View")
let pseudo = [
  𝗛|--8--v1--8--|𝗛 --> identifier("V1", "Spacing", "Horiziontal"),
  [
    v1.height => parent.height * 0.5 --> identifier("V1", "Height"),
    v1.top => parent.top --> identifier("V1", "Top"),
    v2.width => parent.width * 0.5 --> identifier("V2", "Width"),
    v2.left => parent.left --> identifier("V2", "Left"),
    v2.height => parent.height * 0.5 --> identifier("V2", "Height"),
    v2.bottom => parent.bottom --> identifier("V2", "Bottom")
  ]
  ].flatMap {$0}
let pseudoDescriptions = pseudo.map{$0.description}
print("\n".join(pseudoDescriptions))
let constraints: [NSLayoutConstraint] = pseudo.map{(p: Pseudo) -> NSLayoutConstraint in return p.constraint!}
print("\n".join(constraints.map{toString($0)}))
parent.constrain(
  𝗛|--8--v1--8--|𝗛 --> identifier("V1", "Spacing", "Horiziontal"),
  [
    v1.height => parent.height * 0.5 --> identifier("V1", "Height"),
    v1.top => parent.top --> identifier("V1", "Top"),
    v2.width => parent.width * 0.5 --> identifier("V2", "Width"),
    v2.left => parent.left --> identifier("V2", "Left"),
    v2.height => parent.height * 0.5 --> identifier("V2", "Height"),
    v2.bottom => parent.bottom --> identifier("V2", "Bottom")
  ]
)
print("\n".join((parent.constraints).map({$0.description})))
print("")
print("\n".join((parent.constraints).map({$0.prettyDescription})))
parent.setNeedsUpdateConstraints()
parent.setNeedsLayout()
parent.layoutIfNeeded()
parent
