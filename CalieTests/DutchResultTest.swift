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
        var negativeValueSet = Set<Int>()
        print("negativesDic: \(negativesDic)")
        for (nvalue, _) in negativesDic {
            negativeValueSet.insert(nvalue)
        }
        
        print("negativesValueSet: \(negativeValueSet)")
        var allNums = [Int]()
        
        for (key, _ ) in negativesDic {
            allNums.append(key)
        }
        
        allNums = allNums.sorted(by: >)
        print("hi?")
        print("allNums: \(allNums)")
        
        XCTAssertNotEqual(allNums.count, 0)
        
        // FIXME: 후처리 및 중간단계 실시간 처리. How ?? 더 큰 Loop 안에 가두기 ?
    positiveLoop: for (pValue, pPeople) in positivesDic {
        negativeLoop: for (nValue, nPeople) in negativesDic {
            
            if pValue > -nValue {
                let diff = pValue + nValue

                if negativeValueSet.contains(-diff) {
                    if -diff != nValue { // 중복 값 처리.
                    resultTuples.append((from: nPeople.first!,to: pPeople.first!, amount: -nValue))
                    let negativePerson = negativesDic[-diff]!.first!
                    resultTuples.append((from: negativePerson, to: pPeople.first!, amount: diff))
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
                    
                    print("input smallerNums: \(smallerNums) for pValue: \(pValue)\n" )
                    let createdComb = createCombination(using: smallerNums, numToPick: 2)
                    if createdComb == [:] { continue negativeLoop }
                    
                    for (key, matchedIndexes) in createdComb {
                        if key == -diff {
                            print("allNums: \(allNums)")
                            print("found one! diff: \(diff), pValue: \(pValue), nValue: \(nValue)")
                            print(" matched indexes: \(matchedIndexes), smallNums: \(smallerNums)")
                            
                            let resultTuple1 = (from: nPeople.first!, to: pPeople.first!, amount: -nValue)
                          
                            resultTuples.append(resultTuple1)
                            // TODO: n 개의 elements 에 대해 사용할 수 있는 function 만들기. 
                            let firstValue = smallerNums[matchedIndexes[0]]
                            let firstPersonName = negativesDic[firstValue]![0]
                            let secondValue = smallerNums[matchedIndexes[1]]
                            let secondPersonName = negativesDic[secondValue]![0]
                            
                            convertActualNums(sourceArray: smallerNums, target: negativesDic)
                            let resultTuple2 = (from: firstPersonName, to: pPeople.first!, amount: -firstValue)
                            let resultTuple3 = (from: secondPersonName, to: pPeople.first!, amount: -secondValue)
                            
                            resultTuples.append(resultTuple2)
                            resultTuples.append(resultTuple3)
                            // FIXME: 2, 3 사이에 중복 발생 (continue 없애면 발생. 현재도 발생 가능성 존재)
                            print("matched pValue: \(pValue)")
                            print("resultTuple1: \(resultTuple1)")
                            print("resultTuple2: \(resultTuple2)")
                            print("resultTuple3: \(resultTuple3)")
                            continue positiveLoop
                        }
                    }
                }
            }
        }
        print("\n\n\n\n")
        
        
        
    }
        
        let comboTests = combos(elements: [1,2,3,4,5], k: 2)
        print("comboTests: \(comboTests)")
        XCTAssertNotEqual(comboTests.count, 0)
        
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
            print("unit result: \(unitResult), eachCombo: \(eachCombo)")
            result[unitResult] = eachCombo
        }
        

        
        
        print("result22 : \(result)")
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
