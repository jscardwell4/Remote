//
//  BlurDecoration.swift
//  Remote
//
//  Created by Jason Cardwell on 5/28/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class BlurDecoration: UICollectionReusableView {

  static let kind = "Blur"

  private weak var blur: UIVisualEffectView!

  private func createBlurWithStyle(style: UIBlurEffectStyle) {
    self.blur?.removeFromSuperview()
    let blur = UIVisualEffectView(effect: UIBlurEffect(style: style))
    blur.translatesAutoresizingMaskIntoConstraints = false
    addSubview(blur)
    constrain(𝗩|blur|𝗩, 𝗛|blur|𝗛)
    self.blur = blur
  }

  private func setup() {
    backgroundColor = UIColor.clearColor()
    createBlurWithStyle(.Dark)
  }

  override init(frame: CGRect) { super.init(frame: frame); setup() }
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder); setup() }
}
