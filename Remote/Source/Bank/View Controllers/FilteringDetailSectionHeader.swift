//
//  FilteringDetailSectionHeader.swift
//  Remote
//
//  Created by Jason Cardwell on 12/12/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class FilteringDetailSectionHeader: DetailSectionHeader {

  private var checkBoxContainer = UIView(autolayout: true)

  /**
  init:

  :param: reuseIdentifier String?
  */
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    contentView.addSubview(checkBoxContainer)
    contentView.constrain("[container]-| :: container.centerY = self.centerY + 3", views: ["container": checkBoxContainer])

  }

  var labels: [String]? {
    didSet {
      if labels == nil { apply(checkBoxContainer.subviews){$0.removeFromSuperview()} }
      else {
        let font = UIFont(name: "Elysio-Medium", size: 12)!
        let color = UIColor(red: 0.937, green: 0.937, blue: 0.957, alpha: 1.000)
        let labeledCheckboxes: [LabeledCheckbox] = labels!.map{
          let view = LabeledCheckbox(title: $0, font: font, autolayout: true)
          view.titleColor = color
          view.checkboxColor = color
          return view
        }
        apply(labeledCheckboxes){self.checkBoxContainer.addSubview($0)}
        let views: OrderedDictionary<String, UIView> = OrderedDictionary(keys: (0..<labeledCheckboxes.count).map{"view\($0)"},
                                                                         values: labeledCheckboxes)
        let format = "|-" + "-8-".join(views.keys.map{"[\($0)]"}) + "-| :: " + "::".join(views.keys.map{"V:|-[\($0)]|"})
        checkBoxContainer.constrain(format, views: views.dictionary)
      }
    }
  }

  /**
  initWithFrame:

  :param: frame CGRect
  */
  override init(frame: CGRect) { super.init(frame: frame) }

  /**
  initWithCoder:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  /** prepareForReuse */
  override func prepareForReuse() { labels = nil; super.prepareForReuse() }

}
