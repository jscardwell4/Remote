//
//  ImageView.swift
//  Remote
//
//  Created by Jason Cardwell on 10/3/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(ImageView)
class ImageView: ModelObject {

  @NSManaged var color: UIColor?
  @NSManaged var image: Image?

  @NSManaged var buttonIcon: Button?
  @NSManaged var buttonImage: Button?
  @NSManaged var imageSetDisabled: ControlStateImageSet?
  @NSManaged var imageSetDisabledSelected: ControlStateImageSet?
  @NSManaged var imageSetHighlighted: ControlStateImageSet?
  @NSManaged var imageSetHighlightedDisabled: ControlStateImageSet?
  @NSManaged var imageSetHighlightedSelected: ControlStateImageSet?
  @NSManaged var imageSetNormal: ControlStateImageSet?
  @NSManaged var imageSetSelected: ControlStateImageSet?
  @NSManaged var imageSetSelectedHighlightedDisabled: ControlStateImageSet?


  var rawImage: UIImage?

  var colorImage: UIImage?

}
