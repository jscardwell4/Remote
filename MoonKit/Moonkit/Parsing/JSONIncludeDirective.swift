//
//  JSONIncludeDirective.swift
//  MoonKit
//
//  Created by Jason Cardwell on 4/17/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation

internal class JSONIncludeDirective {
  let location: Range<Int>
  let file: IncludeFile!

  private let _parameters: String?
  var parameters: [String:String]? {
    if let p = _parameters {
      return Dictionary(",".split(p).map({disperse2("=".split($0))}))
    } else { return nil }
  }

  static func emptyCache() { cache = [:] }
  static var cacheSize: Int { return cache.count }
  private static var cache: [String:String] = [:]

  let subdirectives: [JSONIncludeDirective]

  init?(_ string: String, location loc: Range<Int>, directory: String) {
    location = loc
    let captures = string.matchFirst("<@include\\s+([^>]+\\.json)(?:,([^>]+))?>")
    assert(captures.count == 2, "unexpected number of capture groups for regular expression")
    _parameters = captures[1]
    if let fileName = captures[0], includeFile = IncludeFile("\(directory)/\(fileName)") {
      file = includeFile
      subdirectives = JSONIncludeDirective.parseDirectives(file.content, directory: directory)
    } else { file = nil; subdirectives = []; return nil }
  }

  static func stringByParsingDirectivesInString(string: String, directory: String) -> String {
    var result = ""
    var i = 0
    for directive in parseDirectives(string, directory: directory) {
      result += string[i..<directive.location.startIndex]
      result += directive.content
      i = directive.location.endIndex
    }
    if i < string.length { result += string[i..<string.length] }
    return result
  }

  private static func parseDirectives(string: String, directory: String) -> [JSONIncludeDirective] {
    let ranges = compressed(string.rangesForCapture(1, byMatching: ~/"(<@include[^>]+>)"))
    let directives = compressedMap(ranges, transform: {JSONIncludeDirective(string[$0], location: $0, directory: directory)})
    return directives
  }

  var description: String {
    var result = "\n".join(
      "location: \(location)",
      "parameters: \(toString(parameters))",
      "file: \(file.path.lastPathComponent)"
    )
    if subdirectives.count == 0 { result += "\nsubdirectives: []" }
    else { result += "\nsubdirectives: {\n" + "\n\n".join(subdirectives.map({$0.description})).indentedBy(4) + "\n}" }
    return result
  }

  var content: String {
    if let cachedContent = JSONIncludeDirective.cache["\(file.path),\(toString(_parameters))"] {
      return cachedContent
    }
    var result: String = ""
    let fileContent = file.content
    if subdirectives.count == 0 { result = fileContent }
    else {
      var i = 0
      for subdirective in subdirectives.sort({$0.location.startIndex < $1.location.startIndex}) {
        result += fileContent[i..<subdirective.location.startIndex]
        result += subdirective.content
        i = subdirective.location.endIndex
      }
      if i < fileContent.length { result += fileContent[i..<fileContent.length] }
    }
    if let p = parameters {
      result = p.reduce(result, combine: {$0.stringByReplacingOccurrencesOfString("<#\($1.0)#>", withString: $1.1)})
    }
    JSONIncludeDirective.cache["\(file.path),\(toString(_parameters))"] = result
    return result
  }

  struct IncludeFile {

    let path: String
    let content: String
    private(set) lazy var parameters: Set<String> = {
      return Set(flattened(self.content.matchAll(~/"<#([A-Z]+)#>").map({compressed($0)})))
      }()

    init?(_ p: String) {
      if let cached = IncludeFile.cache[p] { self = cached }
      else if NSFileManager.defaultManager().isReadableFileAtPath(p),
        let c = String(contentsOfFile: p, encoding: NSUTF8StringEncoding)
      {
        path = p; content = c; IncludeFile.cache[p] = self
      } else { path = ""; content = ""; return nil }
    }

    private static var cache: [String:IncludeFile] = [:]
  }

}

