//
//  RSDResultType.swift
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

/// `RSDResultType` is an extendable string enum used by `RSDFactory` to create the appropriate
/// result type.
extension SerializableResultType {

    /// Defaults to creating a `RSDResult`.
    public static let base: SerializableResultType = "base"
    
    /// Defaults to creating a `RSDTaskResult`.
    public static let task: SerializableResultType = "task"
    
    /// Defaults to creating a `SectionResultObject`.
    public static let section: SerializableResultType = "section"
    
    /// Defaults to creating a `RSDNavigationResult`.
    public static let navigation: SerializableResultType = "navigation"
}

// List of the serialization examples included in this library.

extension ResultDataSerializer {
    func libraryExamples() -> [SerializableResultData] {
        [
            RSDTaskResultObject.examples().first!,
            SectionResultObject.examples().first!,
            RSDResultObject.examples().first!,
            RSDCollectionResultObject.examples().first!,
        ]
    }
    
    func registerLibraryExamples(with factory: RSDFactory) {
        self.add(contentsOf: libraryExamples())
        factory.registerSerializer(self, for: ResultData.self)
    }
}

