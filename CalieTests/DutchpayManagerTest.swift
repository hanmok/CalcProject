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

    // Gathering 생성
    func test_createGathering() {
        dutchpayManager.createGathering(title: "developers")

        let gathering = dutchpayManager.fetchGathering(.title("developers"))!

        XCTAssertEqual("developers", gathering.title)
    }
    
    
    func test_fetchLatestGathering() {
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
    // DutchUnit 하나 생성
    func test_addDutchUnit() {
        let gathering = dutchpayManager.createGathering(title: "developers")!
        
        let person = dutchpayManager.createPerson(name: "new Person")
        let personDetails = dutchpayManager.createPersonDetail(person: person, isAttended: true, spentAmount: 100)
        
        let dutchUnit = dutchpayManager.createDutchUnit(spentTo: "somewhere", spentAmount: 100, personDetails: [personDetails], spentDate: Date())
        
        gathering.dutchUnits.update(with: dutchUnit)
        
        XCTAssertEqual(gathering.dutchUnits.first!.placeName, dutchUnit.placeName)
    }
    
    
    // DutchUnit 생성 완료 후 -> 인원 추가, 장소명 변경
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
    

    // DutchUnit 2명으로 생성 후 -> 1명으로 변경, spentAmount 는 동일 (불가능한 경우)
//    func test_updateDutchUnit2_removePerson() {
//        let gathering = dutchpayManager.createGathering(title: "developers")!
//
//        let person1 = dutchpayManager.createPerson(name: "original Person")
//        let person2 = dutchpayManager.createPerson(name: "added Person")
//
//        let personDetail1 = dutchpayManager.createPersonDetail(person: person1, isAttended: true, spentAmount: 300)
//        let personDetail2 = dutchpayManager.createPersonDetail(person: person2, isAttended: true, spentAmount: 200)
//
//
//        let originalDutchUnit = dutchpayManager.createDutchUnit(spentTo: "somewhereBefore", spentAmount: 500, personDetails: [personDetail1, personDetail2], spentDate: Date())
//
//        gathering.dutchUnits.update(with: originalDutchUnit)
//
//        let updatedDutchUnit = dutchpayManager.createDutchUnit(spentTo: "somewhereAfter", spentAmount: 500, personDetails: [personDetail1], spentDate: Date())
//
//
//        dutchpayManager.updateDutchUnit(target: originalDutchUnit, with: updatedDutchUnit)
//
//
//        XCTAssertEqual(gathering.dutchUnits.count, 1)
//        XCTAssertEqual(gathering.dutchUnits.first!.placeName, "somewhereAfter")
//        XCTAssertEqual(gathering.dutchUnits.first!.personDetails.count, 1)
//        XCTAssertEqual(gathering.totalCost, 500)
//
//        XCTAssertFalse(gathering.dutchUnits.first!.isAmountEqual)
//    }
    
    // DutchUnit 제거
    func test_deleteDutchUnit() {
        let gathering = dutchpayManager.createGathering(title: "developers")!
        
        let person1 = dutchpayManager.createPerson(name: "original Person")
        let personDetail1 = dutchpayManager.createPersonDetail(person: person1, isAttended: true, spentAmount: 100)
        
        
        let dutchUnit1 = dutchpayManager.createDutchUnit(spentTo: "somewhere", spentAmount: 100, personDetails: [personDetail1], spentDate: Date())
        
        let dutchUnit2 = dutchpayManager.createDutchUnit(spentTo: "somewhere", spentAmount: 100, personDetails: [personDetail1], spentDate: Date())
        
        // add dutchUnit to gathering

        dutchpayManager.addDutchUnit(of: dutchUnit1, to: gathering)
        dutchpayManager.addDutchUnit(of: dutchUnit2, to: gathering)
        XCTAssertEqual(gathering.totalCost, 200)
        
        gathering.dutchUnits.remove(dutchUnit1)
        XCTAssertEqual(gathering.totalCost, 100)
        XCTAssertEqual(gathering.dutchUnits.count, 1)
        
        gathering.dutchUnits.remove(dutchUnit2)
        XCTAssertEqual(gathering.totalCost, 0)
        XCTAssertEqual(gathering.dutchUnits.count, 0)
    }
}

extension DutchpayManagerTest {
    
    func test_gathering_updatePeople() {
        let gathering = dutchpayManager.createGathering(title: "developers")!
        
        let person1 = dutchpayManager.createPerson(name: "person1")
        let person2 = dutchpayManager.createPerson(name: "person2")
        let person3 = dutchpayManager.createPerson(name: "person3")

        let personDetail1 = dutchpayManager.createPersonDetail(person: person1, isAttended: true, spentAmount: 100)
        let personDetail2 = dutchpayManager.createPersonDetail(person: person2, isAttended: true, spentAmount: 0)
        
        
        let originalMemberDetails = [personDetail1, personDetail2]
        
        
        let originalDutchUnit = dutchpayManager.createDutchUnit(spentTo: "somewhere", spentAmount: 100, personDetails: originalMemberDetails, spentDate: Date())
        
        
        dutchpayManager.addDutchUnit(of: originalDutchUnit, to: gathering)
        
        XCTAssertEqual(gathering.people.count, 2)
        XCTAssertEqual(gathering.dutchUnits.first!.personDetails.count, 2)
        
        // remove person2 & add person3
        let updatedPeople = [person1, person3]
        
        dutchpayManager.updatePeople(updatedPeople: updatedPeople, currentGathering: gathering)
        
        XCTAssertEqual(gathering.people.filter { $0.name == "person1"}.first!.name, "person1")
        XCTAssertEqual(gathering.people.filter { $0.name == "person3"}.first!.name, "person3")
        XCTAssertEqual(gathering.people.count, 2)
        
        XCTAssertNil(gathering.people.filter { $0.name == "person2"}.first)

        

        XCTAssertNotNil(gathering.dutchUnits.first!.personDetails.filter {$0.person!.name == "person1"})
        XCTAssertNotNil(gathering.dutchUnits.first!.personDetails.filter {$0.person!.name == "person3"})
        XCTAssertNil(gathering.dutchUnits.first!.personDetails.filter {$0.person!.name == "person2"}.first)
    }
    
    // MARK: - People Ordering
//    지금 만들기가 조금 애매함.. 상황이 구체적이지 않기 때문에..
    func test_gathering_makingPeopleInOrder() {
        let person1 = dutchpayManager.createPerson(name: "person1")
        let person2 = dutchpayManager.createPerson(name: "person2")
        let person3 = dutchpayManager.createPerson(name: "person3")
        
        
    }
    
    // 음... Person 이 Gathering 의 People 에 속해있는 상태이면 people 이 변할 때마다 DutchUnit 내에 있는 PersonDetails 도 함께 변할 수 있지 않을까??

    func test_gathering_renamePeople() {
        
    }

}











extension DutchpayManagerTest {
    // Not necessary ..
    
    // DutchUnit 생성 후, ParticipantsController 에서 people 추가 (DutchUnit 들도 추가로 수정)
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


        dutchpayManager.addPeople(addedPeople: [person3], currentGathering: gathering)

        XCTAssertEqual(gathering.dutchUnits.first!.personDetails.count, 3)

        XCTAssertEqual(gathering.people.count, 3)
    }
    
    func test_gathering_removePeople() {
        let gathering = dutchpayManager.createGathering(title: "developers")!

        let person1 = dutchpayManager.createPerson(name: "person1")
        let person2 = dutchpayManager.createPerson(name: "person2")



        let personDetail1 = dutchpayManager.createPersonDetail(person: person1, isAttended: true, spentAmount: 100)
        let personDetail2 = dutchpayManager.createPersonDetail(person: person2, isAttended: true, spentAmount: 0)


        let originalMemberDetails = [personDetail1, personDetail2]

        let originalDutchUnit = dutchpayManager.createDutchUnit(spentTo: "somewhere", spentAmount: 100, personDetails: originalMemberDetails, spentDate: Date())

        dutchpayManager.addDutchUnit(of: originalDutchUnit, to: gathering)
        XCTAssertEqual(gathering.people.count, 2)
        XCTAssertEqual(gathering.dutchUnits.first!.personDetails.count, 2)

        dutchpayManager.removePeople(from: gathering, removedPeople: [person1])

        XCTAssertEqual(gathering.people.count, 1)
        XCTAssertEqual(gathering.dutchUnits.first!.personDetails.count, 1)
    }
    
    func test_swapPeopleOrder() {
        let person1 = dutchpayManager.createPerson(name: "person1", givenIndex: 0)
        let person2 = dutchpayManager.createPerson(name: "person2", givenIndex: 1)
        
        dutchpayManager.swapPersonOrder(of: person1, with: person2)
        
        XCTAssertEqual(person1.order, 1)
        XCTAssertEqual(person2.order, 0)
    }
}


extension DutchpayManagerTest {
    
    func test_result_firstOverall() {
        
        let person1 = dutchpayManager.createPerson(name: "person1", givenIndex: 0)
        let person2 = dutchpayManager.createPerson(name: "person1", givenIndex: 1)
        let person3 = dutchpayManager.createPerson(name: "person1", givenIndex: 2)
        
        let personDetail11 = dutchpayManager.createPersonDetail(person: person1, isAttended: true, spentAmount: 150)
        let personDetail21 = dutchpayManager.createPersonDetail(person: person2, isAttended: true, spentAmount: 0)
        let personDetail31 = dutchpayManager.createPersonDetail(person: person3, isAttended: true, spentAmount: 0)
        
        let personDetail12 = dutchpayManager.createPersonDetail(person: person1, isAttended: true, spentAmount: 0)
        let personDetail22 = dutchpayManager.createPersonDetail(person: person2, isAttended: false, spentAmount: 0)
        let personDetail32 = dutchpayManager.createPersonDetail(person: person3, isAttended: true, spentAmount: 900)
        
        let dutchUnit1 = dutchpayManager.createDutchUnit(spentTo: "some1", spentAmount: 150, personDetails: [personDetail11, personDetail21, personDetail31])

        let dutchUnit2 = dutchpayManager.createDutchUnit(spentTo: "some2", spentAmount: 900, personDetails: [personDetail12, personDetail22, personDetail32])
        
        let gathering = dutchpayManager.createGathering(title: "gathering")
        
        [dutchUnit1, dutchUnit2].forEach { dutchpayManager.addDutchUnit(of: $0, to: gathering!)}

        XCTAssertEqual(dutchUnit1.personDetails.count, 3)
        
        dutchpayManager.getUnitResult(using: dutchUnit1)
        dutchpayManager.getUnitResult(using: dutchUnit2)
        XCTAssertEqual(gathering!.people.count, 3)
        
        dutchpayManager.getFirstOverallResult(using: gathering!) // [ -350, -50, 400]
        // [0 0 -350 ]
        // [0 -50 0  ]
        // [350 50 0 ]
    }
    
    func test_result_secondOverall_Step1() {
//        typealias indexedDetail = ( Double ) // dictionary 가 나을 것 같아.
//        let someArr = [-123.0, -523.5, 123.0 + 523.5]
//        let someArr = createArray()
//        var minuses: [Int: Int] = [:]
//        var pluses: [Int: Int] = [:]
//        var zeros: [Int] = []
//        for (idx, val) in someArr.enumerated() {
//            if val > 0 {
//                pluses[idx] = val
//            } else if val < 0 {
//                minuses[idx] = val
//            } else {
//                zeros.append(val)
//            }
//        }
//        print("pluses: \(pluses)")
//        print("minuses: \(minuses)")
//
//        XCTAssertEqual(someArr.count, pluses.count + minuses.count + zeros.count)
        
        let test1Arr = [-3, -2, 0, 1, 1, 3]
        let test1ArrResult = matchSameValues1On1(firstResult: test1Arr, msg: "test1")!.matchedPeople // [matchedPeople: [0:5]
        XCTAssertEqual(test1ArrResult.count, 1)

        let test2Arr = [-3, -2, -1, 1, 2, 3]
        let test2ArrResult = matchSameValues1On1(firstResult: test2Arr, msg: "test2")!.matchedPeople // [matchedPeople: [2:3, 0:5, 1:4]
        XCTAssertEqual(test2ArrResult.count, 3)

        
        let test3Arr = [-3, -2, 0, 1, 4, 7]
        let test3ArrResult = matchSameValues1On1(firstResult: test3Arr, msg: "test3") // // [matchedPeople: [:]
        XCTAssertNil(test3ArrResult) // validity fail
        
        
    }
}


// MARK: - Test Helpers
extension DutchpayManagerTest {
    func createArray(of num: Int = 6, positiveRange: Int = 10) -> [Int]{
        
        var resultArr = [Int]()
        var sum = 0
        for _ in 0 ..< num - 1 {
            let randomNum = Int.random(in: -positiveRange ... positiveRange)
            resultArr.append(randomNum)
            sum += randomNum
        }
        resultArr.append(-sum)
        print("result of returned arr: \(resultArr)")
        return resultArr
    }
    
    
//    func matchSameValues(firstResult: [Int], msg: String = "") -> [Int: Int]? {
    func matchSameValues1On1(firstResult: [Int], msg: String = "") -> (remainedPeople: [Int: [Int]], matchedPeople: [Int: Int], isFinished: Bool)? {
        // validity test
        let sum = firstResult.reduce(0) { partialResult, value in
            return partialResult + value
        }
        if sum != 0 { return nil }
        
        
        var allDic = [Int: [Int]]()
        var matchedPeople = [Int:Int]()
        print(msg)
        for (pIdx, spentAmount) in firstResult.enumerated() {
            if spentAmount == 0 { continue } // filterOut 0
            // if spentAmount has matched pair already -> create matchedPeople element, remove from allDic
            if let validPairIdx = allDic[-spentAmount]?.first {
                matchedPeople[validPairIdx] = pIdx
                
                if allDic[-spentAmount]!.count == 1 {
                    allDic[-spentAmount] = nil
                } else {
                    allDic[-spentAmount]!.removeFirst()
                }

                // has no matched pair
            } else {
                // for duplicate spentAmount value -> append Person Index
                if allDic[spentAmount] != nil && allDic[spentAmount]!.count != 0 {
                    allDic[spentAmount]!.append(pIdx)
                    // for first (or unique value) -> create one
                } else {
                    allDic[spentAmount] = [pIdx]
                }
            }
        }
        
        print("allDic: \(allDic)")
        print("matchedPeople: \(matchedPeople)")
        
        // if allDic is empty, all process is finished
        let isFinished = allDic.count == 0
        
//        return matchedPeople
        return (allDic, matchedPeople, isFinished)
    }
    
    func matchSameValues1OnN(allDic: [Int: [Int]]) -> (matchedPeople: [Int: [Int]], isFinished: Bool) {
        
        
        return ([:], false)
    }
    
    
    
    
    
//    func matchSameValues(pluses: [Int: Int], minuses: [Int: Int]) -> [Int: Int] {
//        // 중복인 경우에는 ? 이거.. 하나씩 없애야겠는데?
//
//        var matchedIndexes: [Int:Int] = [:]
//
//        var plusSet = Set<Int>()
//        var minusSet = Set<Int>()
//
//        var duplicates: [Int: Int] = [:] // [n:k] : n 이 k 번
//
//        for (_, val) in pluses {
//            if plusSet.contains(val) {
//                // duplicates 에 등록이 안되었을 시 2 로 초기화
//                if duplicates[val] == nil {
//                    duplicates[val] = 2
//                    // duplicates 에 이미 있는 경우 값 + 1
//                } else {
//                    duplicates[val] = duplicates[val]! + 1
//                }
//            } else {
//                plusSet.insert(val)
//            }
//        }
//
//
//        for (_, val) in minuses {
//            if minusSet.contains(val) {
//                if duplicates[val] == nil {
//                    duplicates[val] = 2
//                } else {
//                    duplicates[val] = duplicates[val]! + 1
//                }
//            } else {
//                minusSet.insert(val)
//            }
//        }
//
//
//        let sameValues = plusSet.intersection(minusSet) // set
//        // start matching
//
//        for value in sameValues {
//
//        }
//
//
//        return [:]
//    }
    
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



