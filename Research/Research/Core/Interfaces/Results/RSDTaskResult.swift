//
//  RSDTaskResult.swift
//  
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

import JsonModel
import Foundation
import AssessmentModel

public protocol RSDTaskResult : BranchNodeResult {
}

public extension RSDTaskResult  {
    
    /// Find a result within the step history.
    /// - parameter step: The step associated with the result.
    /// - returns: The result or `nil` if not found.
    func findResult(for step: RSDStep) -> ResultData? {
        return self.stepHistory.first(where: { $0.identifier == step.identifier })
    }
    
    /// Append the async results with the given result, replacing the previous instance with the same identifier.
    /// The step history is used to describe the path you took to get to where you are going, whereas
    /// the asynchronous results include any canonical results that are independent of path.
    /// - parameter result:  The result to add to the async results.
    func appendAsyncResult(with result: ResultData) {
        insert(result)
    }
    
    var nodePath : [String] {
        self.path.map { $0.identifier }
    }
}
