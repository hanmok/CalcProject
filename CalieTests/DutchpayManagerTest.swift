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

class DutchpayManagerTest: XCTestCase {

    var dutchpayManager: DutchManager!
    var coreDataStack: CoreDataTestStack!

    override func setUp() {
        super.setUp()
        coreDataStack = CoreDataTestStack()
        
        dutchpayManager = DutchManager(mainContext: coreDataStack.mainContext)
        }

    func testCreateGathering() {
        dutchpayManager.createGathering(title: "developers")

        let gathering = dutchpayManager.fetchGathering(.title("developers"))!

        XCTAssertEqual("developers", gathering.title)
    }
    
    func fetchingLatestGathering() {
        dutchpayManager.createGathering(title: "first")
        dutchpayManager.createGathering(title: "second")
        
        let latestGathering = dutchpayManager.fetchGathering(.latest)
        
        XCTAssertEqual(latestGathering!.title, "second")
    }

    func test_update_gathering() {
        let gathering = dutchpayManager.createGathering(title: "developers")!
        
        gathering.title = "jiwon"
        
        dutchpayManager.update()

        
        let updated = dutchpayManager.fetchGathering(.title("jiwon"))!

        XCTAssertEqual("jiwon", updated.title)
    }

    func test_delete_gathering() {
        let gatheringA = dutchpayManager.createGathering(title: "A")!
        let gatheringB = dutchpayManager.createGathering(title: "B")!
        let gatheringC = dutchpayManager.createGathering(title: "C")!

        dutchpayManager.deleteGathering(gathering: gatheringB)

        
        let gatherings = dutchpayManager.fetchGatherings()

        XCTAssertEqual(gatherings.count, 2)
        XCTAssertTrue(gatherings.contains(gatheringA))
        XCTAssertTrue(gatherings.contains(gatheringC))
    }
}


// Advanced features ( DutchUnit )
extension DutchpayManagerTest {
    // 하나 생성 후 확인
    func test_addDutchUnit() {
        let gathering = dutchpayManager.createGathering(title: "developers")!
        
        let person = dutchpayManager.createPerson(name: "new Person")
        let personDetails = dutchpayManager.createPersonDetail(person: person, isAttended: true, spentAmount: 100)
        
        let dutchUnit = dutchpayManager.createDutchUnit(spentTo: "somewhere", spentAmount: 100, personDetails: [personDetails], spentDate: Date())
        
        gathering.dutchUnits.update(with: dutchUnit)
        
        XCTAssertEqual(gathering.dutchUnits.first!.placeName, dutchUnit.placeName)
    }
    
    
    // DutchUnit 생성 후 수정 (인원 추가.)
    // 1 DutchUnit 1 Person -> + 1 Person, change Place name
    func test_updateDutchUnit1_addPerson() {
        let gathering = dutchpayManager.createGathering(title: "developers")!
        
        let originalPerson = dutchpayManager.createPerson(name: "original Person")
        let originalPersonDetail = dutchpayManager.createPersonDetail(person: originalPerson, isAttended: true, spentAmount: 300)
        
        let originalDutchUnit = dutchpayManager.createDutchUnit(spentTo: "somewhere", spentAmount: 300, personDetails: [originalPersonDetail], spentDate: Date())
        
        // add dutchUnit to gathering
        gathering.dutchUnits.update(with: originalDutchUnit)
        
        let newPerson = dutchpayManager.createPerson(name: "added Person")
        let additionalPersonDetail = dutchpayManager.createPersonDetail(person: newPerson, isAttended: true, spentAmount: 0)
        
        let updatedDutchUnit = dutchpayManager.createDutchUnit(spentTo: "updatedPlace", spentAmount: 300, personDetails: [originalPersonDetail, additionalPersonDetail], spentDate: Date())
        
        
        // update dutchUnit
        dutchpayManager.updateDutchUnit(target: originalDutchUnit, with: updatedDutchUnit)
        
        

        XCTAssertEqual(gathering.dutchUnits.count, 1)
        // chck if gathering has the same dutchUnit
        XCTAssertEqual(gathering.dutchUnits.first!.placeName, updatedDutchUnit.placeName)
        
        XCTAssertEqual(gathering.dutchUnits.first!.personDetails.count, 2)
        // get totalCost from DutchUnits
        XCTAssertEqual(gathering.totalCost, 300)
    }
    
    // 2 person -> 1 person, with the same spentAmount
    func test_updateDutchUnit2_removePerson() {
        let gathering = dutchpayManager.createGathering(title: "developers")!
        
        let person1 = dutchpayManager.createPerson(name: "original Person")
        let person2 = dutchpayManager.createPerson(name: "added Person")
       
        let personDetail1 = dutchpayManager.createPersonDetail(person: person1, isAttended: true, spentAmount: 300)
        let personDetail2 = dutchpayManager.createPersonDetail(person: person2, isAttended: true, spentAmount: 200)
       
        
        let originalDutchUnit = dutchpayManager.createDutchUnit(spentTo: "somewhereBefore", spentAmount: 500, personDetails: [personDetail1, personDetail2], spentDate: Date())

        gathering.dutchUnits.update(with: originalDutchUnit)
        
        let updatedDutchUnit = dutchpayManager.createDutchUnit(spentTo: "somewhereAfter", spentAmount: 500, personDetails: [personDetail1], spentDate: Date())
        
        
        dutchpayManager.updateDutchUnit(target: originalDutchUnit, with: updatedDutchUnit)
        
        
        XCTAssertEqual(gathering.dutchUnits.count, 1)
        XCTAssertEqual(gathering.dutchUnits.first!.placeName, "somewhereAfter")
        XCTAssertEqual(gathering.dutchUnits.first!.personDetails.count, 1)
        XCTAssertEqual(gathering.totalCost, 500)

        XCTAssertFalse(gathering.dutchUnits.first!.isAmountEqual)
    }
    
    // 1 dutchUnit -> 0 dutchUnit
    func test_deleteDutchUnit() {
        let gathering = dutchpayManager.createGathering(title: "developers")!
        
        let originalPerson = dutchpayManager.createPerson(name: "original Person")
        let originalPersonDetail = dutchpayManager.createPersonDetail(person: originalPerson, isAttended: true, spentAmount: 100)
        
        let originalDutchUnit = dutchpayManager.createDutchUnit(spentTo: "somewhere", spentAmount: 100, personDetails: [originalPersonDetail], spentDate: Date())
        
        // add dutchUnit to gathering
        gathering.dutchUnits.update(with: originalDutchUnit)
        
        gathering.dutchUnits.remove(originalDutchUnit)

        XCTAssertEqual(gathering.dutchUnits.count, 0)
    }
    // add person in participantsController,
    
    func test_gathering_updatePeople() {
        
    }
    
    func test_gathering_addPerson() {
        let gathering = dutchpayManager.createGathering(title: "developers")!
        
        let person1 = dutchpayManager.createPerson(name: "person1")
        let person2 = dutchpayManager.createPerson(name: "person2")
        let person3 = dutchpayManager.createPerson(name: "person3")


        let personDetail1 = dutchpayManager.createPersonDetail(person: person1, isAttended: true, spentAmount: 100)
        let personDetail2 = dutchpayManager.createPersonDetail(person: person2, isAttended: true, spentAmount: 0)
        
        
        let originalMemberDetails = [personDetail1, personDetail2]
        
        let originalDutchUnit = dutchpayManager.createDutchUnit(spentTo: "somewhere", spentAmount: 100, personDetails: originalMemberDetails, spentDate: Date())
        
        dutchpayManager.addDutchUnit(of: originalDutchUnit, to: gathering)

        XCTAssertEqual(gathering.dutchUnits.first!.personDetails.count, 2)
        
        
        dutchpayManager.addMorePeople(addedPeople: [person3], currentGathering: gathering)
        
        XCTAssertEqual(gathering.dutchUnits.first!.personDetails.count, 3)
        
        XCTAssertEqual(gathering.people.count, 3)
    }
    
    
    
    func test_gathering_removePerson() {
        
    }
    
}



extension DutchpayManagerTest {

    
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
