/**
 *  Unbox - the easy to use Swift JSON decoder
 *
 *  For usage, see documentation of the classes/symbols listed in this file, as well
 *  as the guide available at: github.com/johnsundell/unbox
 *
 *  Copyright (c) 2015 John Sundell. Licensed under the MIT license, as follows:
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
 */

import Foundation

/// Type alias defining what type of Dictionary that is Unboxable (valid JSON)
public typealias UnboxableDictionary = [String : AnyObject]

// MARK: - Main Unbox functions

/**
 *  Unbox (decode) a dictionary into a model
 *
 *  @param dictionary The dictionary to decode. Must be a valid JSON dictionary.
 *  @param context Any contextual object that should be available during unboxing.
 *  @param index The index that the dictionary has in any list, will be available during unboxing.
 *
 *  @discussion This function gets its return type from the context in which it's called.
 *  If the context is ambigious, you need to supply it, like:
 *
 *  `let unboxed: MyUnboxable? = Unbox(dictionary)`
 *
 *  @return A model of type `T` or `nil` if an error was occured. If you wish to know more
 *  about any error, use: `Unbox(dictionary, logErrors: true)`
 */
public func Unbox<T: Unboxable>(dictionary: UnboxableDictionary, context: Any? = nil, index: Int? = nil) -> T? {
    do {
        let unboxed: T = try UnboxOrThrow(dictionary, context: context, index: index)
        return unboxed
    } catch {
        return nil
    }
}

public func Unbox<T: UnboxableWithContext>(dictionary: UnboxableDictionary, context: T.ContextType, index: Int? = nil) -> T? {
    do {
        let unboxed: T = try UnboxOrThrow(dictionary, context: context, index: index)
        return unboxed
    } catch {
        return nil
    }
}

/**
 *  Unbox (decode) a set of data into a model
 *
 *  @param data The data to decode. Must be convertible into a valid JSON dictionary.
 *  @param context Any contextual object that should be available during unboxing.
 *  @param index The index that the dictionary has in any list, will be available during unboxing.
 *
 *  @discussion See the documentation for the main Unbox(dictionary:) function above for more information.
 */
public func Unbox<T: Unboxable>(data: NSData, context: Any? = nil, index: Int? = nil) -> T? {
    do {
        let unboxed: T = try UnboxOrThrow(data, context: context, index: index)
        return unboxed
    } catch {
        return nil
    }
}

/**
 *  Unbox (decode) a local JSON file into a model
 *
 *  @param filePath The path to the JSON file that should be decoded.
 *  @param context Any contextual object that should be available during unboxing.
 *  @param index The index that the dictionary has in any list, will be available during unboxing.
 *
 *  @discussion The file in question must be located within the main application bundle. See the documentation
 *  for the main Unbox(dictionary:) function above for more information.
 */
public func Unbox<T: Unboxable>(localFileWithName fileName: String, context: Any? = nil, index: Int? = nil) -> T? {
    do {
        let unboxed: T = try UnboxOrThrow(localFileWithName: fileName, context: context)
        return unboxed
    } catch {
        return nil
    }
}

public func Unbox<T: UnboxableWithContext>(localFileWithName fileName: String, context: T.ContextType, index: Int? = nil) -> T? {
    do {
        let unboxed: T = try UnboxOrThrow(localFileWithName: fileName, context: context)
        return unboxed
    } catch {
        return nil
    }
}

// MARK: - Unbox functions with error handling

/**
 *  Unbox (decode) a dictionary into a model, or throw an UnboxError if the operation failed
 *
 *  @param dictionary The dictionary to decode. Must be a valid JSON dictionary.
 *  @param context Any contextual object that should be available during unboxing.
 *  @param index The index that the dictionary has in any list, will be available during unboxing.
 *
 *  @discussion This function throws an UnboxError if the supplied dictionary couldn't be decoded
 *  for any reason. See the documentation for the main Unbox() function above for more information.
 */
public func UnboxOrThrow<T: Unboxable>(dictionary: UnboxableDictionary, context: Any? = nil, index: Int? = nil) throws -> T {
    let unboxer = Unboxer(dictionary: dictionary, context: context, index: index)
    return try HandleUnboxedObject(T(unboxer: unboxer), unboxer: unboxer)
}

public func UnboxOrThrow<T: UnboxableWithContext>(dictionary: UnboxableDictionary, context: T.ContextType, index: Int? = nil) throws -> T {
    let unboxer = Unboxer(dictionary: dictionary, context: context, index: index)
    return try HandleUnboxedObject(T(unboxer: unboxer, context: context), unboxer: unboxer)
}

/**
 *  Unbox (decode) a set of data into a model, or throw an UnboxError if the operation failed
 *
 *  @param data The data to decode. Must be convertible into a valid JSON dictionary.
 *  @param context Any contextual object that should be available during unboxing.
 *  @param index The index that the dictionary has in any list, will be available during unboxing.
 *
 *  @discussion This function throws an UnboxError if the supplied data couldn't be decoded for
 *  any reason. See the documentation for the main Unbox() function above for more information.
 */
public func UnboxOrThrow<T: Unboxable>(data: NSData, context: Any? = nil, index: Int? = nil) throws -> T {
    if let dictionary = try NSJSONSerialization.unboxableDictionaryFromData(data) {
        return try UnboxOrThrow(dictionary, context: context)
    }
    
    throw UnboxError.InvalidDictionary
}

public func UnboxOrThrow<T: UnboxableWithContext>(data: NSData, context: T.ContextType, index: Int? = nil) throws -> T {
    if let dictionary = try NSJSONSerialization.unboxableDictionaryFromData(data) {
        return try UnboxOrThrow(dictionary, context: context)
    }
    
    throw UnboxError.InvalidDictionary
}

public func UnboxOrThrow<T: Unboxable>(localFileWithName fileName: String, context: Any? = nil, index: Int? = nil) throws -> T {
    if let data = NSData(localFileWithName: fileName) {
        return try UnboxOrThrow(data, context: context)
    }
    
    throw UnboxError.InvalidLocalFile
}

public func UnboxOrThrow<T: UnboxableWithContext>(localFileWithName fileName: String, context: T.ContextType, index: Int? = nil) throws -> T {
    if let data = NSData(localFileWithName: fileName) {
        return try UnboxOrThrow(data, context: context)
    }
    
    throw UnboxError.InvalidLocalFile
}

private func HandleUnboxedObject<T>(object: T, unboxer: Unboxer) throws -> T {
    if let failureInfo = unboxer.failureInfo {
        if let failedValue: Any = failureInfo.value {
            throw UnboxError.InvalidValue(failureInfo.key, "\(failedValue)")
        }
        
        throw UnboxError.MissingKey(failureInfo.key)
    }
    
    return object
}

private extension NSData {
    convenience init?(localFileWithName fileName: String) {
        guard let filePath = NSBundle.mainBundle().pathForResource(fileName, ofType: "json") else {
            return nil
        }
        
        self.init(contentsOfFile: filePath)
    }
}

private extension NSJSONSerialization {
    static func unboxableDictionaryFromData(data: NSData) throws -> UnboxableDictionary? {
        return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? UnboxableDictionary
    }
}

// MARK: - Error type

/// Enum describing errors that can occur during unboxing. Use the throwing functions to receive any errors.
public enum UnboxError: ErrorType, CustomStringConvertible {
    public var description: String {
        let baseDescription = "[Unbox error] "
        
        switch self {
        case .MissingKey(let key):
            return baseDescription + "Missing key (\(key))"
        case .InvalidValue(let key, let valueDescription):
            return baseDescription + "Invalid value (\(valueDescription)) for key (\(key))"
        case .InvalidDictionary:
            return "Invalid dictionary"
        case .InvalidLocalFile:
            return "Invalid local file"
        }
    }
    
    /// Thrown when a required key was missing in an unboxed dictionary. Contains the missing key.
    case MissingKey(String)
    /// Thrown when a required key contained an invalid value in an unboxed dictionary. Contains the invalid
    /// key and a description of the invalid data.
    case InvalidValue(String, String)
    /// Thrown when an unboxed dictionary was either missing or contained invalid data
    case InvalidDictionary
    /// Thrown when a local file was either missing or contained invalid data
    case InvalidLocalFile
}

// MARK: - Protocols

/// Protocol used to declare a model as being Unboxable, for use with the Unbox() function
public protocol Unboxable {
    /// Initialize an instance of this model by unboxing a dictionary using an Unboxer
    init(unboxer: Unboxer)
}

/// Protool used to declare a model as being Unboxable with a required contextual object
public protocol UnboxableWithContext {
    /// The type of the contextual object that is required for unboxing of this type
    typealias ContextType
    
    /// Initialze an instance of this model by unboxing a dictionary using an Unboxer and a context
    init(unboxer: Unboxer, context: ContextType)
}

/// Protocol that objects that can be used in the Unboxing process must conform to
public protocol UnboxCompatibleType {
    /// Create an empty instance of this type, for use in fallbacks when Unboxing failed
    init()
}

// MARK: - Default Unbox compatible types

extension Array: UnboxCompatibleType { }
extension Dictionary: UnboxCompatibleType { }

/// Protocol used to enable a raw type for Unboxing
public protocol UnboxableRawType: UnboxCompatibleType { }

// MARK: - Raw types

extension Bool: UnboxableRawType { }
extension Int: UnboxableRawType { }
extension Int32: UnboxableRawType { }
extension Int64: UnboxableRawType { }
extension UInt: UnboxableRawType { }
extension UInt32: UnboxableRawType { }
extension UInt64: UnboxableRawType { }
extension Double: UnboxableRawType { }
extension Float: UnboxableRawType { }
extension String: UnboxableRawType { }

// MARK: - Unboxer

/**
 *  Class used to Unbox (decode) values from a dictionary
 *
 *  For each supported type, simply call `unbox(key)` and the correct type will be returned. If a required (non-optional)
 *  value couldn't be unboxed, the Unboxer will be marked as failed, and a `nil` value will be returned from the `Unbox()`
 *  function that triggered the Unboxer.
 *
 *  An Unboxer may also be manually failed, by using the `failForKey()` or `failForInvalidValue(forKey:)` APIs.
 */
public class Unboxer {
    /// All keys that the dictionary that this Unboxer manages contains
    public var allKeys: [String] { return Array(self.dictionary.keys) }
    /// Whether the Unboxer has failed, and a `nil` value will be returned from the `Unbox()` function that triggered it.
    public var hasFailed: Bool { return self.failureInfo != nil }
    /// Any contextual object that was supplied when unboxing was started
    public let context: Any?
    /// The index the dictionary that is currently being unboxed has in any list (automatically set for nested arrays)
    public let index: Int?
    
    private var failureInfo: (key: String, value: Any?)?
    private let dictionary: UnboxableDictionary
    
    // MARK: - Private initializer
    
    private init(dictionary: UnboxableDictionary, context: Any? = nil, index: Int? = nil) {
        self.dictionary = dictionary
        self.context = context
        self.index = index
    }
    
    // MARK: - Unboxing API
    
    /// Unbox a required raw type
    public func unbox<T: UnboxableRawType>(key: String) -> T {
        return UnboxValueResolver<T>(self).resolveRequiredValueForKey(key, fallbackValue: T())
    }
    
    /// Unbox an optional raw type
    public func unbox<T: UnboxableRawType>(key: String) -> T? {
        return UnboxValueResolver<T>(self).resolveOptionalValueForKey(key)
    }
    
    /// Unbox a required raw representable type
    public func unbox<T: RawRepresentable where T.RawValue: UnboxableRawType, T: UnboxCompatibleType>(key: String) -> T {
        return UnboxValueResolver<T.RawValue>(self).resolveRequiredValueForKey(key, fallbackValue: T(), transform: {
            return T(rawValue: $0)
        })
    }
    
    /// Unbox an optional raw representable type
    public func unbox<T: RawRepresentable where T.RawValue: UnboxableRawType, T: UnboxCompatibleType>(key: String) -> T? {
        return UnboxValueResolver<T.RawValue>(self).resolveOptionalValueForKey(key, transform: {
            return T(rawValue: $0)
        })
    }
    
    /// Unbox a required Array
    public func unbox<T>(key: String) -> [T] {
        return UnboxValueResolver<[T]>(self).resolveRequiredValueForKey(key, fallbackValue: [])
    }
    
    /// Unbox an optional Array
    public func unbox<T>(key: String) -> [T]? {
        return UnboxValueResolver<[T]>(self).resolveOptionalValueForKey(key)
    }
    
    /// Unbox a required Dictionary
    public func unbox<T>(key: String) -> [String : T] {
        return UnboxValueResolver<[String : T]>(self).resolveRequiredValueForKey(key, fallbackValue: [:])
    }
    
    /// Unbox an optional Dictionary
    public func unbox<T>(key: String) -> [String : T]? {
        return UnboxValueResolver<[String : T]>(self).resolveOptionalValueForKey(key)
    }
    
    /// Unbox a required nested Unboxable, by unboxing a Dictionary and then using a transform
    public func unbox<T: Unboxable>(key: String, context: Any? = nil) -> T {
        return UnboxValueResolver<UnboxableDictionary>(self).resolveRequiredValueForKey(key, fallbackValue: T(unboxer: self), transform: {
            return Unbox($0, context: context ?? self.context)
        })
    }
    
    /// Unbox an optional nested Unboxable, by unboxing a Dictionary and then using a transform
    public func unbox<T: Unboxable>(key: String, context: Any? = nil) -> T? {
        return UnboxValueResolver<UnboxableDictionary>(self).resolveOptionalValueForKey(key, transform: {
            return Unbox($0, context: context ?? self.context)
        })
    }
    
    /// Unbox a required Array of nested Unboxables, by unboxing an Array of Dictionaries and then using a transform
    public func unbox<T: Unboxable>(key: String) -> [T] {
        return UnboxValueResolver<[UnboxableDictionary]>(self).resolveRequiredValueForKey(key, fallbackValue: [], transform: {
            return self.transformUnboxableDictionaryArray($0, forKey: key, required: true)
        })
    }
    
    /// Unbox an optional Array of nested Unboxables, by unboxing an Array of Dictionaries and then using a transform
    public func unbox<T: Unboxable>(key: String) -> [T]? {
        return UnboxValueResolver<[UnboxableDictionary]>(self).resolveOptionalValueForKey(key, transform: {
            return self.transformUnboxableDictionaryArray($0, forKey: key, required: false)
        })
    }
    
    /// Unbox a required Dictionary of nested Unboxables, by unboxing an Dictionary of Dictionaries and then using a transform
    public func unbox<T: Unboxable>(key: String) -> [String : T] {
        return UnboxValueResolver<UnboxableDictionary>(self).resolveRequiredValueForKey(key, fallbackValue: [:], transform: {
            return self.transformUnboxableDictionaryDictionary($0, required: true)
        })
    }
    
    /// Unbox an optional Dictionary of nested Unboxables, by unboxing an Dictionary of Dictionaries and then using a transform
    public func unbox<T: Unboxable>(key: String) -> [String : T]? {
        return UnboxValueResolver<UnboxableDictionary>(self).resolveOptionalValueForKey(key, transform: {
            return self.transformUnboxableDictionaryDictionary($0, required: false)
        })
    }
    
    /// Unbox a required nested UnboxableWithContext, by unboxing a Dictionary and then using a transform
    public func unbox<T: UnboxableWithContext>(key: String, context: T.ContextType) -> T {
        return UnboxValueResolver<UnboxableDictionary>(self).resolveRequiredValueForKey(key, fallbackValue: T(unboxer: self, context: context), transform: {
            return Unbox($0, context: context)
        })
    }
    
    // MARK: - Context API
    
    /// Return a required contextual object of type `T` attached to this Unboxer, or cause the Unboxer to fail
    public func requiredContext<T: UnboxCompatibleType>() -> T {
        if let context = self.context as? T {
            return context
        }
        
        self.failForInvalidValue(self.context, forKey: "Unboxer.Context")
        
        return T()
    }
    
    // MARK: - Failing API
    
    /// Make this Unboxer to fail for a certain key. This will cause the `Unbox()` function that triggered this Unboxer to return `nil`.
    public func failForKey(key: String) {
        self.failForInvalidValue(nil, forKey: key)
    }
    
    /// Make this Unboxer to fail for a certain key and invalid value. This will cause the `Unbox()` function that triggered this Unboxer to return `nil`.
    public func failForInvalidValue(invalidValue: Any?, forKey key: String) {
        print(invalidValue, key)
        
        self.failureInfo = (key, invalidValue)
    }
    
    // MARK: - Private utilities
    
    private func transformUnboxableDictionaryArray<T: Unboxable>(dictionaries: [UnboxableDictionary], forKey key: String, required: Bool) -> [T]? {
        var transformed = [T]()
        
        for (index, dictionary) in dictionaries.enumerate() {
            if let unboxed: T = Unbox(dictionary, context: self.context, index: index) {
                transformed.append(unboxed)
            } else if required {
                self.failForInvalidValue(dictionaries, forKey: key)
            }
        }
        
        return transformed
    }
    
    private func transformUnboxableDictionaryDictionary<T: Unboxable>(dictionaries: UnboxableDictionary, required: Bool) -> [String : T]? {
        var transformed = [String : T]()
        
        for (key, dictionary) in dictionaries {
            if let unboxableDictionary = dictionary as? UnboxableDictionary {
                if let unboxed: T = Unbox(unboxableDictionary, context: self.context) {
                    transformed[key] = unboxed
                    continue
                }
            }
            
            if required {
                self.failForInvalidValue(dictionary, forKey: key)
            }
        }
        
        return transformed
    }
}

// MARK: - UnboxValueResolver

private class UnboxValueResolver<T> {
    let unboxer: Unboxer
    
    init(_ unboxer: Unboxer) {
        self.unboxer = unboxer
    }
    
    func resolveRequiredValueForKey(key: String, @autoclosure fallbackValue: () -> T) -> T {
        return self.resolveRequiredValueForKey(key, fallbackValue: fallbackValue, transform: {
            return $0
        })
    }
    
    func resolveRequiredValueForKey<R>(key: String, @autoclosure fallbackValue: () -> R, transform: T -> R?) -> R {
        if let value = self.resolveOptionalValueForKey(key, transform: transform) {
            return value
        }
        
        self.unboxer.failForInvalidValue(self.unboxer.dictionary[key], forKey: key)
        
        return fallbackValue()
    }
    
    func resolveOptionalValueForKey(key: String) -> T? {
        return self.resolveOptionalValueForKey(key, transform: {
            return $0
        })
    }
    
    func resolveOptionalValueForKey<R>(key: String, transform: T -> R?) -> R? {
        if let value = self.unboxer.dictionary[key] as? T {
            if let transformed = transform(value) {
                return transformed
            }
        }
        
        return nil
    }
}
