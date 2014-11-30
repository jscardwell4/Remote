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
      if info != nil {
        if let previewableItem = info as? PreviewableItem {
          let previewImage = previewableItem.preview
          preview.image = previewImage
          preview.contentMode = bounds.size.contains(previewImage.size) ? .Center : .ScaleAspectFit
        } else { preview.image = nil; info = nil }
      } else { preview.image = nil }
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
