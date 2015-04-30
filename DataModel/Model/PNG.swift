//
//  PNG.swift
//  Remote
//
//  Created by Jason Cardwell on 4/22/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@objc(PNG)
final class PNG: ModelObject {

  @NSManaged var image: UIImage
  @NSManaged var previewDataForPreset: Preset

}
