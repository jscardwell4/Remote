//
//  ItemCellZoom.swift
//  Remote
//
//  Created by Jason Cardwell on 6/1/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import UIKit
import MoonKit

class ItemCellZoom: UICollectionReusableView {

  var image: UIImage? {
    didSet {
      imageView.image = image
      if let size = image?.size {
        let ratio = Ratio(size: size)
        let width = min(size.width, bounds.width)
        let height = ratio.denominatorForNumerator(width)
        imageView.removeAllConstraints()
        imageView.constrain(imageView.width => width, imageView.height => height)
      }
      imageView.sizeToFit()
    }
  }

  var action: (() -> Void)?
  func handleTap() { action?() }

  private weak var imageView: UIImageView!

  private func setup() {
    let imageView = UIImageView(autolayout: true)
    imageView.tintColor = UIColor.blackColor()
    imageView.contentMode = .ScaleAspectFit
    addSubview(imageView)
    constrain(imageView.centerX => centerX, imageView.centerY => centerY)
    self.imageView = imageView
    addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap"))
  }

  override init(frame: CGRect) { super.init(frame: frame); setup() }
  required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder); setup() }

  /** prepareForReuse */
  override func prepareForReuse() { image = nil }

}
