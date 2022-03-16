//
//  RSDUIActionObject.swift
//  Research
//
//  Copyright © 2017 Sage Bionetworks. All rights reserved.
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
import AssessmentModel

/// `RSDEmbeddedResourceUIAction` is a convenience protocol for returning an image using an
/// encodable strings for the name and bundle identifier.
public protocol RSDEmbeddedResourceUIAction: SerializableButtonActionInfo, DecodableBundleInfo {
}

/// The type of the ui action. This is used to decode a `ButtonActionInfo` using a `RSDFactory`. It can also be used
/// to customize the UI.
extension ButtonActionInfoType {
    
    /// Defaults to creating a `ButtonActionInfoObject`.
    public static let defaultNavigation: ButtonActionInfoType = "default"
    
    /// Defaults to creating a `RSDNavigationUIActionObject`.
    public static let navigation: ButtonActionInfoType = "navigation"
    
    /// Defaults to creating a `RSDReminderUIActionObject`.
    public static let reminder: ButtonActionInfoType = "reminder"
    
    /// Defaults to creating a `RSDWebViewUIActionObject`.
    public static let webView: ButtonActionInfoType = "webView"
    
    /// Defaults to creating a `RSDVideoViewUIActionObject`.
    public static let videoView: ButtonActionInfoType = "videoView"
}

extension ButtonActionSerializer {
    func addButtons() {
        let examples: [SerializableButtonActionInfo] = [
            RSDNavigationUIActionObject.examples().first!,
            RSDReminderUIActionObject.examples().first!,
            RSDWebViewUIActionObject.examples().first!,
            RSDVideoViewUIActionObject.examples().first!,
        ]
        examples.forEach { self.add($0) }
    }
}

/// `RSDNavigationUIActionObject` implements an action for navigating to another step in a task.
public struct RSDNavigationUIActionObject : RSDEmbeddedResourceUIAction, RSDNavigationUIAction, Codable {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case serializableType = "type", skipToIdentifier, buttonTitle, iconName, bundleIdentifier, packageName
    }
    
    public private(set) var serializableType: ButtonActionInfoType = .navigation
    
    /// The identifier for the step to skip to if the action is called.
    public let skipToIdentifier: String
    
    /// The title to display on the button associated with this action.
    public var buttonTitle: String?
    
    /// The name of the icon to display on the button associated with this action.
    public var iconName: String?
    
    /// The bundle identifier for the resource bundle that contains the image.
    public var bundleIdentifier: String?
    
    /// The default bundle from the factory used to decode this object.
    public var factoryBundle: ResourceBundle? = nil
    
    /// The Android package for the resource.
    public var packageName: String?
    
    /// Default initializer for a button with text.
    /// - parameters:
    ///     - skipToIdentifier: The identifier for the step to skip to if the action is called.
    ///     - buttonTitle: The title to display on the button associated with this action.
    public init(skipToIdentifier: String, buttonTitle: String) {
        self.skipToIdentifier = skipToIdentifier
        self.buttonTitle = buttonTitle
    }
}

/// `RSDReminderUIActionObject` implements an action for setting up a local notification to remind
/// the participant about doing a particular task later.
public struct RSDReminderUIActionObject : RSDEmbeddedResourceUIAction, RSDReminderUIAction, Codable {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case serializableType = "type", reminderIdentifier, _buttonTitle = "buttonTitle", iconName, bundleIdentifier, packageName
    }
    
    public private(set) var serializableType: ButtonActionInfoType = .reminder
    
    /// The identifier for a `UNNotificationRequest`.
    public let reminderIdentifier: String
    
    /// The title to display on the button associated with this action.
    public var buttonTitle: String? {
        return _buttonTitle ?? Localization.localizedString("REMINDER_BUTTON_TITLE")
    }
    private var _buttonTitle: String?
    
    /// The name of the icon to display on the button associated with this action.
    public var iconName: String?
    
    /// The bundle identifier for the resource bundle that contains the image.
    public var bundleIdentifier: String?
    
    /// The default bundle from the factory used to decode this object.
    public var factoryBundle: ResourceBundle? = nil
    
    /// The Android package for the resource.
    public var packageName: String?
    
    /// Default initializer for a button with text.
    /// - parameters:
    ///     - reminderIdentifier:  The identifier for a `UNNotificationRequest`.
    ///     - buttonTitle: The title to display on the button associated with this action.
    public init(reminderIdentifier: String, buttonTitle: String) {
        self.reminderIdentifier = reminderIdentifier
        self._buttonTitle = buttonTitle
    }
}

/// `RSDWebViewUIActionObject` implements an action that includes a pointer to a url that can display in a
/// webview. The url can either be fully qualified or optionally point to an embedded resource. 
public struct RSDWebViewUIActionObject : RSDEmbeddedResourceUIAction, RSDWebViewUIAction, Codable {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case serializableType = "type", url, usesBackButton, title, closeButtonTitle, buttonTitle, iconName, bundleIdentifier, packageName
    }
    
    public private(set) var serializableType: ButtonActionInfoType = .webView
    
    /// The url to load in the webview. If this is not a fully qualified url string, then it is assumed to
    /// refer to an embedded resource.
    public let url: String
    
    /// Should this webview be presented with a `<-` style of closure or a `X` style of closure?
    /// If nil, then the default will assume `X`.
    ///
    /// - note: This is only applicable to devices that use a back button or close button. Otherwise, it is
    /// ignored.
    public var usesBackButton: Bool?
    
    /// Optional title for a close button.
    public var closeButtonTitle: String?
    
    /// The title to show in a title bar or header.
    public var title: String?
    
    /// The title to display on the button associated with this action.
    public var buttonTitle: String?
    
    /// The name of the icon to display on the button associated with this action.
    public var iconName: String?
    
    /// The bundle identifier for the resource bundle that contains the image.
    public var bundleIdentifier: String?
    
    /// The default bundle from the factory used to decode this object.
    public var factoryBundle: ResourceBundle? = nil
    
    /// The Android package for the resource.
    public var packageName: String?
    
    /// The `url` is the resource name.
    public var resourceName: String {
        return url
    }
    
    /// Returns nil. This value is ignored.
    public var classType: String? {
        return nil
    }
    
    /// Default initializer for a button with text.
    /// - parameters:
    ///     - url: The url to load in the webview.
    ///     - buttonTitle: The title to display on the button associated with this action.
    ///     - bundleIdentifier: The bundle identifier for the url if not fully qualified. Default = `nil`.
    public init(url: String, buttonTitle: String, bundleIdentifier: String? = nil) {
        self.url = url
        self.buttonTitle = buttonTitle
        self.bundleIdentifier = bundleIdentifier
    }
    
    /// Default initializer for a button with an image.
    /// - parameters:
    ///     - url: The url to load in the webview.
    ///     - iconName: The name of the image to display on the button.
    ///     - bundleIdentifier: The bundle identifier for the url if not fully qualified. This is also used
    ///       as the bundle for the image. Default = `nil`.
    public init(url: String, iconName: String, bundleIdentifier: String? = nil) {
        self.url = url
        self.iconName = iconName
        self.bundleIdentifier = bundleIdentifier
    }
}

/// `RSDVideoViewUIActionObject` implements an action that includes a pointer to a url that can display in a
/// `AVPlayerViewController`. The url can either be fully qualified or optionally point to an embedded resource.
public struct RSDVideoViewUIActionObject : RSDEmbeddedResourceUIAction, RSDVideoViewUIAction, Codable {
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case serializableType = "type", url, buttonTitle, iconName, bundleIdentifier, packageName
    }
    
    public private(set) var serializableType: ButtonActionInfoType = .videoView
    
    /// The url to load in the webview. If this is not a fully qualified url string, then it is assumed to
    /// refer to an embedded resource.
    public let url: String
    
    /// The title to show in a title bar or header.
    public var title: String?
    
    /// The title to display on the button associated with this action.
    public var buttonTitle: String?
    
    /// The name of the icon to display on the button associated with this action.
    public var iconName: String?
    
    /// The bundle identifier for the resource bundle that contains the image.
    public var bundleIdentifier: String?
    
    /// The default bundle from the factory used to decode this object.
    public var factoryBundle: ResourceBundle? = nil
    
    /// The Android package for the resource.
    public var packageName: String?
    
    /// The `url` is the resource name.
    public var resourceName: String {
        return url
    }
    
    /// Returns nil. This value is ignored.
    public var classType: String? {
        return nil
    }
    
    /// Default initializer for a button with text.
    /// - parameters:
    ///     - url: The url to load in the webview.
    ///     - buttonTitle: The title to display on the button associated with this action.
    ///     - bundleIdentifier: The bundle identifier for the url if not fully qualified. Default = `nil`.
    public init(url: String, buttonTitle: String, bundleIdentifier: String? = nil) {
        self.url = url
        self.buttonTitle = buttonTitle
        self.bundleIdentifier = bundleIdentifier
    }
    
    /// Default initializer for a button with an image.
    /// - parameters:
    ///     - url: The url to load in the webview.
    ///     - iconName: The name of the image to display on the button.
    ///     - bundleIdentifier: The bundle identifier for the url if not fully qualified. This is also used
    ///       as the bundle for the image. Default = `nil`.
    public init(url: String, iconName: String, bundleIdentifier: String? = nil) {
        self.url = url
        self.iconName = iconName
        self.bundleIdentifier = bundleIdentifier
    }
}

extension RSDNavigationUIActionObject : DocumentableStruct {
    public static func codingKeys() -> [CodingKey] {
        CodingKeys.allCases
    }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool {
        guard let key = codingKey as? CodingKeys else { return false }
        return key == .serializableType || key == .skipToIdentifier
    }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        switch key {
        case .serializableType:
            return .init(constValue: ButtonActionInfoType.navigation)
        case .buttonTitle, .iconName, .bundleIdentifier, .packageName:
            return .init(propertyType: .primitive(.string))
        case .skipToIdentifier:
            return .init(propertyType: .primitive(.string))
        }
    }

    public static func examples() -> [RSDNavigationUIActionObject] {
        let titleAction = RSDNavigationUIActionObject(skipToIdentifier: "nextSection", buttonTitle: "Go, Dogs! Go")
        return [titleAction]
    }
}

extension RSDReminderUIActionObject : DocumentableStruct {
    public static func codingKeys() -> [CodingKey] {
        CodingKeys.allCases
    }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool {
        guard let key = codingKey as? CodingKeys else { return false }
        return key == .serializableType || key == .reminderIdentifier
    }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        switch key {
        case .serializableType:
            return .init(constValue: ButtonActionInfoType.navigation)
        case ._buttonTitle, .iconName, .bundleIdentifier, .packageName:
            return .init(propertyType: .primitive(.string))
        case .reminderIdentifier:
            return .init(propertyType: .primitive(.string))
        }
    }

    public static func examples() -> [RSDReminderUIActionObject] {
        let titleAction = RSDReminderUIActionObject(reminderIdentifier: "foo", buttonTitle: "Remind me later")
        return [titleAction]
    }
}

extension RSDWebViewUIActionObject : DocumentableStruct {
    public static func codingKeys() -> [CodingKey] {
        CodingKeys.allCases
    }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool {
        guard let key = codingKey as? CodingKeys else { return false }
        return key == .serializableType || key == .url
    }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        switch key {
        case .serializableType:
            return .init(constValue: ButtonActionInfoType.defaultNavigation)
        case .buttonTitle, .iconName, .bundleIdentifier, .packageName:
            return .init(propertyType: .primitive(.string))
        case .url:
            return .init(propertyType: .format(.uri))
        case .usesBackButton:
            return .init(propertyType: .primitive(.boolean))
        case .title:
            return .init(propertyType: .primitive(.string))
        case .closeButtonTitle:
            return .init(propertyType: .primitive(.string))
        }
    }

    public static func examples() -> [RSDWebViewUIActionObject] {
        var titleAction = RSDWebViewUIActionObject(url: "About_Dogs.html", buttonTitle: "Go, Dogs! Go")
        titleAction.usesBackButton = true
        titleAction.title = "Go, Dogs! Go"
        let imageAction = RSDWebViewUIActionObject(url: "About_Dogs.html", iconName: "iconInfo", bundleIdentifier: "org.example.SharedResources")
        return [titleAction, imageAction]
    }
}

extension RSDVideoViewUIActionObject : DocumentableStruct {
    public static func codingKeys() -> [CodingKey] {
        CodingKeys.allCases
    }
    
    public static func isRequired(_ codingKey: CodingKey) -> Bool {
        guard let key = codingKey as? CodingKeys else { return false }
        return key == .serializableType || key == .url
    }
    
    public static func documentProperty(for codingKey: CodingKey) throws -> DocumentProperty {
        guard let key = codingKey as? CodingKeys else {
            throw DocumentableError.invalidCodingKey(codingKey, "\(codingKey) is not recognized for this class")
        }
        switch key {
        case .serializableType:
            return .init(constValue: ButtonActionInfoType.defaultNavigation)
        case .buttonTitle, .iconName, .bundleIdentifier, .packageName:
            return .init(propertyType: .primitive(.string))
        case .url:
            return .init(propertyType: .format(.uri))
        }
    }

    public static func examples() -> [RSDVideoViewUIActionObject] {
        let titleAction = RSDVideoViewUIActionObject(url: "About_Dogs.mp4", buttonTitle: "Go, Dogs! Go")
        let imageAction = RSDVideoViewUIActionObject(url: "About_Dogs.mp4", iconName: "iconInfo", bundleIdentifier: "org.example.SharedResources")
        return [titleAction, imageAction]
    }
}
