//
//  Form.swift
//  Remote
//
//  Created by Jason Cardwell on 5/18/15.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation

public class Form {

  public var fields: OrderedDictionary<String, Field>
  public var changeHandler: ((Form, Field, String) -> Void)?

  public init(templates: OrderedDictionary<String, FieldTemplate>) {
    fields = templates.map {Field.fieldWithTemplate($2)}
    apply(fields) {$2.changeHandler = self.didChangeField}
  }

  func didChangeField(field: Field) { if let name = nameForField(field) { changeHandler?(self, field, name) } }

  func nameForField(field: Field) -> String? {
    if let idx = find(fields.values, field) { return fields.keys[idx] } else { return nil }
  }

  public var invalidFields: [(Int, String, Field)] {
    var result: [(Int, String, Field)] = []
    for (idx, name, field) in fields { if !field.valid { result.append((idx, name, field)) } }
    return result
  }

  public var values: OrderedDictionary<String, Any> {
    var values: OrderedDictionary<String, Any> = [:]
    for (_, name, field) in fields {
      if field.valid, let value: Any = field.value {
        values[name] = value
      } else {
        return nil
      }
    }
    return values
  }

}