//
//  DataModelProtocols.swift
//  Remote
//
//  Created by Jason Cardwell on 3/26/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc public protocol Model {
  var uuid: String { get }
  var managedObjectContext: NSManagedObjectContext? { get }
  var index: ModelIndex { get }
}

public protocol PathIndexedModel: Model {
  var pathIndex: PathIndex { get }
  static func modelWithIndex(index: PathIndex, context: NSManagedObjectContext) -> Self?
}

public typealias NamedModel = protocol<Model, DynamicallyNamed>

@objc public protocol Editable {
  func save()
  func delete()
  func rollback()
  var editable: Bool { get }
}

@objc public protocol EditableModel: Model, Editable {
  var user: Bool { get }
}

@objc public protocol ModelCollection: NamedModel {
  optional var items: [NamedModel] { get }
}

@objc public protocol NestingModelCollection: ModelCollection {
  optional var collections: [ModelCollection] { get }
}