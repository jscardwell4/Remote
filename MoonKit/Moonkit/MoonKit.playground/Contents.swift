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
parent.setTranslatesAutoresizingMaskIntoConstraints(false)
parent.addSubview(v1)
parent.addSubview(v2)
// Need to fix the following case that crashes with bad access
//parent.constrain(𝗛|--8--v1--8--v2--8--|𝗛)
let identifier = createIdentifierGenerator("View")
let pseudo = [
  𝗛|--8--v1--8--|𝗛 --> identifier(suffixes: "V1", "Spacing", "Horiziontal"),
  [
    v1.height => parent.height * 0.5 --> identifier(suffixes: "V1", "Height"),
    v1.top => parent.top --> identifier(suffixes: "V1", "Top"),
    v2.width => parent.width * 0.5 --> identifier(suffixes: "V2", "Width"),
    v2.left => parent.left --> identifier(suffixes: "V2", "Left"),
    v2.height => parent.height * 0.5 --> identifier(suffixes: "V2", "Height"),
    v2.bottom => parent.bottom --> identifier(suffixes: "V2", "Bottom")
  ]
]
let pseudoDescriptions = flatMap(pseudo) { $0.map{$0.description}}
println("\n".join(pseudoDescriptions))
let constraints = flatMap(pseudo) { $0.map{$0.constraint()}}
println("\n".join(constraints.map{toString($0)}))
parent.constrain(
  𝗛|--8--v1--8--|𝗛 --> identifier(suffixes: "V1", "Spacing", "Horiziontal"),
  [
    v1.height => parent.height * 0.5 --> identifier(suffixes: "V1", "Height"),
    v1.top => parent.top --> identifier(suffixes: "V1", "Top"),
    v2.width => parent.width * 0.5 --> identifier(suffixes: "V2", "Width"),
    v2.left => parent.left --> identifier(suffixes: "V2", "Left"),
    v2.height => parent.height * 0.5 --> identifier(suffixes: "V2", "Height"),
    v2.bottom => parent.bottom --> identifier(suffixes: "V2", "Bottom")
  ]
)
println("\n".join((parent.constraints() as! [NSLayoutConstraint]).map({$0.description})))
println()
println("\n".join((parent.constraints() as! [NSLayoutConstraint]).map({$0.prettyDescription})))
parent.setNeedsUpdateConstraints()
parent.setNeedsLayout()
parent.layoutIfNeeded()
parent
