//
//  RSDDateCoderObject.swift
//  Research
//

import Foundation
import JsonModel

/// `RSDDateCoderObject` provides a concrete implementation of a `RSDDateCoder`. The date coder is used by
/// the `RSDDateRangeObject` to encode and decode the `minDate` and `maxDate` properties as well as to get
/// which components of a date should be stored in the answer for a given `RSDInputField`.
///
/// This coder uses ISO 8601 format to determine which calendar components to request from the user and to
/// store from the input result. The `calendar` is ISO8601 and the `resultFormatter` is determined from
/// the `calendarComponents` using the shared `RSDFactory` or the factory associated with the decoder if
/// instantiated using a `Decoder`. The locale for the date formatters is "en_US_POSIX" by default.
///
public struct RSDDateCoderObject : RSDDateCoder, RawRepresentable {

    /// Coder for a timestamp.
    public static let timestamp = RSDDateCoderObject(rawValue: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ")!
    
    /// Coder for a date only.
    public static let dateOnly = RSDDateCoderObject(rawValue: "yyyy-MM-dd")!
    
    /// Coder for a time of day.
    public static let timeOfDay = RSDDateCoderObject(rawValue: "HH:mm:ss")!
    
    /// Coder for a time of day.
    public static let hourAndMinutesOnly = RSDDateCoderObject(rawValue: "HH:mm")!
    
    /// The input format used to represent the formatters and calendar components.
    public var rawValue: String {
        return inputFormatter.dateFormat
    }
    
    /// The formatter to use when storing the result.
    /// - note: For an `RSDAnswerResult`, only the `dateFormat` is saved to the encoded
    ///         `RSDAnswerResultType.dateFormat` property.
    public let resultFormatter: DateFormatter
    
    /// The formatter used to determine the appropriate date components (by parsing the `dateFormat` string)
    /// and the formatter used to parse out a `minDate` and `maxDate` for a decoded `RSDDateRangeObject`.
    public let inputFormatter: DateFormatter
    
    /// The components to request from the user and to store.
    public let calendarComponents: Set<Calendar.Component>
    
    /// The calendar used by the associated input field. Default = "ISO8601".
    public let calendar: Calendar
    
    /// The default initializer initializes the date coder as a timestamp.
    public init() {
        let (inputFormatter, resultFormatter, components, calendar) = RSDDateCoderObject.getProperties(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ")!
        self.resultFormatter = resultFormatter
        self.inputFormatter = inputFormatter
        self.calendarComponents = components
        self.calendar = calendar
    }
    
    /// Initialize the date coder using the `rawValue` which is the input date format.
    public init?(rawValue: String) {
        guard let (inputFormatter, resultFormatter, components, calendar) = RSDDateCoderObject.getProperties(format: rawValue)
            else {
                return nil
        }
        self.resultFormatter = resultFormatter
        self.inputFormatter = inputFormatter
        self.calendarComponents = components
        self.calendar = calendar
    }
    
    /// Initialize the date coder using a decoder. The decoder is assumed to have a `SingleValueDecodingContainer`
    /// with the `rawValue` that can be used to decode this instance.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let format = try container.decode(String.self)
        guard let (inputFormatter, resultFormatter, components, calendar) =
            RSDDateCoderObject.getProperties(format: format, factory: decoder.factory)
            else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Failed to get the calendar components from the decoded format \(format)"))
        }
        self.resultFormatter = resultFormatter
        self.inputFormatter = inputFormatter
        self.calendarComponents = components
        self.calendar = calendar
    }
    
    fileprivate static func getProperties(format: String, factory: SerializationFactory = RSDFactory.shared) -> (inputFormatter: DateFormatter, resultFormatter: DateFormatter, Set<Calendar.Component>, Calendar)? {
        let calendar = Calendar.iso8601
        let components = calendarComponents(from: format)
        guard components.count > 0 else {
            return nil
        }
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = format
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let resultFormatter = factory.dateResultFormatter(from: components)
        
        return (inputFormatter, resultFormatter, components, calendar)
    }
    
    /// Encode the `rawValue` to a `SingleValueEncodingContainer`.
    /// - parameter encoder: The encoder to encode the `rawValue` to.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.inputFormatter.dateFormat)
    }

    /// The is a static method used to parse the ISO 8601 date format for the calendar components that are
    /// relavent to this instance. This method inspects the given string for the components where:
    ///     - "yyyy": `year`
    ///     - "MM": `month`
    ///     - "dd": `day`
    ///     - "HH": `hour`
    ///     - "mm": `minute`
    ///     - "ss": `second`
    ///     - "ss.SSS": `nanosecond`
    ///
    /// - parameter format: The string to parse.
    public static func calendarComponents(from format: String) -> Set<Calendar.Component> {
        var components: Set<Calendar.Component> = []
        if format.range(of: "yyyy") != nil {
            components.insert(.year)
        }
        if format.range(of: "MM") != nil {
            components.insert(.month)
        }
        if format.range(of: "dd") != nil {
            components.insert(.day)
        }
        if format.range(of: "HH") != nil {
            components.insert(.hour)
        }
        if format.range(of: "mm") != nil {
            components.insert(.minute)
        }
        if format.range(of: "ss") != nil {
            components.insert(.second)
        }
        if format.range(of: "ss.SSS") != nil {
            components.insert(.nanosecond)
        }
        return components
    }
}

extension Calendar {
    
    /// Convenience property for accessing the ISO8601 calendar.
    public static let iso8601 = Calendar(identifier: .iso8601)
}

extension RSDDateCoderObject : Equatable {
}

extension RSDDateCoderObject : DocumentableStringLiteral {
    public static func examples() -> [String] {
        return ["yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ",
                "yyyy-MM",
                "yyyy-MM-dd",
                "MM-dd",
                "HH:mm:ss",
                "HH:mm"]
    }
}

extension Date {
    func yearComponent() -> Int {
        Calendar.iso8601.component(.year, from: self)
    }
}
