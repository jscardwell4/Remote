//
//  InlinePickerView.swift
//  MSKit
//
//  Created by Jason Cardwell on 10/14/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit


public class InlinePickerView: UIView {


  /**
  initWithFrame:

  - parameter frame: CGRect
  */
  override public init(frame: CGRect) { super.init(frame: frame); initializeIVARs() }

  /**
  init:

  - parameter aDecoder: NSCoder
  */
  required public init(coder aDecoder: NSCoder) { super.init(coder: aDecoder); initializeIVARs() }

  /** initializeIVARs */
  private func initializeIVARs() {
    setContentCompressionResistancePriority(750, forAxis: .Horizontal)
    setContentCompressionResistancePriority(1000, forAxis: .Vertical)
    translatesAutoresizingMaskIntoConstraints = false
    nametag = "picker"

    addSubview(collectionView)
    collectionView.nametag = "collectionView"
    (collectionView.collectionViewLayout as! InlinePickerViewLayout).delegate = self
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.bounces = false
    collectionView.backgroundColor = UIColor.clearColor()
    collectionView.decelerationRate = UIScrollViewDecelerationRateFast
    collectionView.registerClass(InlinePickerViewCell.self, forCellWithReuseIdentifier: "Cell")
    collectionView.reloadData()
  }

  override public func updateConstraints() {
    removeAllConstraints()
    super.updateConstraints()
    constrain(𝗛|collectionView|𝗛, 𝗩|collectionView|𝗩)
    constrain(height ≥ itemHeight)
  }

  private let collectionView = UICollectionView(frame: CGRect.zeroRect, collectionViewLayout: InlinePickerViewLayout())

  override public class func requiresConstraintBasedLayout() -> Bool { return true }
  override public func intrinsicContentSize() -> CGSize {
    let size = CGSize(width: itemWidths.sum + itemPadding * max(CGFloat(labels.count - 1), 0), height: itemHeight)
    MSLogDebug("intrinsicContentSize = \(size)")
    return size
  }

  override public var description: String {
    return super.description + "\n\t" + "\n\t".join(
      "labels = \(labels)",
      "constraints: \n\t" + "\n\t".join(constraints.map({$0.prettyDescription})),
      "collectionView = \(collectionView.description)",
      "collectionView.constraints: \n\t" + "\n\t".join(collectionView.constraints.map({$0.prettyDescription})),
      "visible cells = \(collectionView.visibleCells())"
    )
  }

  /**
  selectItem:animated:

  - parameter item: Int
  - parameter animated: Bool
  */
  public func selectItem(item: Int, animated: Bool) {
    guard selection != item && (0..<labels.count).contains(item) else { return }
    selection = item
    collectionView.selectItemAtIndexPath(NSIndexPath(forItem: selection, inSection: 0),
                                animated: false,
                          scrollPosition: .None)
    if let layout = collectionView.collectionViewLayout as? InlinePickerViewLayout {
      let offset = layout.offsetForItemAtIndex(selection)
      MSLogDebug("cell for item \(selection) with label '\(labels[item]) where offset = \(offset)")
      collectionView.setContentOffset(offset, animated: animated)
    }
  }

  public var labels: [String] = [] {
    didSet {
      refresh()
      if labels.count > 0 {
        setNeedsLayout()
        layoutIfNeeded()
//        collectionView.setNeedsLayout()
//        collectionView.layoutIfNeeded()
        selectItem(0, animated: true)
      }
    }
  }
  public var didSelectItem: ((InlinePickerView, Int) -> Void)?

  public var font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody) {
    didSet {
      (collectionView.visibleCells() as? [InlinePickerViewCell])?.apply {
        [unowned font = self.font] in
        if let text = $0.text { $0.text = text | font }
      }
      if   font.pointSize > selectedFont.pointSize
        || (oldValue.pointSize > selectedFont.pointSize && oldValue.pointSize > font.pointSize)
      {
        refresh()
      }
    }
  }

  public var textColor = UIColor.darkTextColor() {
    didSet {
      (collectionView.visibleCells() as? [InlinePickerViewCell])?.apply {
        [unowned textColor = self.textColor] in
        if let text = $0.text { $0.text = text | textColor }
      }
    }
  }
  public var selectedFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody) {
    didSet {
      (collectionView.visibleCells() as? [InlinePickerViewCell])?.apply {
        [unowned selectedFont = self.selectedFont] in
        if let selectedText = $0.selectedText { $0.selectedText = selectedText | selectedFont }
      }
      if    selectedFont.pointSize > font.pointSize
        || (oldValue.pointSize > font.pointSize && oldValue.pointSize > selectedFont.pointSize)
      {
        refresh()
      }
    }
  }

  public var selectedTextColor = UIColor.darkTextColor() {
    didSet {
      (collectionView.visibleCells() as? [InlinePickerViewCell])?.apply {
        [unowned selectedTextColor = self.selectedTextColor] in
        if let selectedText = $0.selectedText { $0.selectedText = selectedText | selectedTextColor }
      }
    }
  }

  private func refresh() {
    invalidateIntrinsicContentSize()
    collectionView.collectionViewLayout.invalidateLayout()
    collectionView.setNeedsUpdateConstraints()
    collectionView.setNeedsLayout()
    setNeedsUpdateConstraints()
    setNeedsLayout()
  }

  public func reloadData() {
    collectionView.collectionViewLayout.invalidateLayout()
    collectionView.reloadData()
  }

  public var itemHeight: CGFloat { return ceil(max(font.lineHeight, selectedFont.lineHeight)) * 2 }
  public var itemPadding: CGFloat = 8.0 {
    didSet {
      refresh()
    }
  }

  var itemWidths: [CGFloat] { return labels.map {[a = [NSFontAttributeName:font]] in ceil($0.sizeWithAttributes(a).width)} }

  private var selection: Int = -1
}

// MARK: - UICollectionViewDataSource
extension InlinePickerView: UICollectionViewDataSource {


  public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return labels.count }

  public func collectionView(collectionView: UICollectionView,
      cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
  {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! InlinePickerViewCell
    let text = labels[indexPath.item]
    cell.text = text ¶| [font, textColor]
    cell.selectedText = text ¶| [selectedFont, selectedTextColor]
    return cell
  }
}

// MARK: - UICollectionViewDelegate
extension InlinePickerView: UICollectionViewDelegate {

  public func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
  }

  public func collectionView(collectionView: UICollectionView, shouldDeselectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
  }

  public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    MSLogDebug("")
    didSelectItem?(self, indexPath.item)
  }

//  public func collectionView(collectionView: UICollectionView,
//             willDisplayCell cell: UICollectionViewCell,
//          forItemAtIndexPath indexPath: NSIndexPath)
//  {
//    if cell.selected, let layout = collectionView.collectionViewLayout as? InlinePickerViewLayout {
//      let offset = layout.offsetForItemAtIndex(indexPath.item)
//      MSLogDebug("cell for item \(indexPath.item) with label '\(labels[indexPath.item]) where offset = \(offset)")
//      collectionView.setContentOffset(offset, animated: false)
//    }
//  }

}

extension InlinePickerView: UIScrollViewDelegate {
  public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    MSLogDebug("")
    guard let item = collectionView.indexPathsForSelectedItems()?.first?.item else {
      MSLogWarn("failed to get index path for selected cell")
      return
    }
    // invoke selection handler
    didSelectItem?(self, item)
  }
  public func scrollViewWillEndDragging(scrollView: UIScrollView,
                          withVelocity velocity: CGPoint,
                   targetContentOffset: UnsafeMutablePointer<CGPoint>)
  {
    MSLogDebug("")
    let offset = targetContentOffset.memory
    guard let item = (collectionView.collectionViewLayout as! InlinePickerViewLayout).indexOfItemAtOffset(offset) else {
      MSLogWarn("failed to get index path for cell at point \(offset)")
      return
    }
    // update selection
    MSLogDebug("selecting item \(item)")
    collectionView.selectItemAtIndexPath(NSIndexPath(forItem: item, inSection: 0), animated: false, scrollPosition:.None)
  }
}