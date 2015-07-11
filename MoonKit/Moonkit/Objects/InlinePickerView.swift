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
  required public init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder); initializeIVARs() }

  /** initializeIVARs */
  private func initializeIVARs() {
    setContentCompressionResistancePriority(750, forAxis: .Horizontal)
    setContentCompressionResistancePriority(1000, forAxis: .Vertical)
    translatesAutoresizingMaskIntoConstraints = false
    nametag = "picker"

    addSubview(collectionView)
    collectionView.nametag = "collectionView"
    layout.delegate = self
    collectionView.scrollEnabled = false
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
  private var layout: InlinePickerViewLayout { return collectionView.collectionViewLayout as! InlinePickerViewLayout }

  override public class func requiresConstraintBasedLayout() -> Bool { return true }
  override public func intrinsicContentSize() -> CGSize { return CGSize(width: UIViewNoIntrinsicMetric, height: itemHeight) }

  override public var description: String {
    return super.description + "\n\t" + "\n\t".join(
      "labels = \(labels)",
      "collectionView = \(collectionView.description)",
      "collectionViewLayout = \(collectionView.collectionViewLayout.description)"
    )
  }

  /**
  selectItem:animated:

  - parameter item: Int
  - parameter animated: Bool
  */
  public func selectItem(item: Int, animated: Bool) {
    guard (0..<labels.count).contains(item) else { return }
    selection = item
    if let offset = layout.offsetForItemAtIndex(selection) {
      collectionView.selectItemAtIndexPath(NSIndexPath(forItem: selection, inSection: 0),
                                  animated: false,
                            scrollPosition: .None)
      MSLogDebug("selecting cell for item \(selection) with label '\(labels[item]) where offset = \(offset)")
      collectionView.setContentOffset(offset, animated: animated)
    }
  }

  public override func layoutSubviews() {
    super.layoutSubviews()
    if selection > -1 { selectItem(selection, animated: false) }
  }

  public var labels: [String] = [] {
    didSet {
      collectionView.setNeedsLayout()
      collectionView.layoutIfNeeded()
      if labels.count > 0 && selection < 0 { selection = 0 }
      setNeedsLayout()
      layoutIfNeeded()
      reloadData()
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
        reloadData()
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
        reloadData()
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

  public func reloadData() {
    collectionView.collectionViewLayout.invalidateLayout()
    collectionView.reloadData()
    layoutIfNeeded()
    if selection > -1 { selectItem(selection, animated: false) }
  }

  public var itemHeight: CGFloat { return ceil(max(font.lineHeight, selectedFont.lineHeight)) * 2 }
  public var itemPadding: CGFloat = 8.0 { didSet { reloadData() } }

  var itemWidths: [CGFloat] { return labels.map {[a = [NSFontAttributeName:font]] in ceil($0.sizeWithAttributes(a).width)} }

  var selection: Int = -1

  public var selectedItemFrame: CGRect? {
    if selection > -1,
      let cell = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: selection, inSection: 0)) where cell.selected
    {
      var frame = cell.frame
      frame.origin = frame.origin - collectionView.contentOffset
      return frame
    } else { return nil }
  }

  public var editing = false {
    didSet {
      layout.invalidateLayout()
//      setNeedsLayout()
//      layoutIfNeeded()
      collectionView.scrollEnabled = editing
    }
  }
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

}

extension InlinePickerView: UIScrollViewDelegate {
  public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
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
    let offset = targetContentOffset.memory
    guard let item = (collectionView.collectionViewLayout as! InlinePickerViewLayout).indexOfItemAtOffset(offset) else {
      MSLogWarn("failed to get index path for cell at point \(offset)")
      return
    }
    // update selection
    MSLogDebug("selecting cell for item \(selection) with label '\(labels[item]) where offset = \(offset)")
    selection = item
    collectionView.selectItemAtIndexPath(NSIndexPath(forItem: item, inSection: 0), animated: false, scrollPosition:.None)
  }
}