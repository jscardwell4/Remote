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

class DetailLabeledImageCell: DetailCell {

  var placeholderImage: UIImage?

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
    didSet {
      var previewImage = (info as? PreviewableItem)?.preview ?? info as? UIImage ?? placeholderImage

      if previewImage != nil {
        preview.image = previewImage
        preview.contentMode = bounds.size.contains(previewImage!.size) ? .Center : .ScaleAspectFit
      } else {
        preview.image = nil
        info = nil
      }
    }
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
