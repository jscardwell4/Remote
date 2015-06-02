//
//  DetailImageCell.swift
//  Remote
//
//  Created by Jason Cardwell on 10/21/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class DetailImageCell: DetailCell {

  var imageTint: UIColor? { didSet { preview.tintColor = imageTint } }

  /**
  initWithStyle:reuseIdentifier:

  :param: style UITableViewCellStyle
  :param: reuseIdentifier String?
  */
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(preview)
    backgroundView = nil
    backgroundColor = UIColor.clearColor()
    contentView.backgroundColor = UIColor.clearColor()
    contentView.constrain(𝗛|preview|𝗛, 𝗩|preview|𝗩)
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

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
    view.setTranslatesAutoresizingMaskIntoConstraints(false)
    view.userInteractionEnabled = false
    view.contentMode = .ScaleAspectFit
    view.tintColor = UIColor.blackColor()
    view.backgroundColor = UIColor.clearColor()
    return view

  }()


}
