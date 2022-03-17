//
//  AssessmentModel+Bridging.swift
//  
//
//  Copyright © 2022 Sage Bionetworks. All rights reserved.
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
import AssessmentModel
import JsonModel

extension ButtonActionInfoObject : RSDUIAction {
}

extension AbstractNodeObject : RSDUIActionHandler {
    
    public func shouldHideAction(for actionType: RSDUIActionType, on step: RSDStep) -> Bool? {
        self.shouldHideButton(actionType.buttonType, node: step)
    }
    
    public func action(for actionType: RSDUIActionType, on step: RSDStep) -> RSDUIAction? {
        self.button(actionType.buttonType, node: step) as? RSDUIAction
    }
}

public extension ButtonType {
    var actionType: RSDUIActionType {
        .init(rawValue: self.rawValue)
    }
}

extension AbstractStepObject : RSDUIStep {

    public var stepType: RSDStepType {
        .init(rawValue: self.typeName)
    }
    
    public func instantiateStepResult() -> ResultData {
        instantiateResult()
    }
    
    public func validate() throws {
        // do nothing
    }
    
    public var footnote: String? {
        nil
    }
}

extension ChoiceQuestionStepObject : RSDQuestionStep {
    public func instantiateDataSource(with parent: RSDPathComponent?, for supportedHints: Set<RSDFormUIHint>) -> RSDTableDataSource? {
        QuestionStepDataSource(step: self, parent: parent, supportedHints: supportedHints)
    }
}

extension SimpleQuestionStepObject : RSDQuestionStep {
    public func instantiateDataSource(with parent: RSDPathComponent?, for supportedHints: Set<RSDFormUIHint>) -> RSDTableDataSource? {
        QuestionStepDataSource(step: self, parent: parent, supportedHints: supportedHints)
    }
}

extension FetchableImage : RSDImageThemeElement {
}

extension AnimatedImage : RSDAnimatedImageThemeElement {
}

public protocol RSDNode : Node {
}

public protocol RSDNodeStep : RSDStep, RSDNode {
}

public extension RSDNode {
    var comment: String? { nil }
    
    func button(_ buttonType: ButtonType, node: Node) -> ButtonActionInfo? {
        nil
    }
    
    func shouldHideButton(_ buttonType: ButtonType, node: Node) -> Bool? {
        nil
    }
}

public extension RSDNodeStep {

    func instantiateResult() -> ResultData {
        self.instantiateStepResult()
    }
}
