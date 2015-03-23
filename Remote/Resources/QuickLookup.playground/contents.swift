// Playground - noun: a place where people can play

import Foundation
import CoreData

@objc protocol Model { var uuid: String { get } }
@objc protocol Named { var name: String { get } }
@objc protocol DynamicallyNamed: Named { var name: String { get set } }
typealias NamedModel = protocol<Model, DynamicallyNamed>
@objc protocol BankModel: NamedModel { var user: Bool { get } }

protocol Container {
  typealias ItemType
//  var items: [ItemType] { get set }
  func items<C:Containable where C == ItemType>() -> C
}

protocol Containable {
  typealias ContainerType: Container
  var container: ContainerType? { get set }
}

protocol NestingContainer: Container {
  typealias NestedType: Container, Containable
  var subcontainers: [NestedType] { get set }
}

typealias BankCategory = protocol<BankModel, NestingContainer>

"wtf"