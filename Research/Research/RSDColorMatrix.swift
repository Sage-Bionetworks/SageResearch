//
//  RSDColorMatrix.swift
//  Research
//
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
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

/// The color matrix is a shared singleton that allows for accessing the color pallettes using registered
/// libraries that are included within the Research framework.
public final class RSDColorMatrix {
    
    public static let shared = RSDColorMatrix()
    
    /// The color libraries that are registered with the Research framework.
    public let registeredLibraries: [RSDColorLibrary]
    
    /// The current version of the default color library.
    public var currentVersion: Int {
        return self.registeredLibraries.last!.version
    }
    
    private init() {
        guard let url = Bundle(for: RSDColorMatrix.self).url(forResource: "ColorMatrix", withExtension: "json")
            else {
                fatalError("Could not decode the color matrix. Something is very wrong.")
        }
        do {
            let data = try Data(contentsOf: url)
            let jsonDecoder = JSONDecoder()
            let libraries = try jsonDecoder.decode([RSDColorLibrary].self, from: data)
            self.registeredLibraries = libraries.sorted()
        }
        catch let err {
            fatalError("Could not decode the color matrix. Something is very wrong. \(err)")
        }
    }
    
    /// The library for a given version.
    public func library(for version: Int?) -> RSDColorLibrary {
        guard let ver = version,
            let library = self.registeredLibraries.first(where: { $0.version == ver })
            else {
                return self.registeredLibraries.last!
        }
        return library
    }
    
    /// Get the gray scale to use for a given version of the color library.
    public func grayScale(for version: Int?) -> RSDGrayScale {
        return self.library(for: version).grayScale ?? RSDGrayScale()
    }
    
    /// Get the color swatch associated with the given name.
    public func colorSwatch(for name: String, version: Int?) -> RSDColorSwatch? {
        guard let reserved = RSDReservedColorName(rawValue: name) else { return nil }
        return self.colorSwatch(for: reserved, version: version)
    }
    
    /// Get the color swatch associated with the given name.
    public func colorSwatch(for name: RSDReservedColorName, version: Int?) -> RSDColorSwatch? {
        let ver = min(name.version ?? Int.max, version ?? Int.max)
        let library = self.library(for: ver)
        return library.swatches.first(where: { $0.name == name.rawValue })
    }
    
    /// Get the color swatch associated with the given name.
    public func colorKey(for name: RSDReservedColorName, shade: RSDColorSwatch.Shade) -> RSDColorKey {
        guard let swatch = colorSwatch(for: name, version: nil)
            else {
                fatalError("Could not find a color for restricted color \(name).")
        }
        let mapping = swatch.mapping(for: shade)
        return RSDColorKey(index: mapping.index, swatch: swatch)!
    }

    
    /// Get the most appropriate color key for a given restricted color name.
    public func colorKey(for name: RSDReservedColorName, version: Int? = nil, index: Int? = nil) -> RSDColorKey {
        guard let swatch = colorSwatch(for: name, version: version)
            else {
                fatalError("Could not find a color for restricted color \(name).")
        }
        guard let idx = index, idx >= 0, idx < swatch.colorTiles.count
            else {
                return RSDColorKey(index: swatch.colorTiles.count - 1, swatch: swatch)!
        }
        return RSDColorKey(index: idx, swatch: swatch)!
    }
    
    public func colorMapping(for gray: RSDGrayScale.Shade, version: Int? = nil) -> RSDColorMapping {
        return self.grayScale(for: version).mapping(for: gray)
    }
    
    public func findColorTile(for color: RSDColor) -> RSDColorTile? {
        for colorTile in RSDGrayScale().colorTiles {
            if colorTile.color == color {
                return colorTile
            }
        }
        for library in self.registeredLibraries.reversed() {
            for swatch in library.swatches {
                for colorTile in swatch.colorTiles {
                    if colorTile.color == color {
                        return colorTile
                    }
                }
            }
            if let grayScale = library.grayScale {
                for colorTile in grayScale.colorTiles {
                    if colorTile.color == color {
                        return colorTile
                    }
                }
            }
        }
        return nil
    }
}


/// A color library is a versioned collection of color swatches.
public struct RSDColorLibrary : Codable, Equatable, Hashable, Comparable {

    /// The version for this library.
    public var version: Int
    
    /// A gray scale for the color library.
    public var grayScale: RSDGrayScale?
    
    /// A list of all the color swatches included in this color library.
    public var swatches: Set<RSDColorSwatch>
    
    /// Get the color swatch associated with the given name.
    public func colorSwatch(for name: String) -> RSDColorSwatch? {
        return self.swatches.first(where: { $0.name == name })
    }
    
    /// Get the color swatch associated with the given name.
    public func colorSwatch(for name: RSDReservedColorName) -> RSDColorSwatch? {
        return self.colorSwatch(for: name.rawValue)
    }
    
    public static func < (lhs: RSDColorLibrary, rhs: RSDColorLibrary) -> Bool {
        return lhs.version < rhs.version
    }
}


/// A listing of the color names that are already assigned by the base framework using "ColorMatrix.json" as
/// the source file.
public enum RSDReservedColorName : RawRepresentable, Equatable, Hashable, Codable {
    
    case pallette(Pallette)
    public enum Pallette : String, CaseIterable {
        case royal
        case butterscotch
        case powder
        case turquoise
        case coral
        case apricot
        case blueberry
        case apple
        case rose
        case lavender
        case slate
        case fern
        case cloud
        case stone
    }
    
    case special(Special)
    public enum Special : String, CaseIterable {
        case errorRed
        case successGreen
    }
    
    /// Maximum version in which a given reserved color name is expected to be included. If `nil` this color
    /// name should still be included in the color matrix in the most recent library.
    public var version: Int? {
        return nil
    }
    
    public init?(rawValue: String) {
        if let pallette = Pallette(rawValue: rawValue) {
            self = .pallette(pallette)
        }
        else if let special = Special(rawValue: rawValue) {
            self = .special(special)
        }
        else {
            return nil
        }
    }
    
    public var rawValue: String {
        switch self {
        case .pallette(let value):
            return value.rawValue
        case .special(let value):
            return value.rawValue
        }
    }
}
