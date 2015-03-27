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

  /**
  removeSegmentAtIndex:animated:

  :param: segment Int
  :param: animated Bool
  */
  public override func removeSegmentAtIndex(segment: Int, animated: Bool) {
    super.removeSegmentAtIndex(segment, animated: animated)
    precondition(defaultImages.count > segment && selectedImages.count > segment,
                 "we should have had images in our arrays for the segment to remove")
    defaultImages.removeAtIndex(segment)
    selectedImages.removeAtIndex(segment)
  }

  /** removeAllSegments */
  public override func removeAllSegments() {
    super.removeAllSegments()
    defaultImages.removeAll(keepCapacity: false)
    selectedImages.removeAll(keepCapacity: false)
  }

  /**
  insertSegmentWithImage:selectedImage:atIndex:animated:

  :param: image UIImage
  :param: selectedImage UIImage
  :param: segment Int
  :param: animated Bool
  */
  public func insertSegmentWithImage(image: UIImage, selectedImage: UIImage, atIndex segment: Int, animated: Bool) {
    super.insertSegmentWithImage(image, atIndex: segment, animated: animated)
    defaultImages.insert(image, atIndex: segment)
    selectedImages.insert(selectedImage, atIndex: segment)
  }

  /**
  insertSegmentWithImage:atIndex:animated:

  :param: image UIImage
  :param: segment Int
  :param: animated Bool
  */
  public override func insertSegmentWithImage(image: UIImage, atIndex segment: Int, animated: Bool) {
    // Disallow setting only one image
  }

  /**
  insertSegmentWithTitle:atIndex:animated:

  :param: title String!
  :param: segment Int
  :param: animated Bool
  */
  public override func insertSegmentWithTitle(title: String!, atIndex segment: Int, animated: Bool) {
    // Disallow segments with titles for now
  }

  /**
  initWithFrame:

  :param: frame CGRect
  */
  override init(frame: CGRect) {
    super.init(frame: frame)
    UIGraphicsBeginImageContextWithOptions(frame.size, false, 0.0)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    setBackgroundImage(image, forState: .Normal, barMetrics: .Default)
    addTarget(self, action: "toggleImage:", forControlEvents: .ValueChanged)
  }

  /**
  initWithItems:

  :param: items [AnyObject]!
  */
  override public init(items: [AnyObject]) {
    var defaultImages: [UIImage]?
    var selectedImages: [UIImage]?
    if let images = items as? [UIImage] {
      defaultImages = []
      for idx in stride(from: 0, to: items.count, by: 2) { defaultImages!.append(images[idx]) }
      selectedImages = []
      for idx in stride(from: 1, to: items.count, by: 2) { selectedImages!.append(images[idx]) }
    }

    if defaultImages == nil || selectedImages == nil || defaultImages!.count != selectedImages!.count {
      defaultImages = nil
      selectedImages = nil
    }

    super.init(items: defaultImages!)

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

    addTarget(self, action: "toggleImage:", forControlEvents: .ValueChanged)

  }

  public var toggleAction: ((ToggleImageSegmentedControl) -> Void)?

  /**
  initWithItems:action:

  :param: items [AnyObject]!
  :param: action ((ToggleImageSegmentedControl) -> Void)? = nil
  */
//  public convenience init?(items: [AnyObject]!, action: ((ToggleImageSegmentedControl) -> Void)? = nil) {
//    self.init(items: items)
//    toggleAction = action
//  }

  /**
  initWithCoder:

  :param: aDecoder NSCoder
  */
  required public init(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
  }

  /** toggleImage */
  func toggleImage(sender: ToggleImageSegmentedControl?) {
    if previouslySelectedSegmentIndex != UISegmentedControlNoSegment {
      super.setImage(defaultImages[previouslySelectedSegmentIndex], forSegmentAtIndex: previouslySelectedSegmentIndex)
    }
    previouslySelectedSegmentIndex = selectedSegmentIndex
    if selectedSegmentIndex != UISegmentedControlNoSegment {
      super.setImage(selectedImages[selectedSegmentIndex], forSegmentAtIndex: selectedSegmentIndex)
    }
    if sender != nil { toggleAction?(self) }
  }

  /**
  setImage:selectedImage:forSegmentAtIndex:

  :param: image UIImage?
  :param: selectedImage UIImage?
  :param: segment Int
  */
  public func setImage(image: UIImage?, selectedImage: UIImage?, forSegmentAtIndex segment: Int) {
    if segment < numberOfSegments {
      defaultImages[segment] = image
      selectedImages[segment] = selectedImage
      super.setImage(segment == selectedSegmentIndex ? selectedImage : image, forSegmentAtIndex: segment)
    }
  }

  override public var selectedSegmentIndex: Int {
    didSet {
      toggleImage(nil)
    }
  }

}
