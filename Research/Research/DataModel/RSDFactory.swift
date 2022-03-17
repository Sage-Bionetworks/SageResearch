//
//  RSDFactory.swift
//  Research
//
//  Copyright © 2017-2021 Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import Foundation
import JsonModel
import Formatters
import MobilePassiveData
import AssessmentModel

public protocol RSDFactoryTypeRepresentable : RawRepresentable, ExpressibleByStringLiteral {
    var stringValue: String { get }
}

/// `RSDFactory` handles customization of decoding the elements of a task. Applications should
/// override this factory to add custom elements required to run their task modules.
open class RSDFactory : MobilePassiveDataFactory {
    
    public static var shared = RSDFactory.defaultFactory
    
    public let colorMappingSerializer = ColorMappingSerializer()
    public let taskSerializer = TaskSerializer()
    public let viewThemeSerializer = ViewThemeSerializer()
    
    public var stepSerializer : NodeSerializer {
        nodeSerializer
    }
    
    public required init() {
        super.init()
        
        self.registerSerializer(colorMappingSerializer)
        self.registerSerializer(taskSerializer)
        self.registerSerializer(viewThemeSerializer)
        
        self.resultSerializer.add(RSDTaskResultObject(identifier: "example"))
        self.resultSerializer.add(RSDNavigationResultObject(result: ResultObject(identifier: "foo"), skipToIdentifier: "baroo"))
        self.buttonActionSerializer.addButtons()
        self.nodeSerializer.addAllSteps()
        
        // Add root objects
        self.registerRootObject(RSDAssessmentTaskObject())
        self.registerRootObject(RSDTaskMetadata())
    }
    
    /// The type of device to point use when decoding different text depending upon the target
    /// device.
    public internal(set) var deviceType: RSDDeviceType = {
        #if os(watchOS)
        return .watch
        #elseif os(iOS)
        return .phone
        #elseif os(tvOS)
        return .tv
        #else
        return .computer
        #endif
    }()
    
    /// Optional shared tracking rules
    open var trackingRules: [RSDTrackingRule] = []
    
    open override func modelName(for className: String) -> String {
        switch className {
        default:
            var modelName = className
            let objcPrefix = "RSD"
            if modelName.hasPrefix(objcPrefix) {
                modelName = String(modelName.dropFirst(objcPrefix.count))
            }
            return modelName.replacingOccurrences(of: "UIAction", with: "Button")
        }
    }

    // MARK: Class name factory
    
    private enum TypeKeys: String, CodingKey {
        case type
    }
    
    /// Get a string that will identify the type of object to instantiate for the given decoder.
    ///
    /// By default, this will look in the container for the decoder for a key/value pair where
    /// the key == "type" and the value is a `String`.
    ///
    /// - parameter decoder: The decoder to inspect.
    /// - returns: The string representing this class type (if found).
    /// - throws: `DecodingError` if the type name cannot be decoded.
    open func typeName(from decoder:Decoder) throws -> String? {
        let container = try decoder.container(keyedBy: TypeKeys.self)
        return try container.decodeIfPresent(String.self, forKey: .type)
    }
    
    open override func serializer<T>(for type: T.Type) -> GenericSerializer? {
        if type == RSDStep.self {
            return nodeSerializer
        }
        else if type == RSDUIAction.self {
            return buttonActionSerializer
        }
        else {
            return super.serializer(for: type)
        }
    }
    
    // MARK: Task factory

    /// Use the resource transformer to get a data object to decode into a task.
    ///
    /// - parameters:
    ///     - resourceTransformer: The resource transformer.
    ///     - taskIdentifier: The identifier of the task.
    ///     - schemaInfo: The schema info for the task.
    /// - returns: The decoded task.
    /// - throws: `DecodingError` if the object cannot be decoded.
    /// - seealso: `RSDTaskResourceTransformer`
    open func decodeTask(with resourceTransformer: RSDResourceTransformer, taskIdentifier: String? = nil, schemaInfo: RSDSchemaInfo? = nil) throws -> RSDTask {
        let (data, type) = try resourceTransformer.resourceData()
        return try decodeTask(with: data,
                              resourceType: type,
                              typeName: nil, //resourceTransformer.classType, TODO: syoung 04/14/2020 Refactor task decoding to a serialization strategy supported by Kotlin.
                              taskIdentifier: taskIdentifier,
                              schemaInfo: schemaInfo,
                              resourceInfo: resourceTransformer)
    }
    
    /// Decode an object with top-level data (json or plist) for a given `resourceType`,
    /// `typeName`, and `taskInfo`.
    ///
    /// - parameters:
    ///     - data:            The data to use to decode the object.
    ///     - resourceType:    The type of resource (json or plist).
    ///     - typeName:        The class name type key for this task (if any).
    ///     - taskIdentifier:  The identifier of the task.
    ///     - schemaInfo:      The schema info for the task.
    ///     - resourceInfo:    The resource info for the source of the data.
    /// - returns: The decoded task.
    /// - throws: `DecodingError` if the object cannot be decoded.
    open func decodeTask(with data: Data, resourceType: RSDResourceType, typeName: String? = nil, taskIdentifier: String? = nil, schemaInfo: RSDSchemaInfo? = nil, resourceInfo: ResourceInfo? = nil) throws -> RSDTask {
        let decoder = try createDecoder(for: resourceType, taskIdentifier: taskIdentifier, schemaInfo: schemaInfo, resourceInfo: resourceInfo)
        return try decoder.factory.decodeTask(with: data, from: decoder)
    }
    
    /// Decode a task from the decoder.
    ///
    /// - parameters:
    ///     - data:    The data to use to decode the object.
    ///     - decoder: The decoder to use to instantiate the object.
    /// - returns: The decoded task.
    /// - throws: `DecodingError` if the object cannot be decoded.
    open func decodeTask(with data: Data, from decoder: FactoryDecoder) throws -> RSDTask {
        let wrapper = try decoder.decode(TaskWrapper.self, from: data)
        let task = wrapper.task
        try task.validate()
        return task
    }
    
    private struct TaskWrapper : Decodable {
        let task: RSDTask
        init(from decoder: Decoder) throws {
            self.task = try decoder.factory.decodePolymorphicObject(RSDTask.self, from: decoder)
        }
    }
    
    // MARK: Task Transformer factory
    
    /// Decode the task transformer from this decoder. This method *must* return a task transformer
    /// object. The default implementation will return a `RSDResourceTransformerObject`.
    ///
    /// - parameter decoder: The decoder to use to instantiate the object.
    /// - returns: The object created from this decoder.
    /// - throws: `DecodingError` if the object cannot be decoded.
    open func decodeTaskTransformer(from decoder: Decoder) throws -> RSDTaskTransformer {
        return try _decodeResource(RSDResourceTransformerObject.self, from: decoder)
    }
        
    /// Override mapping the array to allow steps to add a pointer between the countdown step and
    /// the active step. This is handled in Kotlin native serialization during unpacking.
    open override func mapDecodedArray<RSDStep>(_ objects: [RSDStep]) throws -> [RSDStep] {
        objects.enumerated().forEach { (index, step) in
            if let countdown = step as? RSDCountdownUIStepObject,
                index + 1 < objects.count,
                let activeStep = objects[index + 1] as? RSDActiveUIStep {
                // Special-case handling of a countdown step. Inspect the step to see if this is
                // a countdown/active step pairing and if so, set the countdown step to include a
                // pointer to the active step.
                //
                // WARNING: This is *not* a weak pointer b/c the `RSDActiveUIStep` protocol does not
                // require that step to be a class (but it might be) so this will cause a retain
                // loop if this special-case handling is ever modified to have a pointer from the
                // countdown step to the active step. syoung 07/12/2019
                //
                countdown.activeStep = activeStep
            }
        }
        return objects
    }
    
    /// Override mapping the object to check if this is a step transformer, and transform the step
    /// if needed. In Kotlin native, this is handled during unpacking of the assessment.
    open override func mapDecodedObject<T>(_ type: T.Type, object: Any, codingPath: [CodingKey]) throws -> T {
        if let step = (object as? RSDStepTransformer)?.transformedStep as? T {
            return step
        }
        else {
            return try super.mapDecodedObject(type, object: object, codingPath: codingPath)
        }
    }
    
    private func _decodeResource<T>(_ type: T.Type, from decoder: Decoder) throws -> T where T : DecodableBundleInfo {
        var resource = try T(from: decoder)
        resource.factoryBundle = decoder.bundle
        return resource
    }
    

    // MARK: Decoder
    
    /// Create the appropriate decoder for the given resource type. This method will return an
    /// decoder that conforms to the `FactoryDecoder` protocol. The decoder will assign the
    /// user info coding keys as appropriate.
    ///
    /// - parameters:
    ///     - resourceType:    The resource type.
    ///     - taskIdentifier:  The task identifier to pass with the decoder.
    ///     - schemaInfo:      The schema info to pass with the decoder.
    ///     - resourceInfo:    The resource info for this decoder.
    /// - returns: The decoder for the given type.
    /// - throws: `DecodingError` if the object cannot be decoded.
    open func createDecoder(for resourceType: RSDResourceType, taskIdentifier: String? = nil, schemaInfo: RSDSchemaInfo? = nil, resourceInfo: ResourceInfo? = nil) throws -> FactoryDecoder {
        var decoder : FactoryDecoder = try {
            if resourceType == .json {
                return self.createJSONDecoder(resourceInfo: resourceInfo)
            }
            else if resourceType == .plist {
                return self.createPropertyListDecoder(resourceInfo: resourceInfo)
            }
            else {
                let supportedTypes: [RSDResourceType] = [.json, .plist]
                let supportedTypeList = supportedTypes.map({$0.rawValue}).joined(separator: ",")
                throw RSDResourceTransformerError.invalidResourceType("ResourceType \(resourceType.rawValue) is not supported by this factory. Supported types: \(supportedTypeList)")
            }
            }()
        if let taskIdentifier = taskIdentifier {
            decoder.userInfo[.taskIdentifier] = taskIdentifier
        }
        if let schemaInfo = schemaInfo {
            decoder.userInfo[.schemaInfo] = schemaInfo
        }
        return decoder
    }
    
    // MARK: Encoding polymophic objects
    
    open func encode(_ list: [Any], to nestedContainer: UnkeyedEncodingContainer) throws {
        var container = nestedContainer
        try list.forEach {
            guard let encodable = $0 as? Encodable else {
                let context = EncodingError.Context(codingPath: nestedContainer.codingPath, debugDescription: "Object does not conform to the encodable protocol.")
                throw EncodingError.invalidValue($0, context)
            }
            let nestedEncoder = container.superEncoder()
            try encodable.encode(to: nestedEncoder)
        }
    }
}

/// Extension of CodingUserInfoKey to add keys used by the Codable objects in this framework.
extension CodingUserInfoKey {
        
    /// The key for the task identifier to use when coding.
    public static let taskIdentifier = CodingUserInfoKey(rawValue: "RSDFactory.taskIdentifier")!
    
    /// The key for the schema info to use when coding.
    public static let schemaInfo = CodingUserInfoKey(rawValue: "RSDFactory.schemaInfo")!
    
    /// The key for the task data source to use when coding.
    public static let taskDataSource = CodingUserInfoKey(rawValue: "RSDFactory.taskDataSource")!
}

extension FactoryDecoder {
    
    public var factory : RSDFactory {
        (serializationFactory as? RSDFactory) ?? RSDFactory.shared
    }
    
    /// The task identifier to use when decoding.
    public var taskIdentifier: String? {
        return self.userInfo[.taskIdentifier] as? String
    }
}

/// Extension of Decoder to return the factory objects used by the Codable objects
/// in this framework.
extension Decoder {
    
    public var factory : RSDFactory {
        (serializationFactory as? RSDFactory) ?? RSDFactory.shared
    }
    
    /// The task identifier to use when decoding.
    public var taskIdentifier: String? {
        return self.userInfo[.taskIdentifier] as? String
    }
    
    /// The schema info to use when decoding if there isn't a local task info defined on the object.
    public var schemaInfo: RSDSchemaInfo? {
        return self.userInfo[.schemaInfo] as? RSDSchemaInfo
    }
}

/// Extension of Encoder to return the factory objects used by the Codable objects
/// in this framework.
extension Encoder {
    
    public var factory : RSDFactory {
        (serializationFactory as? RSDFactory) ?? RSDFactory.shared
    }
    
    /// The task info to use when encoding.
    public var taskIdentifier: String? {
        return self.userInfo[.taskIdentifier] as? String
    }
    
    /// The schema info to use when encoding.
    public var schemaInfo: RSDSchemaInfo? {
        return self.userInfo[.schemaInfo] as? RSDSchemaInfo
    }
}

