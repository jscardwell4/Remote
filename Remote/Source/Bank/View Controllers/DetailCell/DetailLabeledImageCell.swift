//
//  DetailLabeledImageCell.swift
//  Remote
//
//  Created by Jason Cardwell on 11/28/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

final class DetailLabeledImageCell: DetailCell {

  var placeholderImage: UIImage? {
    didSet { if preview.image == nil && placeholderImage != nil { setPreviewImage(placeholderImage) } }
  }

  /**
  setPreviewImage:

  :param: image UIImage?
  */
  private func setPreviewImage(image: UIImage?) {
    preview.image = image
    if image != nil {
      preview.contentMode = bounds.size.contains(image!.size) ? .Center : .ScaleAspectFit
    }
  }

  /**
  initWithStyle:reuseIdentifier:

  :param: style UITableViewCellStyle
  :param: reuseIdentifier String?
  */
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(nameLabel)
    contentView.addSubview(preview)
    contentView.constrain("|-[name]-[image]-| :: V:|-[name]-| :: V:|-[image]-|", views: ["name": nameLabel, "image": preview])
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  /** prepareForReuse */
  override func prepareForReuse() {
    super.prepareForReuse()
    nameLabel.text = nil
    preview.image = nil
    preview.contentMode = .ScaleAspectFit
  }

  override var info: AnyObject? {
    didSet { setPreviewImage((info as? PreviewableItem)?.preview ?? info as? UIImage ?? placeholderImage) }
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
