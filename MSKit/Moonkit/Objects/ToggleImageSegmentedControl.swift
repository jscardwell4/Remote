//
//  ToggleImageSegmentedControl.swift
//  MSKit
//
//  Created by Jason Cardwell on 10/6/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//
import Foundation
import UIKit

public class ToggleImageSegmentedControl: UISegmentedControl {

  private var defaultImages:  [UIImage?] = []
  private var selectedImages: [UIImage?] = []
  private var previouslySelectedSegmentIndex = UISegmentedControlNoSegment

  public override func removeSegmentAtIndex(segment: Int, animated: Bool) {
    super.removeSegmentAtIndex(segment, animated: animated)
    precondition(defaultImages.count > segment && selectedImages.count > segment, "we should have had images in our arrays for the segment to remove")
    defaultImages.removeAtIndex(segment)
    selectedImages.removeAtIndex(segment)
  }

  public override func removeAllSegments() {
    super.removeAllSegments()
    defaultImages.removeAll(keepCapacity: false)
    selectedImages.removeAll(keepCapacity: false)
  }

  public func insertSegmentWithImage(image: UIImage, selectedImage: UIImage, atIndex segment: Int, animated: Bool) {
    super.insertSegmentWithImage(image, atIndex: segment, animated: animated)
    defaultImages.insert(image, atIndex: segment)
    selectedImages.insert(selectedImage, atIndex: segment)
  }

  public override func insertSegmentWithImage(image: UIImage, atIndex segment: Int, animated: Bool) {
    // Disallow setting only one image
  }

  public override func insertSegmentWithTitle(title: String!, atIndex segment: Int, animated: Bool) {
    // Disallow segments with titles for now
  }

  // Only override drawRect: if you perform custom drawing.
  // An empty implementation adversely affects performance during animation.
//  override public func drawRect(rect: CGRect) {
    // Drawing code
//  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    UIGraphicsBeginImageContextWithOptions(frame.size, false, 0.0)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    setBackgroundImage(image, forState: .Normal, barMetrics: .Default)
    addTarget(self, action: "toggleImage", forControlEvents: .ValueChanged)
  }

  override public init?(items: [AnyObject]!) {
    var defaultImages: [UIImage]?
    var selectedImages: [UIImage]?
    if let images = items as? [UIImage] {
      defaultImages = collectFrom(images, stride(from: 0, to: items.count, by: 2))
      selectedImages = collectFrom(images, stride(from: 1, to: items.count, by: 2))
    }

    if defaultImages == nil || selectedImages == nil || defaultImages!.count != selectedImages!.count {
      defaultImages = nil
      selectedImages = nil
    }

    super.init(items: defaultImages)

    if defaultImages != nil {
      for i in 0 ..< defaultImages!.count {
        self.defaultImages.append(defaultImages![i])
        self.selectedImages.append(selectedImages![i])
      }
    }

    UIGraphicsBeginImageContextWithOptions(frame.size, false, 0.0)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    setBackgroundImage(image, forState: .Normal, barMetrics: .Default)

    addTarget(self, action: "toggleImage", forControlEvents: .ValueChanged)

  }

  required public init(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
  }

  func toggleImage() {
    if previouslySelectedSegmentIndex != UISegmentedControlNoSegment {
      super.setImage(defaultImages[previouslySelectedSegmentIndex], forSegmentAtIndex: previouslySelectedSegmentIndex)
    }
    previouslySelectedSegmentIndex = selectedSegmentIndex
    if selectedSegmentIndex != UISegmentedControlNoSegment {
      super.setImage(selectedImages[selectedSegmentIndex], forSegmentAtIndex: selectedSegmentIndex)
    }
  }

  public func setImage(image: UIImage?, selectedImage: UIImage?, forSegmentAtIndex segment: Int) {
    if segment < numberOfSegments {
      defaultImages[segment] = image
      selectedImages[segment] = selectedImage
      super.setImage(segment == selectedSegmentIndex ? selectedImage : image, forSegmentAtIndex: segment)
    }
  }

  override public var selectedSegmentIndex: Int {
    didSet {
      toggleImage()
    }
  }

}
