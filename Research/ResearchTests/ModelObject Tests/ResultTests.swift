//
//  ResultTests.swift
//  ResearchTests_iOS
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

import XCTest
@testable import ResearchV2

class ResultTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCollectionResultExtensions() {
        
        var collection = RSDCollectionResultObject(identifier: "test")
        let answers = ["a" : 3, "b": 5, "c" : 7]
        answers.forEach {
            let answerResult = RSDAnswerResultObject(identifier: $0.key, answerType: .integer, value: $0.value)
            collection.appendInputResults(with: answerResult)
        }
        
        let answerMap = collection.answers()
        XCTAssertEqual(answerMap as? [String : Int], answers)

        let answerB = RSDAnswerResultObject(identifier: "a", answerType: .integer, value: 8)
        let previous = collection.appendInputResults(with: answerB)
        XCTAssertNotNil(previous)
        if let previousResult = previous as? RSDAnswerResultObject {
            XCTAssertEqual(previousResult.value as? Int, 3)
        }
        else {
            XCTFail("Failed to return the previous answer")
        }
        
        if let newResult = collection.findAnswerResult(with: "a") {
            XCTAssertEqual(newResult.value as? Int, 8)
        }
        else {
            XCTFail("Failed to find the new answer")
        }
        
        let removed = collection.removeInputResult(with: "b")
        XCTAssertNotNil(removed)
        if let removedResult = removed as? RSDAnswerResultObject {
            XCTAssertEqual(removedResult.value as? Int, 5)
        }
        else {
            XCTFail("Failed to remove the result")
        }
        
        let removedD = collection.removeInputResult(with: "d")
        XCTAssertNil(removedD)
    }
    
    func testAnswerTypeEquality_Boolean() {
        let a = RSDAnswerResultType(baseType: .boolean, sequenceType: nil, formDataType: .base(.boolean), dateFormat: nil, unit: nil, sequenceSeparator: nil)
        let b = RSDAnswerResultType.boolean
        XCTAssertEqual(a, b)
        XCTAssertEqual(a.hashValue, b.hashValue)
    }

    func testAnswerTypeEquality_StringCollection() {
        let a = RSDAnswerResultType(baseType: .string, sequenceType: .array, formDataType: .collection(.multipleChoice, .string), dateFormat: nil, unit: nil, sequenceSeparator: "-")
        let b = RSDAnswerResultType(baseType: .string, sequenceType: .array, formDataType: nil, dateFormat: nil, unit: nil, sequenceSeparator: "-")
        let c = RSDAnswerResultType(baseType: .string, sequenceType: .array, formDataType: nil, dateFormat: nil, unit: nil, sequenceSeparator: nil)
        XCTAssertEqual(a, b)
        XCTAssertEqual(a.hashValue, b.hashValue)
        XCTAssertNotEqual(a, c)
        XCTAssertNotEqual(a.hashValue, c.hashValue)
    }
    
    func testAnswerTypeEquality_Date() {
        let a = RSDAnswerResultType(baseType: .date, sequenceType: nil, formDataType: .base(.date), dateFormat: "YYYY-mm", unit: nil, sequenceSeparator: nil)
        let b = RSDAnswerResultType(baseType: .date, sequenceType: nil, formDataType: nil, dateFormat: "YYYY-mm", unit: nil, sequenceSeparator: nil)
        let c = RSDAnswerResultType.date
        XCTAssertEqual(a, b)
        XCTAssertEqual(a.hashValue, b.hashValue)
        XCTAssertNotEqual(a, c)
        XCTAssertNotEqual(a.hashValue, c.hashValue)
    }
}
