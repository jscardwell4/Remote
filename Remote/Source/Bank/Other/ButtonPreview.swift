//
//  ButtonPreview.swift
//  Remote
//
//  Created by Jason Cardwell on 12/16/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class ButtonPreview: RemoteElementPreview {

  // private let labelView = UILabel(autolayout: true)

  private var textStorage: NSTextStorage? { didSet { textStorage?.addLayoutManager(layoutManager) } }
  private let layoutManager = NSLayoutManager()
  private let textContainer: NSTextContainer = {
    let container = NSTextContainer()
    container.lineFragmentPadding = 10.0
    return container
  }()

  override var bounds: CGRect { didSet { textContainer.size = bounds.size } }

  /** init */
//  override init() { super.init() }

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  /**
  initWithPreset:

  :param: preset Preset
  */
  required init(preset: Preset) { super.init(preset: preset) }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  /** initializeViewFromPreset */
  override func initializeViewFromPreset() {
    super.initializeViewFromPreset()

    layoutManager.addTextContainer(textContainer)
    if let titleData = preset.titles?["normal"] {
      textStorage = NSTextStorage(attributedString: TitleAttributes(JSONValue: titleData).string)
    }
    elementBackgroundColor = UIColor(JSONValue: preset.backgroundColors?["normal"] as? String ?? "")
  }

  /** resizeText:toFitContainer */
  private func resizeText() {

    if textStorage == nil { return }

    let wordRanges = compressed(textStorage!.string.rangesForCapture(1, byMatching: ~/"(\\w+)")).map{count($0)}

    let maxWordLength = wordRanges.isEmpty ? 0 : maxElement(wordRanges)

    let maxFragmentLength = {
      () -> Int in
      var maxLength = 0
      self.layoutManager.enumerateLineFragmentsForGlyphRange(NSRange(location: 0, length: self.textStorage!.length)) {
        _, _, _, glyphRange, _ in maxLength = max(maxLength, glyphRange.length)
      }
      return maxLength
    }

    let reduceFontSize = {
      self.textStorage!.enumerateAttribute(NSFontAttributeName, inRange: NSRange(location: 0, length: self.textStorage!.length), options: nil) {
        obj, range, _ in

        if let font = obj as? UIFont {
          self.textStorage!.addAttribute(NSFontAttributeName, value: font.fontWithSize(font.pointSize - 1), range: range)
        }
      }
    }

    let incompleteCoverage = { () -> Bool in self.layoutManager.glyphRangeForTextContainer(self.textContainer).length < self.layoutManager.numberOfGlyphs }

    while maxFragmentLength() < maxWordLength || incompleteCoverage() { reduceFontSize() }


  }


  /**
  drawContentInContext:inRect:

  :param: ctx CGContextRef
  :param: rect CGRect
  */
  override func drawContentInContext(ctx: CGContextRef, inRect rect: CGRect) {
    var image: UIImage?
    if let iconData = preset.icons?["normal"] {
      if let imagePath = iconData["image"] as? String,
        moc = preset.managedObjectContext,
        imageObject = ImageCategory.itemForIndex(imagePath, context: moc) as? Image
      {
        if let color = UIColor(JSONValue: iconData["color"] as? String ?? "") {
          image = UIImage(fromAlphaOfImage: imageObject.image, color: color)
        } else {
          image = imageObject.image
        }
      }
    }

    if image != nil {
      let insets = preset.imageEdgeInsets ?? UIEdgeInsets.zeroInsets
      let insetRect = insets.insetRect(rect)
      let size = insetRect.size.contains(image!.size)
                   ? image!.size
                   : image!.size.aspectMappedToSize(insetRect.size, binding: true)
      let frame = CGRect(origin: CGPoint(x: insetRect.midX - size.width * 0.5,
                                         y: insetRect.midY - size.height * 0.5),
                         size: size)
      image!.drawInRect(frame)
    }

    if textStorage != nil {

      resizeText()

      let boundingRect = rect
      let textSize = layoutManager.usedRectForTextContainer(textContainer).size

//      let xOffset = (boundingRect.width - textSize.width) * 0.25
//      let yOffset = (boundingRect.height - textSize.height) * 0.5
//      let point = CGPoint(x: boundingRect.origin.x + xOffset, y: boundingRect.origin.y + yOffset)

      UIGraphicsPushContext(ctx)
      CGContextTranslateCTM(ctx, (boundingRect.width - textSize.width) * 0.5, (boundingRect.height - textSize.height) * 0.5)

      textStorage!.drawWithRect(CGRect(size: CGSize(width: ceil(textSize.width), height: ceil(textSize.height))), options: .UsesLineFragmentOrigin, context: nil)
      // layoutManager.drawGlyphsForGlyphRange(NSRange(location: 0, length: textStorage!.length), atPoint: CGPoint.zeroPoint)

      UIGraphicsPopContext()
    }

  }


}


