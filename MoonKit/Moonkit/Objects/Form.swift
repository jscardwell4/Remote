//
//  Form.swift
//  MoonKit
//
//  Created by Jason Cardwell on 8/4/15.
//  Copyright © 2015 Jason Cardwell. All rights reserved.
//

import Foundation

public final class Form: NSObject {

  public typealias ChangeHandler = (Form, Field, String) -> Void

  public var fields: OrderedDictionary<String, Field>
  public var changeHandler: ChangeHandler?

  /**
  initWithTemplates:

  - parameter templates: OrderedDictionary<String, FieldTemplate>
  */
  public init(templates: OrderedDictionary<String, Field.Template>) {
    fields = templates.map {Field.fieldWithTemplate($2)}
    super.init()
    apply(fields) {$2.changeHandler = self.didChangeField}
  }

  /**
  didChangeField:

  - parameter field: Field
  */
  func didChangeField(field: Field) { if let name = nameForField(field) { changeHandler?(self, field, name) } }

  /**
  nameForField:

  - parameter field: Field

  - returns: String?
  */
  func nameForField(field: Field) -> String? {
    if let idx = fields.values.indexOf(field) { return fields.keys[idx] } else { return nil }
  }

  public var invalidFields: [(Int, String, Field)] {
    var result: [(Int, String, Field)] = []
    for (idx, name, field) in fields { if !field.valid { result.append((idx, name, field)) } }
    return result
  }

  public var valid: Bool { return invalidFields.count == 0 }

  public var values: OrderedDictionary<String, Any>? {
    var values: OrderedDictionary<String, Any> = [:]
    for (_, n, f) in fields { if f.valid, let value: Any = f.value { values[n] = value } else { return nil } }
    return values
  }

  public override var description: String {
    return "Form: {\n\t" + "\n\t".join(fields.map {"\($0): \($1) = \(String($2.value))"}) + "\n}"
  }

}

