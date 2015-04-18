//
//  Logging.swift
//  MSKit
//
//  Created by Jason Cardwell on 9/18/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
import CocoaLumberjack

public struct ColorLog {
  public static let ESCAPE = "\u{001b}["

  public static let RESET_FG = ESCAPE + "fg;" // Clear any foreground color
  public static let RESET_BG = ESCAPE + "bg;" // Clear any background color
  public static let RESET = ESCAPE + ";"   // Clear any foreground or background color

  public static func red<T>(object:T) {
    println("\(ESCAPE)fg255,0,0;\(object)\(RESET)")
  }

  public static func green<T>(object:T) {
    println("\(ESCAPE)fg0,255,0;\(object)\(RESET)")
  }

  public static func blue<T>(object:T) {
    println("\(ESCAPE)fg0,0,255;\(object)\(RESET)")
  }

  public static func yellow<T>(object:T) {
    println("\(ESCAPE)fg255,255,0;\(object)\(RESET)")
  }

  public static func purple<T>(object:T) {
    println("\(ESCAPE)fg255,0,255;\(object)\(RESET)")
  }

  public static func cyan<T>(object:T) {
    println("\(ESCAPE)fg0,255,255;\(object)\(RESET)")
  }
}

public class LogManager {

  public struct LogFlag: RawOptionSetType {
    public private(set) var rawValue: Int32
    public init(rawValue: Int32) { self.rawValue = rawValue }
    public init(nilLiteral: ()) { rawValue = 0 }
    public static var allZeros: LogFlag { return LogFlag.None }
    public static var None:     LogFlag = LogFlag(rawValue: 0b00000)
    public static var Error:    LogFlag = LogFlag(rawValue: 0b00001)
    public static var Warn:     LogFlag = LogFlag(rawValue: 0b00010)
    public static var Info:     LogFlag = LogFlag(rawValue: 0b00100)
    public static var Debug:    LogFlag = LogFlag(rawValue: 0b01000)
    public static var Verbose:  LogFlag = LogFlag(rawValue: 0b10000)
  }

  public struct LogLevel: RawOptionSetType {
    public private(set) var rawValue: Int32
    public init(rawValue: Int32) { self.rawValue = rawValue }
    public init(flags: LogFlag) { rawValue = flags.rawValue }
    public init(nilLiteral: ()) { rawValue = 0 }
    public static var allZeros: LogLevel { return LogLevel.Off }
    public static var Off:      LogLevel = LogLevel(flags: LogFlag.None)
    public static var Error:    LogLevel = LogLevel(flags: LogFlag.Error)
    public static var Warn:     LogLevel = LogLevel.Error | LogLevel(flags: LogFlag.Warn)
    public static var Info:     LogLevel = LogLevel.Warn  | LogLevel(flags: LogFlag.Info)
    public static var Debug:    LogLevel = LogLevel.Info | LogLevel(flags: LogFlag.Debug)
    public static var Verbose:  LogLevel = LogLevel.Debug | LogLevel(flags: LogFlag.Verbose)
    public static var All:      LogLevel = ~LogLevel.Off
  }



  public static var logLevel: LogLevel = .Debug

  static var registeredLogLevels: [String:LogLevel] = [:]

  /**
  logLevelForFile:

  :param: file String

  :returns: LogLevel
  */
  public class func logLevelForFile(file: String) -> LogManager.LogLevel {
    return registeredLogLevels[file] ?? logLevel
  }

  /**
  setLogLevel:forFile:

  :param: level LogManager.LogLevel
  :param: file String = __FILE__
  */
  public class func setLogLevel(level: LogManager.LogLevel, forFile file: String = __FILE__) {
    registeredLogLevels[file] = level
  }

}

/**
MSLogMessage:flag:function:line:level:context:

:param: message String
:param: flag LogManager.LogFlag
:param: function String = __FUNCTION__
:param: line Int = __LINE__
:param: context Int32 = LOG_CONTEXT_CONSOLE
*/
public func MSLogMessage(message: String,
                    flag: LogManager.LogFlag,
                function: String = __FUNCTION__,
                    line: Int32 = __LINE__,
                    file: String = __FILE__,
                 context: Int32 = LOG_CONTEXT_CONSOLE)
{
  MSLog.log(false,
      level: LogManager.logLevelForFile(file).rawValue,
       flag: flag.rawValue,
    context: context,
   function: function,
    message: message)
}


/**
MSLogDebug:function:line:level:context:

:param: message String
:param: function String = __FUNCTION__
:param: line Int = __LINE__
:param: context Int32 = LOG_CONTEXT_CONSOLE
*/
public func MSLogDebug(message: String,
              function: String = __FUNCTION__,
                  line: Int32 = __LINE__,
                  file: String = __FILE__,
               context: Int32 = LOG_CONTEXT_CONSOLE)
{
  MSLogMessage(message, .Debug, function: function, file: file, line: line, context: context)
}

/**
MSLogError:function:line:level:context:

:param: message String
:param: function String = __FUNCTION__
:param: line Int = __LINE__
:param: context Int32 = LOG_CONTEXT_CONSOLE
*/
public func MSLogError(message: String,
              function: String = __FUNCTION__,
                  line: Int32 = __LINE__,
                  file: String = __FILE__,
               context: Int32 = LOG_CONTEXT_CONSOLE)
{
  MSLogMessage(message, .Error, function: function, file: file, line: line, context: context)
}

/**
MSLogInfo:function:line:level:context:

:param: message String
:param: function String = __FUNCTION__
:param: line Int = __LINE__
:param: context Int32 = LOG_CONTEXT_CONSOLE
*/
public func MSLogInfo(message: String,
             function: String = __FUNCTION__,
                 line: Int32 = __LINE__,
                 file: String = __FILE__,
              context: Int32 = LOG_CONTEXT_CONSOLE)
{
  MSLogMessage(message, .Info, function: function, file: file, line: line, context: context)
}

/**
MSLogWarn:function:line:level:context:

:param: message String
:param: function String = __FUNCTION__
:param: line Int = __LINE__
:param: context Int32 = LOG_CONTEXT_CONSOLE
*/
public func MSLogWarn(message: String,
             function: String = __FUNCTION__,
                 line: Int32 = __LINE__,
                 file: String = __FILE__,
              context: Int32 = LOG_CONTEXT_CONSOLE)
{
  MSLogMessage(message, .Warn, function: function, file: file, line: line, context: context)
}

/**
MSLogVerbose:function:line:level:context:

:param: message String
:param: function String = __FUNCTION__
:param: line Int = __LINE__
:param: context Int32 = LOG_CONTEXT_CONSOLE
*/
public func MSLogVerbose(message: String,
                function: String = __FUNCTION__,
                    line: Int32 = __LINE__,
                    file: String = __FILE__,
                 context: Int32 = LOG_CONTEXT_CONSOLE)
{
  MSLogMessage(message, .Verbose, function: function, file: file, line: line, context: context)
}

/**
detailedDescriptionForError:depth:

:param: error NSError
:param: depth Int = 0

:returns: String
*/
public func detailedDescriptionForError(error: NSError, depth: Int = 0) -> String {

  let depthIndent = "  " * depth

  var message = "\(depthIndent)domain: \(error.domain)\n\(depthIndent)code: \(error.code)\n"
  if let coreDataErrorDescription = coreDataErrorCodeDescriptions[error.code] {
    message += "\(depthIndent)description: \(coreDataErrorDescription)\n"
    if let key: AnyObject = error.userInfo?[NSValidationKeyErrorKey] {
      message += "\(depthIndent)key: \(key)\n"
    }
    if let value: AnyObject = error.userInfo?[NSValidationValueErrorKey] {
      message += "\(depthIndent)value: \(value)\n"
    }
    if let predicate: AnyObject = error.userInfo?[NSValidationPredicateErrorKey] {
      message += "\(depthIndent)predicate: \(predicate)\n"
    }
    if let object: AnyObject = error.userInfo?[NSValidationObjectErrorKey] {
      message += "\(depthIndent)object: \(object)\n"
    }
  }

  if let reason = error.localizedFailureReason { message += "\(depthIndent)reason: \(reason)\n" }

  if let recoveryOptions = error.localizedRecoveryOptions as? [String] {
    let joinString = ",\n" + (" " * 18) + depthIndent
    message += "\(depthIndent)recovery options: \(joinString.join(recoveryOptions))\n"
  }

  if let suggestion = error.localizedRecoverySuggestion { message += "\(depthIndent)suggestion: \(suggestion)\n" }

  // Check for any undelrying errors
  if let underlyingError = error.userInfo?[NSUnderlyingErrorKey] as? NSError {
    // Add information gathered from the underlying error
    message += "\(depthIndent)underlyingError:\n\(detailedDescriptionForError(underlyingError, depth: depth + 1))\n"
  } else if let underlyingErrors = error.userInfo?[NSUnderlyingErrorKey] as? [NSError] {
      // Add information gathered from each underlying error
      message += "\(depthIndent)underlyingErrors:\n"
      message += ",\n".join(underlyingErrors.map{detailedDescriptionForError($0, depth: depth + 1)}) + "\n"
  } else if let detailedErrors = error.userInfo?[NSDetailedErrorsKey] as? [NSError] {
    // Add information gathered from each underlying error
    message += "\(depthIndent)detailedErrors:\n"
    message += ",\n".join(detailedErrors.map{detailedDescriptionForError($0, depth: depth + 1)})// + "\n"
  }

  return message

}

/**
MSHandleError:message:function:line:

:param: error NSError?
:param: message String? = nil
:param: function String = __FUNCTION__
:param: line Int = __LINE__

:returns: Bool
*/
public func MSHandleError(error: NSError?,
                  message: String? = nil,
                 function: String = __FUNCTION__,
                     line: Int32 = __LINE__) -> Bool
{
  if error == nil { return false }
  let logMessage = String("-Error- \(message ?? String())\n\(detailedDescriptionForError(error!, depth: 0))")
  MSLogError(logMessage, function: function, line: line)
  return true
}

/**
recursiveDescription<T>:description:subelements:

:param: base [T]
:param: description (T) -> String
:param: subelements (T) -> [T]
*/
public func recursiveDescription<T>(base: [T], level: Int = 0, description: (T) -> String, subelements:(T) -> [T]) -> String {
  var result = ""
  let indent = "\t" * level
  for object in base {
    result += indent + description(object) + "\n"
    for subelement in subelements(object) {
      result += recursiveDescription([subelement], level: level + 1, description, subelements)
    }
  }
  return result
}

let coreDataErrorCodeDescriptions = [
  NSManagedObjectValidationError: "generic validation error",
  NSValidationMultipleErrorsError: "generic message for error containing multiple validation errors",
  NSValidationMissingMandatoryPropertyError: "non-optional property with a nil value",
  NSValidationRelationshipLacksMinimumCountError: "to-many relationship with too few destination objects",
  NSValidationRelationshipExceedsMaximumCountError: "bounded, to-many relationship with too many destination objects",
  NSValidationRelationshipDeniedDeleteError: "some relationship with NSDeleteRuleDeny is non-empty",
  NSValidationNumberTooLargeError: "some numerical value is too large",
  NSValidationNumberTooSmallError: "some numerical value is too small",
  NSValidationDateTooLateError: "some date value is too late",
  NSValidationDateTooSoonError: "some date value is too soon",
  NSValidationInvalidDateError: "some date value fails to match date pattern",
  NSValidationStringTooLongError: "some string value is too long",
  NSValidationStringTooShortError: "some string value is too short",
  NSValidationStringPatternMatchingError  : "some string value fails to match some pattern",
  NSManagedObjectContextLockingError: "can't acquire a lock in a managed object context",
  NSPersistentStoreCoordinatorLockingError: "can't acquire a lock in a persistent store coordinator",
  NSManagedObjectReferentialIntegrityError: "attempt to fire a fault pointing to an object that does not exist (we can see the store, we can't see the object)",
  NSManagedObjectExternalRelationshipError: "an object being saved has a relationship containing an object from another store",
  NSManagedObjectMergeError: "merge policy failed - unable to complete merging",
  NSPersistentStoreInvalidTypeError: "unknown persistent store type/format/version",
  NSPersistentStoreTypeMismatchError: "returned by persistent store coordinator if a store is accessed that does not match the specified type",
  NSPersistentStoreIncompatibleSchemaError: "store returned an error for save operation (database level errors ie missing table, no permissions)",
  NSPersistentStoreSaveError: "unclassified save error - something we depend on returned an error",
  NSPersistentStoreIncompleteSaveError: "one or more of the stores returned an error during save (stores/objects that failed will be in userInfo)",
  NSPersistentStoreSaveConflictsError: "an unresolved merge conflict was encountered during a save.  userInfo has NSPersistentStoreSaveConflictsErrorKey",
  NSCoreDataError: "general Core Data error",
  NSPersistentStoreOperationError: "the persistent store operation failed ",
  NSPersistentStoreOpenError: "an error occurred while attempting to open the persistent store",
  NSPersistentStoreTimeoutError: "failed to connect to the persistent store within the specified timeout (see NSPersistentStoreTimeoutOption)",
  NSPersistentStoreUnsupportedRequestTypeError: "an NSPersistentStore subclass was passed an NSPersistentStoreRequest that it did not understand",
  NSPersistentStoreIncompatibleVersionHashError: "entity version hashes incompatible with data model",
  NSMigrationError: "general migration error",
  NSMigrationCancelledError: "migration failed due to manual cancellation",
  NSMigrationMissingSourceModelError: "migration failed due to missing source data model",
  NSMigrationMissingMappingModelError: "migration failed due to missing mapping model",
  NSMigrationManagerSourceStoreError: "migration failed due to a problem with the source data store",
  NSMigrationManagerDestinationStoreError: "migration failed due to a problem with the destination data store",
  NSEntityMigrationPolicyError: "migration failed during processing of the entity migration policy ",
  NSSQLiteError: "general SQLite error ",
  NSInferredMappingModelError: "inferred mapping model creation error",
  NSExternalRecordImportError: "general error encountered while importing external records"
]
