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

class DutchpayUnitTest: XCTestCase {
    
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
        let gathering = dutchpayManager.createGathering(title: "developers")
        
        gathering.title = "jiwon"
        
        dutchpayManager.update()
        
        
        let updated = dutchpayManager.fetchGathering(.title("jiwon"))!
        
        XCTAssertEqual("jiwon", updated.title)
    }
    
    func test_delete_gathering() {
        let gatheringA = dutchpayManager.createGathering(title: "A")
        let gatheringB = dutchpayManager.createGathering(title: "B")
        let gatheringC = dutchpayManager.createGathering(title: "C")
        
        dutchpayManager.deleteGathering(gathering: gatheringB) {
            
        }
        
        
        let gatherings = dutchpayManager.fetchGatherings()
        
        XCTAssertEqual(gatherings.count, 2)
        XCTAssertTrue(gatherings.contains(gatheringA))
        XCTAssertTrue(gatherings.contains(gatheringC))
    }
}


// Advanced features ( DutchUnit )
extension DutchpayUnitTest {
    // DutchUnit 하나 생성
//    func test_addDutchUnit() {
//        let gathering = dutchpayManager.createGathering(title: "developers")
//
//        let person = dutchpayManager.createPerson(name: "new Person", currentGathering: gathering)
//        let personDetails = dutchpayManager.createPersonDetail(person: person, isAttended: true, spentAmount: 100)
//
//        let dutchUnit = dutchpayManager.createDutchUnit(spentTo: "somewhere", spentAmount: 100, personDetails: [personDetails], spentDate: Date())
//
//        gathering.dutchUnits.update(with: dutchUnit)
//
//        XCTAssertEqual(gathering.dutchUnits.first!.placeName, dutchUnit.placeName)
//    }
    
    
    // DutchUnit 생성 완료 후 -> 인원 추가, 장소명 변경
//    func test_updateDutchUnit1_addPerson() {
//        let gathering = dutchpayManager.createGathering(title: "developers")
//
//        let originalPerson = dutchpayManager.createPerson(name: "original Person", currentGathering: gathering)
//        let originalPersonDetail = dutchpayManager.createPersonDetail(person: originalPerson, isAttended: true, spentAmount: 300)
//
//        let originalDutchUnit = dutchpayManager.createDutchUnit(spentTo: "somewhere", spentAmount: 300, personDetails: [originalPersonDetail], spentDate: Date())
//
//        // add dutchUnit to gathering
//        gathering.dutchUnits.update(with: originalDutchUnit)
//
//        let newPerson = dutchpayManager.createPerson(name: "added Person", currentGathering: gathering)
//        let additionalPersonDetail = dutchpayManager.createPersonDetail(person: newPerson, isAttended: true, spentAmount: 0)
//
//        //        let updatedDutchUnit = dutchpayManager.createDutchUnit(spentTo: "updatedPlace", spentAmount: 300, personDetails: [originalPersonDetail, additionalPersonDetail], spentDate: Date())
//
//        let updatedPlace = "updatedPlace"
//
//        // update dutchUnit
//        //        dutchpayManager.updateDutchUnit(target: originalDutchUnit, with: updatedDutchUnit)
//        dutchpayManager.updateDutchUnit(target: originalDutchUnit,
//                                        spentTo: updatedPlace,
//                                        spentAmount: 300,
//                                        personDetails: [originalPersonDetail, additionalPersonDetail],
//                                        spentDate: Date())
//
//
//        XCTAssertEqual(gathering.dutchUnits.count, 1)
//        // chck if gathering has the same dutchUnit
//        XCTAssertEqual(gathering.dutchUnits.first!.placeName, updatedPlace)
//
//        XCTAssertEqual(gathering.dutchUnits.first!.personDetails.count, 2)
//        // get totalCost from DutchUnits
//        XCTAssertEqual(gathering.totalCost, 300)
//    }
    
    
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
//    func test_deleteDutchUnit() {
//        let gathering = dutchpayManager.createGathering(title: "developers")
//
//        let person1 = dutchpayManager.createPerson(name: "original Person", currentGathering: gathering)
//        let personDetail1 = dutchpayManager.createPersonDetail(person: person1, isAttended: true, spentAmount: 100)
//
//
//        let dutchUnit1 = dutchpayManager.createDutchUnit(spentTo: "somewhere", spentAmount: 100, personDetails: [personDetail1], spentDate: Date())
//
//        let dutchUnit2 = dutchpayManager.createDutchUnit(spentTo: "somewhere", spentAmount: 100, personDetails: [personDetail1], spentDate: Date())
//
//        // add dutchUnit to gathering
//
//        dutchpayManager.addDutchUnit(of: dutchUnit1, to: gathering)
//        dutchpayManager.addDutchUnit(of: dutchUnit2, to: gathering)
//        XCTAssertEqual(gathering.totalCost, 200)
//
//        gathering.dutchUnits.remove(dutchUnit1)
//        XCTAssertEqual(gathering.totalCost, 100)
//        XCTAssertEqual(gathering.dutchUnits.count, 1)
//
//        gathering.dutchUnits.remove(dutchUnit2)
//        XCTAssertEqual(gathering.totalCost, 0)
//        XCTAssertEqual(gathering.dutchUnits.count, 0)
//    }
}

extension DutchpayUnitTest {
    
//    func test_gathering_updatePeople() {
//        let gathering = dutchpayManager.createGathering(title: "developers")
//
//        let person1 = dutchpayManager.createPerson(name: "person1", currentGathering: gathering)
//        let person2 = dutchpayManager.createPerson(name: "person2", currentGathering: gathering)
//        let person3 = dutchpayManager.createPerson(name: "person3", currentGathering: gathering)
//
//        let personDetail1 = dutchpayManager.createPersonDetail(person: person1, isAttended: true, spentAmount: 100)
//        let personDetail2 = dutchpayManager.createPersonDetail(person: person2, isAttended: true, spentAmount: 0)
//
//
//        let originalMemberDetails = [personDetail1, personDetail2]
//
//
//        let originalDutchUnit = dutchpayManager.createDutchUnit(spentTo: "somewhere", spentAmount: 100, personDetails: originalMemberDetails, spentDate: Date())
//
//
//        dutchpayManager.addDutchUnit(of: originalDutchUnit, to: gathering)
//
//        XCTAssertEqual(gathering.people.count, 2)
//        XCTAssertEqual(gathering.dutchUnits.first!.personDetails.count, 2)
//
//        // remove person2 & add person3
//        let updatedPeople = [person1, person3]
//
//        dutchpayManager.updateAllDetailsWithNewPeople(updatedPeople: updatedPeople, currentGathering: gathering)
//
//        XCTAssertEqual(gathering.people.filter { $0.name == "person1"}.first!.name, "person1")
//        XCTAssertEqual(gathering.people.filter { $0.name == "person3"}.first!.name, "person3")
//        XCTAssertEqual(gathering.people.count, 2)
//
//        XCTAssertNil(gathering.people.filter { $0.name == "person2"}.first)
//
//
//
//        XCTAssertNotNil(gathering.dutchUnits.first!.personDetails.filter {$0.person!.name == "person1"})
//        XCTAssertNotNil(gathering.dutchUnits.first!.personDetails.filter {$0.person!.name == "person3"})
//        XCTAssertNil(gathering.dutchUnits.first!.personDetails.filter {$0.person!.name == "person2"}.first)
//    }
    
    // MARK: - People Ordering
    //    지금 만들기가 조금 애매함.. 상황이 구체적이지 않기 때문에..
    func test_gathering_makingPeopleInOrder() {
        //        let person1 = dutchpayManager.createPerson(name: "person1")
        //        let person2 = dutchpayManager.createPerson(name: "person2")
        //        let person3 = dutchpayManager.createPerson(name: "person3")
        
        
    }
    
    // 음... Person 이 Gathering 의 People 에 속해있는 상태이면 people 이 변할 때마다 DutchUnit 내에 있는 PersonDetails 도 함께 변할 수 있지 않을까??
    
    func test_gathering_renamePeople() {
        
    }
}











extension DutchpayUnitTest {
    // Not necessary ..
    
    // DutchUnit 생성 후, ParticipantsController 에서 people 추가 (DutchUnit 들도 추가로 수정)
//    func test_gathering_addPerson() {
//        let gathering = dutchpayManager.createGathering(title: "developers")
//
//        let person1 = dutchpayManager.createPerson(name: "person1", currentGathering: gathering)
//        let person2 = dutchpayManager.createPerson(name: "person2", currentGathering: gathering)
//        let person3 = dutchpayManager.createPerson(name: "person3", currentGathering: gathering)
//
//
//        let personDetail1 = dutchpayManager.createPersonDetail(person: person1, isAttended: true, spentAmount: 100)
//        let personDetail2 = dutchpayManager.createPersonDetail(person: person2, isAttended: true, spentAmount: 0)
//
//
//        let originalMemberDetails = [personDetail1, personDetail2]
//
//        let originalDutchUnit = dutchpayManager.createDutchUnit(spentTo: "somewhere", spentAmount: 100, personDetails: originalMemberDetails, spentDate: Date())
//
//        dutchpayManager.addDutchUnit(of: originalDutchUnit, to: gathering)
//
//        XCTAssertEqual(gathering.dutchUnits.first!.personDetails.count, 2)
//
//
//        dutchpayManager.addPeople(addedPeople: [person3], currentGathering: gathering)
//
//        XCTAssertEqual(gathering.dutchUnits.first!.personDetails.count, 3)
//
//        XCTAssertEqual(gathering.people.count, 3)
//    }
    
//    func test_gathering_removePeople() {
//        let gathering = dutchpayManager.createGathering(title: "developers")
//
//        let person1 = dutchpayManager.createPerson(name: "person1", currentGathering: gathering)
//        let person2 = dutchpayManager.createPerson(name: "person2", currentGathering: gathering)
//
//
//
//        let personDetail1 = dutchpayManager.createPersonDetail(person: person1, isAttended: true, spentAmount: 100)
//        let personDetail2 = dutchpayManager.createPersonDetail(person: person2, isAttended: true, spentAmount: 0)
//
//
//        let originalMemberDetails = [personDetail1, personDetail2]
//
//        let originalDutchUnit = dutchpayManager.createDutchUnit(spentTo: "somewhere", spentAmount: 100, personDetails: originalMemberDetails, spentDate: Date())
//
//        dutchpayManager.addDutchUnit(of: originalDutchUnit, to: gathering)
//        XCTAssertEqual(gathering.people.count, 2)
//        XCTAssertEqual(gathering.dutchUnits.first!.personDetails.count, 2)
//
//        dutchpayManager.removePeople(from: gathering, removedPeople: [person1])
//
//        XCTAssertEqual(gathering.people.count, 1)
//        XCTAssertEqual(gathering.dutchUnits.first!.personDetails.count, 1)
//    }
    
//    func test_swapPeopleOrder() {
//        let gathering = dutchpayManager.createGathering(title: "dummy")
//        let person1 = dutchpayManager.createPerson(name: "person1", currentGathering: gathering)
//        let person2 = dutchpayManager.createPerson(name: "person2", currentGathering: gathering)
//
//        dutchpayManager.swapPersonOrder(of: person1, with: person2)
//
//        XCTAssertEqual(person1.order, 1)
//        XCTAssertEqual(person2.order, 0)
//    }
}


extension DutchpayUnitTest {
    
//    func test_result_firstOverall() {
//
//        let gathering = dutchpayManager.createGathering(title: "gathering")
//
//        //        let person1 = dutchpayManager.createPerson(name: "person1", givenIndex: 0)
//        let person1 = dutchpayManager.createPerson(name: "person1", currentGathering: gathering)
//        let person2 = dutchpayManager.createPerson(name: "person2", currentGathering: gathering)
//        let person3 = dutchpayManager.createPerson(name: "person3", currentGathering: gathering)
//
//        let personDetail11 = dutchpayManager.createPersonDetail(person: person1, isAttended: true, spentAmount: 150)
//        let personDetail21 = dutchpayManager.createPersonDetail(person: person2, isAttended: true, spentAmount: 0)
//        let personDetail31 = dutchpayManager.createPersonDetail(person: person3, isAttended: true, spentAmount: 0)
//
//        let personDetail12 = dutchpayManager.createPersonDetail(person: person1, isAttended: true, spentAmount: 0)
//        let personDetail22 = dutchpayManager.createPersonDetail(person: person2, isAttended: false, spentAmount: 0)
//        let personDetail32 = dutchpayManager.createPersonDetail(person: person3, isAttended: true, spentAmount: 900)
//
//        let dutchUnit1 = dutchpayManager.createDutchUnit(spentTo: "some1", spentAmount: 150, personDetails: [personDetail11, personDetail21, personDetail31])
//
//        let dutchUnit2 = dutchpayManager.createDutchUnit(spentTo: "some2", spentAmount: 900, personDetails: [personDetail12, personDetail22, personDetail32])
//
//
//
//        [dutchUnit1, dutchUnit2].forEach { dutchpayManager.addDutchUnit(of: $0, to: gathering)}
//
//        XCTAssertEqual(dutchUnit1.personDetails.count, 3)
//
//        dutchpayManager.getRelativeTobePaidAmount(from: dutchUnit1)
//        dutchpayManager.getRelativeTobePaidAmount(from: dutchUnit2)
//        XCTAssertEqual(gathering.people.count, 3)
//
//        dutchpayManager.getRelativeTobePaidAmountForEachPerson(from: gathering) // [ -350, -50, 400]
//
//
//
//        // [0 0 -350 ]
//        // [0 -50 0  ]
//        // [350 50 0 ]
//
//        let displayedData = dutchpayManager.createOverallInfo(gathering: gathering)
//        XCTAssertEqual(displayedData.count, 3)
//
//        let payData = dutchpayManager.createPersonPayInfos(gathering: gathering)
//        XCTAssertEqual(payData.count, 3)
//
//    }
    
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
    
    //    func test_createCombination() {
    //        let allDic = [100: [1], 200: [2,3], 50: [4], 25: [5], 10:[6]]
    //        createCombination(using: allDic, numOfElementsToPick: 1)
    //        createCombination(using: allDic, numOfElementsToPick: 2)
    //        createCombination(using: allDic, numOfElementsToPick: 3)
    //        createCombination(using: allDic, numOfElementsToPick: 4)
    //
    //        XCTAssertEqual(0, 0)
    //    }
    
    // need to combine 2 functions below with the right above one
    func createCorrectSequenceOfArray(numOfElementsToPick: Int, numOfAllElements: Int)  {
        let numOfElementsToPick = 5
        let numOfAllElements = 10
        var inputIndexes = Array(0 ..< numOfElementsToPick)
        var indexesContainer = [inputIndexes]
        
        
        while (inputIndexes.first! != 5) {
            print("inputIndexes: \(inputIndexes)")
            
            inputIndexes = returnNextIndexes(indexes: inputIndexes, numOfAllElements: numOfAllElements)
            indexesContainer.append(inputIndexes)
        }
        print("indexesContainer: \(indexesContainer)")
        print("hello")
        
    }
    
    
}


// MARK: - Test Helpers
extension DutchpayUnitTest {
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

extension DutchpayUnitTest {
    
    
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




extension DutchpayUnitTest {
    func createAllCombinations(using allDic: [Int: [Int]], numOfElementsToPick: Int) -> Set<Int>{
        // 중복된 elements 없다고 가정, Result 에는 Set 으로 (중복된 결과 넣지 않음) 우선 넣기.
        var allNums = Set<Int>()
        var combinationSet = Set<Int>() // result
        
        for (key, _) in allDic {
            if allNums.contains(key) == false {
                allNums.insert(key)
            }
        }
        
        if numOfElementsToPick == 1 {
            return allNums
        }
        
        
        let allNumsArr = Array(allNums) // make elements into array form.
        print("\nallNumsArr: \(allNumsArr)\n\n")
        
        let numOfAllElements = allNumsArr.count // 총 n 개
        let firstIndexOfLastCombination = numOfAllElements - numOfElementsToPick
        // 사람에 대한 Index 가 아님.
        var inputIndexes = Array(0 ..< numOfElementsToPick) // 0, 1, 2  Set 를 구하는 데 사용된 Elements 의 Indexes.
        
        var firstlyUsedIndexOfLastCombination = 0
        
        let resultCombination = sum(of: allNumsArr, withIndexesOf: inputIndexes)
        combinationSet.insert(resultCombination)
        
        print("inputIndexes: \(inputIndexes), resultCombination: \(resultCombination)")
        
        // 초기값 조건들을 어떻게 주지...??
        while (firstIndexOfLastCombination != firstlyUsedIndexOfLastCombination ) {
            
            // update Indexes.
            inputIndexes = returnNextIndexes(indexes: inputIndexes, numOfAllElements: numOfAllElements)
            
            let resultCombination = sum(of: inputIndexes, withIndexesOf: allNumsArr)
            print("inputIndexes: \(inputIndexes), resultCombination: \(resultCombination)")
            combinationSet.insert(resultCombination)
            
            firstlyUsedIndexOfLastCombination = inputIndexes.first!
        }
        
        print("\n\nprinting combinationSet: \n")
        for element in combinationSet {
            print(element)
        }
        
        return combinationSet
    }
    
    // MARK: - Newly added.
    func createAllCombinationsInPersonIdx(using allDic: [Int: [Int]], numOfElementsToPick: Int) -> Set<Int>{
        // 중복된 elements 없다고 가정, Result 에는 Set 으로 (중복된 결과 넣지 않음) 우선 넣기.
        var allNums = Set<Int>()
        var combinationSet = Set<Int>() // result
        
        for (key, _) in allDic {
            if allNums.contains(key) == false {
                allNums.insert(key)
            }
        }
        
        if numOfElementsToPick == 1 {
            return allNums
        }
        
        
        let allNumsArr = Array(allNums) // make elements into array form.
        print("\nallNumsArr: \(allNumsArr)\n\n")
        
        let numOfAllElements = allNumsArr.count // 총 n 개
        let firstIndexOfLastCombination = numOfAllElements - numOfElementsToPick
        // 사람에 대한 Index 가 아님.
        var inputIndexes = Array(0 ..< numOfElementsToPick) // 0, 1, 2  Set 를 구하는 데 사용된 Elements 의 Indexes.
        // 간단히, personIndexes 와 inputIndexes 를 관계지어주면 안되나 ? 음... 그러면 사용하는 함수 (sum) 가 달라져야함. ???
        
        //        var personIndexes = allDic.map { $0.key }
        var personIndexes = [Int]()
        
        for (numIdx, allnum) in allNumsArr.enumerated() {
            if let idx = allDic[allnum] {
                personIndexes.append(idx[0])
            }
        }
        
        print("personIndexes: \(personIndexes)")
        
        var firstlyUsedIndexOfLastCombination = 0
        
        // 순서가 여기서 고려되었나 ?
        let resultCombination = sum(of: allNumsArr, withIndexesOf: inputIndexes )
        
        combinationSet.insert(resultCombination)
        
        print("inputIndexes: \(inputIndexes), resultCombination: \(resultCombination)")
        for (idx, value) in inputIndexes.enumerated() {
            print("personIndexes: \(personIndexes[value])")
        }
        
        
        // 초기값 조건들을 어떻게 주지...??
        while (firstIndexOfLastCombination != firstlyUsedIndexOfLastCombination ) {
            
            // update Indexes.
            inputIndexes = returnNextIndexes(indexes: inputIndexes, numOfAllElements: numOfAllElements)
            
            let resultCombination = sum(of: allNumsArr, withIndexesOf: inputIndexes)
            print("inputIndexes: \(inputIndexes), resultCombination: \(resultCombination)")
            for (idx, value) in inputIndexes.enumerated() {
                print("personIndexes: \(personIndexes[value])")
            }
            combinationSet.insert(resultCombination)
            
            firstlyUsedIndexOfLastCombination = inputIndexes.first!
        }
        
        print("\n\nprinting combinationSet: \n")
        for element in combinationSet {
            print(element)
        }
        
        return combinationSet
    }
    
    func sum(of targetArr: [Int], withIndexesOf indexes: [Int]) -> Int {
        var sum = 0
        for idx in 0 ..< indexes.count {
            sum += targetArr[indexes[idx]]
        }
        return sum
    }
    
    
    func returnNextIndexes(indexes: [Int], numOfAllElements: Int) -> [Int] {
        var backwardIndex = 1
        var ans = indexes
        let numOfElementsToPick = indexes.count
        while (backwardIndex <= numOfElementsToPick) {
            if indexes[indexes.count - backwardIndex] == numOfAllElements - backwardIndex {
                // 전 인덱스 + 1
                // 다음거 체크 !
                backwardIndex += 1
                
            } else {
                ans = indexes
                
                ans[indexes.count - backwardIndex] = indexes[indexes.count - backwardIndex] + 1
                
                var forwardIndex = 1
                
                while (indexes.count - backwardIndex + forwardIndex < numOfElementsToPick) {
                    ans[indexes.count - backwardIndex + forwardIndex] = ans[indexes.count - backwardIndex + forwardIndex - 1] + 1
                    forwardIndex += 1
                }
                return ans
            }
        }
        return ans
    }
    
    func testCode() {
        let allDic = [100: [0], 200: [1], -300: [2], 50: [3], -50: [4]]
        let numOfCombi = createAllCombinations(using: allDic, numOfElementsToPick: 2)
        
        
        XCTAssertNotEqual(numOfCombi.count, 1)
    }
    
    func test_createCombinationOfBothSigns() {
        let allDic = [100: [0], 200: [1], -300: [2], 50: [3], -50: [4]]
        
        // [100: [0], 200: [1], 50: [3]]
        var positiveNums = [Int:[Int]]()
        
        // [-300: [2], -50: [4]]
        var negativeNums = [Int:[Int]]()
        
        for (key, value) in allDic {
            if key >= 0 && positiveNums[key] == nil {
                positiveNums[key] = value
            } else if key < 0 && negativeNums[key] == nil {
                negativeNums[key] = value
            }
        }
        
        //        let positiveCombinations = createAllCombinations(using: positiveNums, numOfElementsToPick: 2)
        //        let negativeCombination = createAllCombinations(using: negativeNums, numOfElementsToPick: 2)
        
        let positiveCombinations = createAllCombinationsInPersonIdx(using: positiveNums, numOfElementsToPick: 2)
        let negativeCombination = createAllCombinationsInPersonIdx(using: negativeNums, numOfElementsToPick: 2)
        
        XCTAssertEqual(positiveCombinations.count, 3)
        print("end of positiveCombination. ")
        XCTAssertEqual(negativeCombination.count, 1)
        
    }
    
    func makePairsUsingArraysOfSameValue(arr1: [Int], arr2: [Int], result: inout [Int: Int]) {
        for (idx, int) in arr1.enumerated() {
            if arr2.count > idx {
                result[int] = arr2[idx]
            } else { break }
        }
        
    }
}

//extension DutchpayUnitTest {
//    func test_fromTheTop() {
//
//
//
//        let personDetails: [PersonTuple] = [("a1", 1), ("a2", 25), ("a3", 7), ("a4", 4), ("a5", 7), ("a6", 5), ("a7", 2), ("a8", 0), ("a9", 17), ("a10", 7), ("a11", 14),
//                                            ("b1", -54), ("b2", -13), ("b3", -2), ("b4", -1), ("b5", -5), ("b6", -7),("b7", -7) ]
//
//        var positiveTuples = [PersonTuple]()
//        var negativeTuples = [PersonTuple]()
//        var resultTuples = [ResultTuple]()
//
//        for tup in personDetails {
//            if tup.spentAmount >= 0 {
//                positiveTuples.append(tup)
//            } else {
//                negativeTuples.append(tup)
//            }
//        }
//
//        // --------------------------------Test----------------------------- //
//        let positiveSum = positiveTuples.map { $0.spentAmount}.reduce(0, +)
//        let negativeSum = negativeTuples.map { $0.spentAmount }.reduce(0, +)
//        XCTAssertEqual(positiveSum, -negativeSum)
//        // ----------------------------------------------------------------- //
//
//        // 0원 인 경우, Result 에 들어갈 필요 없이, 앞으로 연산 시 고려사항에서 제거되어있어야함.
//        let zeroPeople = positiveTuples.filter { $0.spentAmount == 0 }
//        let positiveTupleCountBefore = positiveTuples.count
//        XCTAssertNotEqual(zeroPeople.count, 0)
//
//        positiveTuples = positiveTuples.filter { $0.spentAmount != 0 }
//        XCTAssertEqual(positiveTupleCountBefore - 1, positiveTuples.count)
//
//        // MARK: - Make Dictionary for both signs
//        var positivesDic: [Int: [String]] = [:]
//        var negativesDic: [Int: [String]] = [:]
//
//        for personTuple in positiveTuples {
//            if positivesDic[personTuple.spentAmount] != nil {
//                positivesDic[personTuple.spentAmount]!.append(personTuple.name)
//
//            } else {
//                positivesDic[personTuple.spentAmount] = [personTuple.name]
//            }
//        }
//
//        for  personTuple in negativeTuples {
//            if negativesDic[personTuple.spentAmount] != nil {
//                negativesDic[personTuple.spentAmount]!.append(personTuple.name)
//
//            } else {
//                negativesDic[personTuple.spentAmount] = [personTuple.name]
//            }
//        }
//
//        print("positivesDic: \(positivesDic)")
//        print("negativesDic: \(negativesDic)")
//
//        // MARK: - Match 1 on 1 // Using Dynamic approach may reduce time complexity ..
//    }
//}

extension DutchpayUnitTest {
    
    func test_getNthOrder() {

        let targetName = "Gathering 10"

        if targetName.contains("Gathering ") {

            if let stringIdx = targetName.firstIndex(of: " "), let stringInt = targetName.firstIndexInt(of: " "), stringInt == 9 {

                let lastIdx = targetName.endIndex
                
                let initialIdx = targetName.index(stringIdx, offsetBy: 1)
                let numberPart = targetName[initialIdx ..< lastIdx]
                print("numberPart: \(numberPart)")
                XCTAssertEqual(numberPart, "10")
            }
        }
    }
    
    func test_maxNumber() {
        let maxInt = Int.max //
        let maxDouble = Double.greatestFiniteMagnitude //
        
//        XCTAssertEqual(Double(100), maxDouble)
        XCTAssertNotEqual(Double(maxInt), maxDouble)
        // intDouble: 9.223372036854776e+18
        // maxDouble: 1.7976931348623157e+308
//        XCTAssertEqual failed: ("") is not equal to ("")
    }
}
