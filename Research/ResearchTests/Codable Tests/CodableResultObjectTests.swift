//
//  CodableResultObjectTests.swift
//  ResearchTests
//

import XCTest
@testable import Research
import JsonModel
import ResultModel

class CodableResultObjectTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Use a statically defined timezone.
        ISO8601TimestampFormatter.timeZone = TimeZone(secondsFromGMT: Int(-2.5 * 60 * 60))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testResultObject_Codable() {
        let json = """
        {
            "identifier": "foo",
            "type": "base",
            "startDate": "2017-10-16T22:28:09.000-02:30",
            "endDate": "2017-10-16T22:30:09.000-02:30"
        }
        """.data(using: .utf8)! // our data in native (JSON) format
        
        do {
            
            let object = try decoder.decode(ResultObject.self, from: json)
            
            XCTAssertEqual(object.identifier, "foo")
            XCTAssertEqual(object.serializableType, .base)
            XCTAssertGreaterThan(object.endDate, object.startDate)
            
            let jsonData = try encoder.encode(object)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertEqual(dictionary["type"] as? String, "base")
            XCTAssertEqual(dictionary["startDate"] as? String, "2017-10-16T22:28:09.000-02:30")
            XCTAssertEqual(dictionary["endDate"] as? String, "2017-10-16T22:30:09.000-02:30")

        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
        }
    }

    
    func testStepCollectionResultObject_Codable() {
        let stepResult = CollectionResultObject(identifier: "foo")
        let answerResult1 = AnswerResultObject(identifier: "input1", value: .boolean(true))
        let answerResult2 = AnswerResultObject(identifier: "input2", value: .integer(42))
        stepResult.endDateTime = Date() // Set an end time (can be nil)
        stepResult.children = [answerResult1, answerResult2]
        
        do {
            let jsonData = try encoder.encode(stepResult)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertNotNil(dictionary["startDate"])
            XCTAssertNotNil(dictionary["endDate"])
            if let results = dictionary["children"] as? [[String : Any]] {
                XCTAssertEqual(results.count, 2)
                if let result1 = results.first {
                    XCTAssertEqual(result1["identifier"] as? String, "input1")
                }
            } else {
                XCTFail("Failed to encode the input results.")
            }
            
            let object = try decoder.decode(CollectionResultObject.self, from: jsonData)
            
            XCTAssertEqual(object.identifier, stepResult.identifier)
            XCTAssertEqual(object.startDate.timeIntervalSinceNow, stepResult.startDate.timeIntervalSinceNow, accuracy: 1)
            XCTAssertEqual(object.endDate.timeIntervalSinceNow, stepResult.endDate.timeIntervalSinceNow, accuracy: 1)
            XCTAssertEqual(object.children.count, 2)
            
            if let result1 = object.children.first as? AnswerResultObject {
                XCTAssertEqual(result1.identifier, answerResult1.identifier)
                let expected = AnswerTypeBoolean()
                XCTAssertEqual(expected, answerResult1.jsonAnswerType as? AnswerTypeBoolean)
                XCTAssertEqual(result1.startDate.timeIntervalSinceNow, answerResult1.startDate.timeIntervalSinceNow, accuracy: 1)
                XCTAssertEqual(result1.endDate.timeIntervalSinceNow, answerResult1.endDate.timeIntervalSinceNow, accuracy: 1)
                XCTAssertEqual(result1.jsonValue, answerResult1.jsonValue)
            } else {
                XCTFail("\(object.children) did not decode the results as expected")
            }
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
        }
    }
    
    func testTaskResultObject_Codable() {
        let taskResult = RSDTaskResultObject(identifier: "foo",
                                             versionString: "3",
                                             assessmentIdentifier: "foo 2",
                                             schemaIdentifier: "bar")
        let answerResult1 = AnswerResultObject(identifier: "step1", value: .boolean(true))
        let answerResult2 = AnswerResultObject(identifier: "step2", value: .integer(42))
        taskResult.stepHistory = [answerResult1, answerResult2]
        
        do {
            let jsonData = try encoder.encode(taskResult)
            guard let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any]
                else {
                    XCTFail("Encoded object is not a dictionary")
                    return
            }
            
            XCTAssertEqual(dictionary["identifier"] as? String, "foo")
            XCTAssertNotNil(dictionary["startDate"])
            XCTAssertNil(dictionary["endDate"])

            if let results = dictionary["stepHistory"] as? [[String : Any]] {
                XCTAssertEqual(results.count, 2)
                if let result1 = results.first {
                    XCTAssertEqual(result1["identifier"] as? String, "step1")
                }
            }
            else {
                XCTFail("Failed to encode the step history.")
            }
            
            XCTAssertEqual(dictionary["assessmentIdentifier"] as? String, "foo 2")
            XCTAssertEqual(dictionary["schemaIdentifier"] as? String, "bar")
            XCTAssertEqual(dictionary["versionString"] as? String, "3")
            
            let object = try decoder.decode(RSDTaskResultObject.self, from: jsonData)
            
            XCTAssertEqual(object.identifier, taskResult.identifier)
            XCTAssertEqual(object.startDate.timeIntervalSinceNow, taskResult.startDate.timeIntervalSinceNow, accuracy: 1)
            XCTAssertEqual(object.endDate.timeIntervalSinceNow, taskResult.endDate.timeIntervalSinceNow, accuracy: 1)
            XCTAssertEqual(object.stepHistory.count, 2)
            
            if let result1 = object.stepHistory.first as? AnswerResultObject {
                XCTAssertEqual(result1.identifier, answerResult1.identifier)
                let expected = AnswerTypeBoolean()
                XCTAssertEqual(expected, answerResult1.jsonAnswerType as? AnswerTypeBoolean)
                XCTAssertEqual(result1.startDate.timeIntervalSinceNow, answerResult1.startDate.timeIntervalSinceNow, accuracy: 1)
                XCTAssertEqual(result1.endDate.timeIntervalSinceNow, answerResult1.endDate.timeIntervalSinceNow, accuracy: 1)
                XCTAssertEqual(result1.jsonValue, answerResult1.jsonValue)
            } else {
                XCTFail("\(object.stepHistory) did not decode the results as expected")
            }
            
            XCTAssertEqual(object.schemaIdentifier, "bar")
            XCTAssertEqual(object.versionString, "3")
            XCTAssertEqual(object.assessmentIdentifier, "foo 2")
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
        }
    }
}
