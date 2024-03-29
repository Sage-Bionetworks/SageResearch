//
//  StepViewModelTests.swift
//  ResearchTests_iOS
//

import JsonModel
import ResultModel
import XCTest
@testable import Research

class StepViewModelTests: XCTestCase {
    
    var top: RSDTaskViewModel!
    var section3: RSDTaskStepNode!
    var sectionA: RSDTaskStepNode!
    var stepXModel: RSDStepViewModel!
    var stepX: RSDUIStepObject!
    var task: AssessmentTaskObject!
    
    override func setUp() {
        super.setUp()
        
        setupTask()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAction_NilAction() {

        let action = stepXModel.action(for: .navigation(.cancel))
        XCTAssertNil(action)
    }
    
    func testAction_TopActionOnly() {

        // set a non-nil action at the top level
        task.actions = [.navigation(.cancel) : RSDUIActionObject(buttonTitle: "Cancel")]
        
        let action = stepXModel.action(for: .navigation(.cancel))
        XCTAssertNotNil(action)
        XCTAssertEqual(action?.buttonTitle, "Cancel")
    }
    
    func testAction_TopActionAndStepAction() {

        // set a non-nil action at the top level
        task.actions = [.navigation(.cancel) : RSDUIActionObject(buttonTitle: "Cancel")]
        stepX.actions = [.navigation(.cancel) : RSDUIActionObject(buttonTitle: "Back")]
        
        let action = stepXModel.action(for: .navigation(.cancel))
        XCTAssertNotNil(action)
        XCTAssertEqual(action?.buttonTitle, "Back")
    }
    
    func testShouldHideAction_NilAction() {

        XCTAssertFalse(stepXModel.shouldHideAction(for: .navigation(.cancel)))
        XCTAssertFalse(stepXModel.shouldHideAction(for: .navigation(.goForward)))
        XCTAssertFalse(stepXModel.shouldHideAction(for: .navigation(.goBackward)))
        XCTAssertTrue(stepXModel.shouldHideAction(for: .navigation(.learnMore)))
        XCTAssertTrue(stepXModel.shouldHideAction(for: .navigation(.skip)))
    }
    
    func testShouldHideAction_TaskLevelShouldHide() {
        
        task.shouldHideActions = [.navigation(.cancel), .navigation(.goForward), .navigation(.goBackward), .navigation(.skip)]
        
        XCTAssertTrue(stepXModel.shouldHideAction(for: .navigation(.cancel)))
        XCTAssertTrue(stepXModel.shouldHideAction(for: .navigation(.goForward)))
        XCTAssertTrue(stepXModel.shouldHideAction(for: .navigation(.goBackward)))
        XCTAssertTrue(stepXModel.shouldHideAction(for: .navigation(.skip)))
    }
    
    func testShouldHideAction_TaskLevelShouldHide_NonNilAction() {
        
        task.shouldHideActions = [.navigation(.cancel), .navigation(.goForward), .navigation(.goBackward), .navigation(.skip)]
        stepX.actions = [.navigation(.cancel) : RSDUIActionObject(buttonTitle: "Cancel"),
                         .navigation(.goForward) : RSDUIActionObject(buttonTitle: "Next"),
                         .navigation(.goBackward) : RSDUIActionObject(buttonTitle: "Back"),
                         .navigation(.skip) : RSDUIActionObject(buttonTitle: "Skip")]
        
        XCTAssertFalse(stepXModel.shouldHideAction(for: .navigation(.cancel)))
        XCTAssertFalse(stepXModel.shouldHideAction(for: .navigation(.goForward)))
        XCTAssertFalse(stepXModel.shouldHideAction(for: .navigation(.goBackward)))
        XCTAssertFalse(stepXModel.shouldHideAction(for: .navigation(.skip)))
    }
    
    func testShouldHideAction_StepLevelShouldHide() {
        
        stepX.shouldHideActions = [.navigation(.cancel), .navigation(.goForward), .navigation(.goBackward), .navigation(.skip)]
        
        XCTAssertTrue(stepXModel.shouldHideAction(for: .navigation(.cancel)))
        XCTAssertTrue(stepXModel.shouldHideAction(for: .navigation(.goForward)))
        XCTAssertTrue(stepXModel.shouldHideAction(for: .navigation(.goBackward)))
        XCTAssertTrue(stepXModel.shouldHideAction(for: .navigation(.skip)))
    }
    
    func setupTask() {
        
        let step1 = RSDUIStepObject(identifier: "step1")
        let step2 = RSDUIStepObject(identifier: "step2")
        stepX = RSDUIStepObject(identifier: "stepX")
        let stepY = RSDUIStepObject(identifier: "stepY")
        let stepZ = RSDUIStepObject(identifier: "stepZ")
        let stepA = RSDSectionStepObject(identifier: "stepA", steps: [stepX, stepY, stepZ])
        let stepB = RSDUIStepObject(identifier: "stepB")
        let stepC = RSDUIStepObject(identifier: "stepC")
        let step3 = RSDSectionStepObject(identifier: "step3", steps: [stepA, stepB, stepC])
        let step4 = RSDUIStepObject(identifier: "step4")
        task = AssessmentTaskObject(identifier: "task", steps: [step1, step2, step3, step4])
        
        top = RSDTaskViewModel(task: task)
        section3 = RSDTaskStepNode(sectionStep: step3, parentPath: top)
        top.currentChild = section3
        sectionA = RSDTaskStepNode(sectionStep: stepA, parentPath: section3)
        section3.currentChild = sectionA
        stepXModel = RSDStepViewModel(step: stepX, parent: sectionA)
        sectionA.currentChild = stepXModel
        
        top.taskResult.stepHistory = [ResultObject(identifier: "step1"),
                                      ResultObject(identifier: "step2")]
    }
    
    func testResultSummaryStepViewModel_String() {
        let resultStep = RSDResultSummaryStepObject(identifier: "feedback", resultIdentifier: "foo")
        let answerResult = AnswerResultObject(identifier: "foo", value: .string("blu"))
        let taskResult = RSDTaskResultObject(identifier: "magoo")
        taskResult.stepHistory = [answerResult]
        let stepViewModel = RSDResultSummaryStepViewModel(step: resultStep, parent: nil)
        stepViewModel.taskResult = taskResult
        
        let resultText = stepViewModel.resultText
        XCTAssertNotNil(resultText)
        XCTAssertEqual(resultText, "blu")
    }
    
    func testResultSummaryStepViewModel_Decimal() {
        let resultStep = RSDResultSummaryStepObject(identifier: "feedback", resultIdentifier: "foo")
        let answerResult = AnswerResultObject(identifier: "foo", value: .number(1.234211))
        let taskResult = RSDTaskResultObject(identifier: "magoo")
        taskResult.stepHistory = [answerResult]
        let stepViewModel = RSDResultSummaryStepViewModel(step: resultStep, parent: nil)
        stepViewModel.taskResult = taskResult
        
        let resultText = stepViewModel.resultText
        XCTAssertNotNil(resultText)
        XCTAssertEqual(resultText, "1")
    }
    
    func testResultSummaryStepViewModel_Collection() {
        let resultStep = RSDResultSummaryStepObject(identifier: "feedback", resultIdentifier: "foo", unitText: nil, stepResultIdentifier: "step2")

        let result1 = CollectionResultObject(identifier: "step1")
        let answerResult1 = AnswerResultObject(identifier: "foo", value: .string("magoo"))
        result1.children = [answerResult1, ResultObject(identifier: "roo")]
        
        let result2 = CollectionResultObject(identifier: "step2")
        let answerResult2 = AnswerResultObject(identifier: "foo", value: .string("blu"))
        result2.children = [answerResult2, ResultObject(identifier: "roo")]
        
        let taskResult = RSDTaskResultObject(identifier: "magoo")
        taskResult.stepHistory = [result1, result2]
        
        let stepViewModel = RSDResultSummaryStepViewModel(step: resultStep, parent: nil)
        stepViewModel.taskResult = taskResult
        
        let resultText = stepViewModel.resultText
        XCTAssertNotNil(resultText)
        XCTAssertEqual(resultText, "blu")
    }
}
