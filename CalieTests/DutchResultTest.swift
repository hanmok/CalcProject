//
//  DutchResultTest.swift
//  CalieTests
//
//  Created by Mac mini on 2022/08/15.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import XCTest
import CoreData
@testable import Calie


typealias PersonTuple = (name: String, spentAmount: Int)
typealias ResultTuple = (from: String, to: String, amount: Int)

class DutchResultTest: XCTestCase {
    
    func test_fromTheTop_duplicate() {
        
        //        typealias PersonTuple = (name: String, spentAmount: Int)
        //        typealias ResultTuple = (from: String, to: String, amount: Int)
        
        var personDetails: [PersonTuple] = [
            ("a1", 1), ("a2", 25), ("a3", 7), ("a4", 4),
            ("a5", 7), ("a6", 5), ("a7", 2), ("a8", 0),
            ("a9", 17), ("a10", 7), ("a11", 14),("a12", 7),("a13", 6),("a14", 6),
            
            ("b1", -54), ("b2", -13), ("b3", -2), ("b4", -1),
            ("b5", -5), ("b6", -7),("b7", -7),("b8", -5),
            ("b9", -2),("b10", -10),("b11", -2) ]
        
        personDetails = personDetails.filter { $0.spentAmount != 0 }
        
        var positiveTuples = [PersonTuple]()
        var negativeTuples = [PersonTuple]()
        var resultTuples = [ResultTuple]()
        
        
        
        for tup in personDetails {
            if tup.spentAmount >= 0 {
                positiveTuples.append(tup)
            } else {
                negativeTuples.append(tup)
            }
        }
        
        // --------------------------------Test----------------------------- //
        let positiveSum = positiveTuples.map { $0.spentAmount}.reduce(0, +)
        let negativeSum = negativeTuples.map { $0.spentAmount }.reduce(0, +)
        XCTAssertEqual(positiveSum, -negativeSum)
        // ----------------------------------------------------------------- //
        
        
        // MARK: - Make Dictionary for both signs
        var positivesDic: [Int: [String]] = [:]
        var negativesDic: [Int: [String]] = [:]
        
        for personTuple in positiveTuples {
            if positivesDic[personTuple.spentAmount] != nil {
                positivesDic[personTuple.spentAmount]!.append(personTuple.name)
                
            } else {
                positivesDic[personTuple.spentAmount] = [personTuple.name]
            }
        }
        
        for  personTuple in negativeTuples {
            if negativesDic[personTuple.spentAmount] != nil {
                negativesDic[personTuple.spentAmount]!.append(personTuple.name)
                
            } else {
                negativesDic[personTuple.spentAmount] = [personTuple.name]
            }
        }
        
        print("positivesDic: \(positivesDic)")
        print("negativesDic: \(negativesDic)")
        
        // MARK: - Match 1 on 1 // Using Dynamic approach may reduce time complexity ..
        
        var matchedPeopleName = Set<String>()
        
        for (spentAmount, positivePersonNames) in positivesDic {
            print("flag 1, spentAmount: \(spentAmount)")
            if let validNegativeNames = negativesDic[-1 * spentAmount] {
                // MATCH
                print("flag 2, validNegativeNames: \(validNegativeNames)")
                for (idx, positivePersonName) in positivePersonNames.enumerated() {
                    if idx < validNegativeNames.count {
                        
                        print("flag 3, idx: \(idx), validNegativenames.count: \(validNegativeNames.count)")
                        resultTuples.append((from: validNegativeNames[idx], to: positivePersonName, amount: spentAmount))
                        matchedPeopleName.insert(validNegativeNames[idx])
                        matchedPeopleName.insert(positivePersonName)
                    }
                }
            }
        }
        
        print("resultTuples: \(resultTuples)")
        XCTAssertNotEqual(resultTuples.count, 0)
        
        // Match 1 on 1 후처리 ;; 추후 반드시 수정 필요.
        // create new personDetails
        var newPersonDetails = [PersonTuple]()
        
        for eachPersonInfo in personDetails {
            if matchedPeopleName.contains(eachPersonInfo.name) == false {
                newPersonDetails.append(eachPersonInfo)
            }
        }
        
        positivesDic = [:]
        negativesDic = [:]
        
        positiveTuples = [PersonTuple]()
        negativeTuples = [PersonTuple]()
        
        for tup in newPersonDetails {
            if tup.spentAmount > 0 {
                positiveTuples.append(tup)
            } else if tup.spentAmount < 0 {
                negativeTuples.append(tup)
            }
        }
        
        
        for personTuple in positiveTuples {
            if positivesDic[personTuple.spentAmount] != nil {
                positivesDic[personTuple.spentAmount]!.append(personTuple.name)
                
            } else {
                positivesDic[personTuple.spentAmount] = [personTuple.name]
            }
        }
        
        for  personTuple in negativeTuples {
            if negativesDic[personTuple.spentAmount] != nil {
                negativesDic[personTuple.spentAmount]!.append(personTuple.name)
                
            } else {
                negativesDic[personTuple.spentAmount] = [personTuple.name]
            }
        }
        
        print("newPersonDetails: \(newPersonDetails)\n")
        print("newPositiveDic: \(positivesDic)")
        print("newNegativeDic: \(negativesDic)")
        
        // MARK: - 1: n
        print("Stage 2, Matching 1: n")
        
        var negativeCandidates = [Int]()
        var positiveCandidates = [Int]()
        
        for (amt, _) in negativesDic {
            negativeCandidates.append(-amt)
        }
        
        for (amt, _) in positivesDic {
            positiveCandidates.append(amt)
        }
       
        negativeCandidates.sort(by: >)  // [54, ... 2, 1, 1]
        positiveCandidates.sort(by: <) // [1,2,3, ... ]
       
        for positiveCandidate in positiveCandidates {
            let target = positiveCandidate
            print("flag 0, positive target: \(target)")
            print("negativeCandidates: \(negativeCandidates)")
            let negativeResultIndexes = combinationSum(candidates: negativeCandidates, target: target)
            print("flag 0, negativeResult: \(negativeResultIndexes)")
//            let negativeResults = convert // Array of Values
            let negativesResults = convertResult2(source: negativeCandidates, indexes: negativeResultIndexes)
            if negativeResultIndexes != [] {
                // found pair
                let pPersonName = positivesDic[target]!.removeFirst()
                
                for negativeValue in negativesResults {
                    var nPersonName: String
                    print("negativeValue: \(negativeValue)")
                    print("negativeCandidate: \(negativeCandidates)")
                    nPersonName = negativesDic[-negativeValue]!.removeFirst()
                    
                    if negativesDic[-negativeValue]!.count == 0 { negativesDic[-negativeValue] = nil }
                    
                    let resultTuple: (ResultTuple) = (from: nPersonName, to: pPersonName, amount: negativeValue)
                    resultTuples.append(resultTuple)
                    print("resultTuple: \(resultTuple)")
                }
                if positivesDic[target]!.count == 0 { positivesDic[target] = nil }
                

                // update negativesDic, NegativeCandidates,
                negativeCandidates = [Int]()
                for (amt, _) in negativesDic {
                    negativeCandidates.append(-amt)
                }
                negativeCandidates.sort(by: >)
                
            }
        }
        
        
        // MARK: - n : n (not implemented Yet.. ) 
        
        

        print("in the end, resultTuples: \(resultTuples)")
        print("positivesDic: \(positivesDic)")
        print("negativesDic: \(negativesDic)")
        
        
        // MARK: - 하나 남았을 때 처리
        
        if negativesDic.count == 1, let lastNagativeElement = negativesDic.first, lastNagativeElement.value.count == 1 {
            let lastnName = lastNagativeElement.value[0]
            for (amt, names) in positivesDic {
                for name in names {
                    let tupleResult: (ResultTuple) = (from: lastnName, to: name, amount: amt)
                    resultTuples.append(tupleResult)
                }
                positivesDic[amt] = nil
            }
            let value = lastNagativeElement.key
            negativesDic[value] = nil
        }
        
        
        if positivesDic.count == 1, let lastPositiveElement = negativesDic.first,
           lastPositiveElement.value.count == 1 {
            let lastpName = lastPositiveElement.value[0]
            for (amt, names) in negativesDic {
                for name in names {
                    let resultTuple: (ResultTuple) = (from: name, to: lastpName, amount: -amt)
                    resultTuples.append(resultTuple)
                }
            }
            let value = lastPositiveElement.key
            positivesDic[value] = nil
        }
        
        print("in the very end, resultTuples: \(resultTuples)")
        print("positivesDic: \(positivesDic), negativesDic: \(negativesDic)")
    }
    
    
    
    
    func combos<T>(elements: ArraySlice<T>, k: Int) -> [[T]] {
        if k == 0 {
            return [[]]
        }

        guard let first = elements.first else {
            return []
        }

        let head = [first]
        let subcombos = combos(elements: elements, k: k - 1)
        var ret = subcombos.map { head + $0 }
        ret += combos(elements: elements.dropFirst(), k: k)

        return ret
    }

    func combos<T>(elements: Array<T>, k: Int) -> [[T]] {
        return combos(elements: ArraySlice(elements), k: k)
    }
        
    //return [value: [indexOfSmallerNums]]
    func createCombination(using array: [Int], numToPick: Int) -> [Int: [Int]] {
        
// arr = [0,1,2, ... array.count-1]
        var arr = Array(repeating: 0, count: array.count)
        for (idx, _) in array.enumerated() {
            arr[idx] = idx
        }
        
        if arr.count < numToPick { return [:] }
        
        print("flag 5, arr: \(arr)")
        let combos = combos(elements: arr, k: numToPick)
        print("semiResult, combos: \(combos)")
        
        var result = [Int:[Int]]()
        var unitResult = 0
        
        for eachCombo in combos {
            unitResult = 0
            for eachIndex in eachCombo {
                unitResult += array[eachIndex]
            }
//            print("unit result: \(unitResult), eachCombo: \(eachCombo)")
            result[unitResult] = eachCombo
        }
        

        
        
//        print("result22 : \(result)")
        return result
    }
    
    func convertActualNums(sourceArray: [Int], target: [Int: [String]]) -> [Int: String] {
//        var result = [String]()
        var result = [Int:String]()
        
        for value in sourceArray {
//            let myResult = target[value]!
            let myResult = target[value]!
//            result.append(myResult)
//            result.append(myResult.first!)
            result
        }
        
        return result
    }
}







//newPersonDetails: [(name: "a2", spentAmount: 25),
//                   (name: "a4", spentAmount: 4),
//                   (name: "a9", spentAmount: 17),
//                   (name: "a10", spentAmount: 7),
//                   (name: "a11", spentAmount: 14),
//                   (name: "b1", spentAmount: -54),
//                   (name: "b2", spentAmount: -13)]
//
//newPositiveDic: [4: ["a4"],
//                 17: ["a9"],
//                 25: ["a2"],
//                 7: ["a10"],
//                 14: ["a11"],
//                 0: ["a8"]]
//
//newNegativeDic: [-54: ["b1"],
//                  -13: ["b2"]]





//newPersonDetails: [
//(name: "a2", spentAmount: 25),
//(name: "a4", spentAmount: 4),
//(name: "a9", spentAmount: 17),
//(name: "a10", spentAmount: 7),
//(name: "a11", spentAmount: 14),
//(name: "a12", spentAmount: 7),
//(name: "b1", spentAmount: -54),
//(name: "b2", spentAmount: -13),
//(name: "b8", spentAmount: -5),
//(name: "b9", spentAmount: -2)]


//newPositiveDic:
//[4: ["a4"],
//17: ["a9"],
//14: ["a11"],
//7: ["a10", "a12"],
//25: ["a2"]]

//newNegativeDic:[
//-54: ["b1"],
//-13: ["b2"],
//  -5: ["b8"],
//  -2: ["b9"]]





//newPositiveDic: [
//    14: ["a11"],
//    4: ["a4"],
//    17: ["a9"],
//    7: ["a10", "a12"],
//    6: ["a13", "a12"],
//    25: ["a2"]]
//
//newNegativeDic: [
//    -13: ["b2"],
//     -54: ["b1"],
//     -2: ["b9", "b11"],
//     -10: ["b10"],
//     -5: ["b8"]]

extension DutchResultTest {
    func convertResult(matchedIndexes:[Int], smallerNums: [Int], negativesDic: [Int: [String]]) -> [Int: String]{

        var result = [Int:String]()
        for matchedIndex in matchedIndexes {
            let value = smallerNums[matchedIndex]
            let name = negativesDic[value]![0]
            result[value] = name
        }
        
        return result
    }
    
    func removePersonFromDic(amt: Int, negativesDic: inout [Int: [String]]) {
        if negativesDic[amt]!.count > 1 {
            negativesDic[amt]!.removeFirst()
        } else {
            negativesDic[amt] = nil
        }
    }
    
    func convertResult2(source: [Int], indexes: [Int]) -> [Int]{
//        return []
        var result = [Int]()
        for index in indexes {
            result.append(source[index])
        }
        return result
    }
}














extension DutchResultTest {
    
    func test_fromTheTop() {
        
        //        typealias PersonTuple = (name: String, spentAmount: Int)
        //        typealias ResultTuple = (from: String, to: String, amount: Int)
        
        var personDetails: [PersonTuple] = [
            ("a1", 1), ("a2", 25), ("a3", 7), ("a4", 4),
            ("a5", 7), ("a6", 5), ("a7", 2), ("a8", 0),
            ("a9", 17), ("a10", 7), ("a11", 14),("a12", 7),("a13", 6),("a12", 6),
            
            ("b1", -54), ("b2", -13), ("b3", -2), ("b4", -1),
            ("b5", -5), ("b6", -7),("b7", -7),("b8", -5),
            ("b9", -2),("b10", -10),("b11", -2) ]
        
        personDetails = personDetails.filter { $0.spentAmount != 0 }
        
        var positiveTuples = [PersonTuple]()
        var negativeTuples = [PersonTuple]()
        var resultTuples = [ResultTuple]()
        
        
        
        for tup in personDetails {
            if tup.spentAmount >= 0 {
                positiveTuples.append(tup)
            } else {
                negativeTuples.append(tup)
            }
        }
        
        // --------------------------------Test----------------------------- //
        let positiveSum = positiveTuples.map { $0.spentAmount}.reduce(0, +)
        let negativeSum = negativeTuples.map { $0.spentAmount }.reduce(0, +)
        XCTAssertEqual(positiveSum, -negativeSum)
        // ----------------------------------------------------------------- //
        
        
        // MARK: - Make Dictionary for both signs
        var positivesDic: [Int: [String]] = [:]
        var negativesDic: [Int: [String]] = [:]
        
        for personTuple in positiveTuples {
            if positivesDic[personTuple.spentAmount] != nil {
                positivesDic[personTuple.spentAmount]!.append(personTuple.name)
                
            } else {
                positivesDic[personTuple.spentAmount] = [personTuple.name]
            }
        }
        
        for  personTuple in negativeTuples {
            if negativesDic[personTuple.spentAmount] != nil {
                negativesDic[personTuple.spentAmount]!.append(personTuple.name)
                
            } else {
                negativesDic[personTuple.spentAmount] = [personTuple.name]
            }
        }
        
        print("positivesDic: \(positivesDic)")
        print("negativesDic: \(negativesDic)")
        
        // MARK: - Match 1 on 1 // Using Dynamic approach may reduce time complexity ..
        
        var matchedPeopleName = Set<String>()
        
        for (spentAmount, positivePersonNames) in positivesDic {
            print("flag 1, spentAmount: \(spentAmount)")
            if let validNegativeNames = negativesDic[-1 * spentAmount] {
                // MATCH
                print("flag 2, validNegativeNames: \(validNegativeNames)")
                for (idx, positivePersonName) in positivePersonNames.enumerated() {
                    if idx < validNegativeNames.count {
                        
                        print("flag 3, idx: \(idx), validNegativenames.count: \(validNegativeNames.count)")
                        resultTuples.append((from: validNegativeNames[idx], to: positivePersonName, amount: spentAmount))
                        matchedPeopleName.insert(validNegativeNames[idx])
                        matchedPeopleName.insert(positivePersonName)
                    }
                }
            }
        }
        
        print("resultTuples: \(resultTuples)")
        XCTAssertNotEqual(resultTuples.count, 0)
        
        // Match 1 on 1 후처리 ;; 추후 반드시 수정 필요.
        // create new personDetails
        var newPersonDetails = [PersonTuple]()
        
        for eachPersonInfo in personDetails {
            if matchedPeopleName.contains(eachPersonInfo.name) == false {
                newPersonDetails.append(eachPersonInfo)
            }
        }
        
        positivesDic = [:]
        negativesDic = [:]
        
        positiveTuples = [PersonTuple]()
        negativeTuples = [PersonTuple]()
        
        for tup in newPersonDetails {
            if tup.spentAmount > 0 {
                positiveTuples.append(tup)
            } else if tup.spentAmount < 0 {
                negativeTuples.append(tup)
            }
        }
        
        
        for personTuple in positiveTuples {
            if positivesDic[personTuple.spentAmount] != nil {
                positivesDic[personTuple.spentAmount]!.append(personTuple.name)
                
            } else {
                positivesDic[personTuple.spentAmount] = [personTuple.name]
            }
        }
        
        for  personTuple in negativeTuples {
            if negativesDic[personTuple.spentAmount] != nil {
                negativesDic[personTuple.spentAmount]!.append(personTuple.name)
                
            } else {
                negativesDic[personTuple.spentAmount] = [personTuple.name]
            }
        }
        
        print("newPersonDetails: \(newPersonDetails)\n")
        print("newPositiveDic: \(positivesDic)")
        print("newNegativeDic: \(negativesDic)")
        
        // MARK: - 1: n
        print("Stage 2, Matching 1: n")
        
        
        
        
        
        
        /*
        
        // FIXME: 후처리 및 중간단계 실시간 처리. How ?? 더 큰 Loop 안에 가두기 ?
    positiveLoop: for (pValue, pPeople) in positivesDic {
        negativeLoop: for (nValue, nPeople) in negativesDic {
            print("flag 7, negativesDic: \(negativesDic)")
            
            var negativeValueSet = Set<Int>()
            
            for (nvalue, _) in negativesDic {
                negativeValueSet.insert(nvalue)
            }
            
            var allNums = [Int]()
            
            for (key, _ ) in negativesDic {
                allNums.append(key)
            }
            
            allNums = allNums.sorted(by: >)
            
            
            if pValue > -nValue {
                let diff = pValue + nValue

                if negativeValueSet.contains(-diff) {
                    if -diff != nValue { // 중복 값 처리.
                    resultTuples.append((from: nPeople.first!,to: pPeople.first!, amount: -nValue))
                    let negativePerson = negativesDic[-diff]!.first!
                    resultTuples.append((from: negativePerson, to: pPeople.first!, amount: diff))
                        print("found matched ones!")
                    print("matched ! \(nPeople.first!), \(pPeople.first!), amount: \(-nValue)")
                    print("matched ! \(negativePerson), \(pPeople.first!), amount: \(diff)")
                    // TODO: 매칭된 것들 List 에서 지워야함
                    continue positiveLoop
                    }
                } else {
                    // get ingredients for combinations
                    var smallerNums = [Int]()
                    print("flag 5 start to make smallerNums, pValue: \(pValue), nValue: \(nValue), diff: \(diff) ")
                    makingSmaller: for allNum in allNums {
                        print("flag 6 diff: \(diff), -allNum: \(-allNum)")
                        if diff > -allNum && allNum != nValue {
                            smallerNums.append(allNum)
                        } else if diff < -allNum { break makingSmaller }
                    }
                    
                    
                    // TODO: 2 ~ n 명까지 골라주기.
                    // n 범위는 어디까지여? 중복도 허용해야함 ?? 응.. 반드시 허용해야함.
                    
                    let createdComb = createCombination(using: smallerNums, numToPick: 2)
                    
                    if createdComb == [:] { continue negativeLoop }
                    
                    for (key, matchedIndexes) in createdComb {
                        if key == -diff {
                            
                            let resultTuple1 = (from: nPeople.first!, to: pPeople.first!, amount: -nValue)
                            
                            removePersonFromDic(amt: nValue, negativesDic: &negativesDic)
                            
                            resultTuples.append(resultTuple1)
                            // TODO: n 개의 elements 에 대해 사용할 수 있는 function 만들기.
                            
                            let result = convertResult(matchedIndexes: matchedIndexes, smallerNums: smallerNums, negativesDic: negativesDic)
                            
                            print("found matched ones! ")
                            print("unitResult: \(resultTuple1)")
                            for (amt, value) in result {
                                let unitResult: ResultTuple = (from:value , to: pPeople.first!, amount:-amt )
                                print("unitResult: \(unitResult)")
                                resultTuples.append(unitResult)
                                
                                removePersonFromDic(amt: amt, negativesDic: &negativesDic)
                            }
                            continue positiveLoop
                        }
                    }
                }
            }
        }
        
        
        print("\n\n\n\n")
        print("printing results ")
        for eachResult in resultTuples {
            print(eachResult)
        }
        print("remained Minuses: \(negativesDic)")
        
        
    }
        */
        
        
        let comboTests = combos(elements: [1,2,3,4,5], k: 2)
        print("comboTests: \(comboTests)")
        XCTAssertNotEqual(comboTests.count, 0)
        
    }
    
    
}


//extension DutchResultTest {
//    func combinationSum(candidates: [Int], target: Int) -> [[Int]] {
//        var results = [[Int]]()
//        var comb = LinkedList
//
//        var counter = [Int:Int]()
//
//        for candidate in candidates {
//            if counter[candidate] != nil {
//                counter[candidate] = counter[candidate]! + 1
//            } else {
//                counter[candidate] = 1
//            }
//        }
//
//        // list of (num, count) tuple ??
//        var counterList = [(Int,Int)]() // Type 이거 아닐 수도 있음
//        counter.forEach { (key, value) in
////            counterList
//            counterList.append((key, value))
//        }
//
//        backtrack(comb, target, 0, counterList, results)
//        return results
//
//    }
//
//    func backtrack(comb: LinkedList, remain: Int, curr: Int, )
//}

extension DutchResultTest {
    // sortedCandidates // return Indexes of candidates in [Int]
    func combinationSum(candidates: [Int], target: Int) -> [Int] {
        
        let sortedCandidates = candidates.sorted(by: >)
        
        var currentIndex = 0
        
        var initialDigitIdx = 0
        
        var selectedIndexes = [Int]()
        
        let length = candidates.count
        
        var selectedDigitIdx = 0
    
    bigLoop: while (initialDigitIdx < length) {
            
            digitLoop: while (selectedDigitIdx < length) {
                if currentIndex < length {
                    selectedIndexes.append(currentIndex)
                } else {
                    initialDigitIdx += 1
                    continue bigLoop
                }
                
                print("flag 1, selectedIndexes: \(selectedIndexes)")
                let result = getResult(target: sortedCandidates, indexes: selectedIndexes)
                print("flag 2, result: \(result)")
                if result == target {
                    print("flag 3, return : \(selectedIndexes)")
                    return selectedIndexes }
                
                else if result < target {
                    selectedDigitIdx += 1
                    currentIndex = selectedIndexes[selectedIndexes.count - 1] + 1
                    print("flag 4, selectedDigitIdx: \(selectedDigitIdx)")
                    continue digitLoop
                }
                
                else if result > target {
                    if selectedDigitIdx > 0 {
                    selectedDigitIdx -= 1
                    }
                    currentIndex = selectedIndexes[selectedIndexes.count - 1] + 1
                    selectedIndexes.removeLast()
                    continue digitLoop
                }
                
            }
            
            currentIndex = selectedIndexes[0] + 1
            selectedIndexes = [currentIndex]
            initialDigitIdx += 1
            print("flag 3, selectedIndexes: \(selectedIndexes)")
            
        }

        return []
    }

    
    func test_combinationSum() {
        // Index 를 날리는구나 ?
        let result = combinationSum(candidates: [1,2,3,4,5,6], target: 6)
        print("final result: \(result)")
        XCTAssertNotEqual(result, [10])
    }
    
    func getResult(target: [Int], indexes: [Int]) -> Int {
        var result = 0
        for index in indexes {
            result += target[index]
        }
        return result
    }
    
    
    func test_combination() {
        let results = combinationSum(candidates: [1,1,2,3,1,4,2,5], target: 5)
        
    }
    
    func backtrack(selectedIndexes: [Int], currentIndex: Int, candidates: [Int], target: Int ) {
        
    }
}




//in the end, resultTuples: [
//    (from: "b5", to: "a6", amount: 5),
//    (from: "b4", to: "a1", amount: 1),
//    (from: "b3", to: "a7", amount: 2),
//    (from: "b6", to: "a3", amount: 7),
//    (from: "b7", to: "a5", amount: 7),
//
//    (from: "b8", to: "a10", amount: 5),
//    (from: "b9", to: "a10", amount: 2),
//    (from: "b2", to: "a2", amount: 13),
//    (from: "b10", to: "a2", amount: 10),
//    (from: "b11", to: "a2", amount: 2)]
