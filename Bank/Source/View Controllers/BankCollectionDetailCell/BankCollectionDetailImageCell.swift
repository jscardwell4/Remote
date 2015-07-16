//
//  BankCollectionDetailImageCell.swift
//  Remote
//
//  Created by Jason Cardwell on 10/21/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class BankCollectionDetailImageCell: BankCollectionDetailCell {

  var imageTint: UIColor? { didSet { preview.tintColor = imageTint } }

  override func initializeIVARs() {
    super.initializeIVARs()
    contentView.addSubview(preview)
    backgroundView = nil
    backgroundColor = UIColor.clearColor()
    contentView.backgroundColor = UIColor.clearColor()
  }

  override func updateConstraints() {
    super.updateConstraints()
    let id = MoonKit.Identifier(self, "Internal")
    if constraintsWithIdentifier(id).count == 0 {
      constrain(𝗛|preview|𝗛 --> id, 𝗩|preview|𝗩 --> id)
    }
  }

  /** prepareForReuse */
  override func prepareForReuse() {
    super.prepareForReuse()
    backgroundColor = UIColor.clearColor()
    contentView.backgroundColor = UIColor.clearColor()
    preview.image = nil
    preview.contentMode = .ScaleAspectFit
  }

  override var info: AnyObject? {
    get { return preview.image }
    set {
      preview.image = newValue as? UIImage
      if let size = (newValue as? UIImage)?.size {
        preview.contentMode = bounds.size.contains(size) ? .Center : .ScaleAspectFit
      }
    }
  }

  private let preview: UIImageView = {
    let view = UIImageView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.userInteractionEnabled = false
    view.contentMode = .ScaleAspectFit
    view.tintColor = UIColor.blackColor()
    view.backgroundColor = UIColor.clearColor()
    return view

  }()


}
