//
//  RSDTaskResultObject.swift
//  Research
//
//  Copyright © 2017-2022 Sage Bionetworks. All rights reserved.
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

/// `RSDTaskResultObject` is a result associated with a task. This object includes a step history, task run UUID,
/// schema identifier, and asynchronous results.
public final class RSDTaskResultObject : AbstractAssessmentResultObject, SerializableResultData, AssessmentResult, MultiplatformResultData, RSDTaskResult {
    
    public override class func defaultType() -> SerializableResultType {
        .task
    }

    private enum CodingKeys : String, OrderedEnumCodingKey {
        case nodePath
    }
    
    /// Default initializer for this object.
    ///
    /// - parameters:
    ///     - identifier: The identifier string.
    ///     - schemaInfo: The schemaInfo associated with this task result. Default = `nil`.
    public init(identifier: String,
                versionString: String? = nil,
                assessmentIdentifier: String? = nil,
                schemaIdentifier: String? = nil) {
        super.init(identifier: identifier, versionString: versionString, assessmentIdentifier: assessmentIdentifier, schemaIdentifier: schemaIdentifier)
    }
    
    /// Initialize from a `Decoder`. This decoding method will use the `RSDFactory` instance associated
    /// with the decoder to decode the `stepHistory`, `asyncResults`, and `schemaInfo`.
    ///
    /// - parameter decoder: The decoder to use to decode this instance.
    /// - throws: `DecodingError`
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        guard path.isEmpty else { return }
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let nodePath = try container.decodeIfPresent([String].self, forKey: .nodePath) {
            self.path = nodePath.map { .init(identifier: $0, direction: .forward) }
        }
    }
    
    /// Encode the result to the given encoder.
    /// - parameter encoder: The encoder to use to encode this instance.
    /// - throws: `EncodingError`
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(path.map { $0.identifier }, forKey: .nodePath)
    }
    
    public func deepCopy() -> RSDTaskResultObject {
        let copy = type(of: self).init(identifier: self.identifier,
                                       versionString: self.versionString,
                                       assessmentIdentifier: self.assessmentIdentifier,
                                       schemaIdentifier: self.schemaIdentifier)
        copy.startDateTime = self.startDateTime
        copy.endDateTime = self.endDateTime
        copy.taskRunUUID = self.taskRunUUID
        copy.stepHistory = self.stepHistory.map { $0.deepCopy() }
        copy.asyncResults = self.asyncResults?.map { $0.deepCopy() }
        copy.path = self.path
        return copy
    }
}
