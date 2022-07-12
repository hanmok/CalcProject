//
//  DutchpayManagerTest.swift
//  Calie
//
//  Created by Mac mini on 2022/07/12.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import XCTest
import CoreData
@testable import Calie

class SampleGatheringManagerTest: XCTestCase {

    var sampleManager: SampleManager!
    var coreDataStack: SampleCoreDataTestStack!

    override func setUp() {
        super.setUp()
        coreDataStack = SampleCoreDataTestStack()
//        Thread 1: Fatal error: Unexpectedly found nil while implicitly unwrapping an Optional value
        // coreDatStack
        
        sampleManager = SampleManager(mainContext: coreDataStack.mainContext)
        }

    func testCreateGathering() {
        sampleManager.createSampleGathering(title: "developers")

//        let gathering = sampleManager.fetchSampleGatherings()
        
//        XCTAssertNil(gathering)
        
        let gathering = sampleManager.fetchSampleGathering(withTitle: "developers")!

        XCTAssertEqual("developers", gathering.title)
    }

    func test_update_gathering() {
        let gathering = sampleManager.createSampleGathering(title: "developers")!
        gathering.title = "jiwon"
//        gathering.setValue("jiwon", forKey: .Gathering.title)
        sampleManager.updateSampleGathering(sampleGathering: gathering)

//        let testUpdated = sampleManager.fetchSampleGathering(withTitle: "jiwon")
//        XCTAssertNil(testUpdated)
        
        let updated = sampleManager.fetchSampleGathering(withTitle: "jiwon")!

        XCTAssertNil(sampleManager.fetchSampleGathering(withTitle:"developers"))
        XCTAssertEqual("jiwon", updated.title)
    }

    func test_delete_gathering() {
        let gatheringA = sampleManager.createSampleGathering(title: "A")!
        let gatheringB = sampleManager.createSampleGathering(title: "B")!
        let gatheringC = sampleManager.createSampleGathering(title: "C")!

        sampleManager.deleteSampleGathering(sampleGathering: gatheringB)

//        let testGatherings = sampleManager.fetchGatherings()
//        XCTAssertNil(testGatherings)
        
        let gatherings = sampleManager.fetchSampleGatherings()!

        XCTAssertEqual(gatherings.count, 2)
        XCTAssertTrue(gatherings.contains(gatheringA))
        XCTAssertTrue(gatherings.contains(gatheringC))
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
