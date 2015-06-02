//
//  BankCollectionDetailLabeledImageCell.swift
//  Remote
//
//  Created by Jason Cardwell on 11/28/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

final class BankCollectionDetailLabeledImageCell: BankCollectionDetailCell {

  var placeholderImage: UIImage? {
    didSet {
      if preview.image == nil && placeholderImage != nil {
        setPreviewImage(placeholderImage)
        preview.tintColor = UIColor.lightGrayColor()
      }
    }
  }

  /**
  setPreviewImage:

  :param: image UIImage?
  */
  private func setPreviewImage(image: UIImage?) {
    preview.image = image
    if image != nil { preview.contentMode = bounds.size.contains(image!.size) ? .Center : .ScaleAspectFit }
  }

  override func initializeIVARs() {
    contentView.addSubview(nameLabel)
    contentView.addSubview(preview)
    contentView.constrain(𝗛|-nameLabel--preview-|𝗛, 𝗩|-nameLabel-|𝗩, 𝗩|-preview-|𝗩)
  }

  /** prepareForReuse */
  override func prepareForReuse() {
    super.prepareForReuse()
    nameLabel.text = nil
    preview.image = nil
    preview.contentMode = .ScaleAspectFit
    preview.tintColor = UIColor.blackColor()
  }

  override var info: AnyObject? {
    didSet { setPreviewImage((info as? Previewable)?.preview ?? info as? UIImage ?? placeholderImage) }
  }

  private let preview: UIImageView = {
    let view = UIImageView()
    view.setTranslatesAutoresizingMaskIntoConstraints(false)
    view.userInteractionEnabled = false
    view.contentMode = .ScaleAspectFit
    view.tintColor = UIColor.blackColor()
    view.backgroundColor = UIColor.clearColor()
    return view

  }()


}
