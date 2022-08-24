//
//  DutchResultTest.swift
//  CalieTests
//
//  Created by Mac mini on 2022/08/15.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import XCTest
import CoreData
import Darwin

@testable import Calie


typealias Idx = Int

typealias PersonTuple = (name: String, spentAmount: Int, idx: Idx)
//typealias ResultTuple = (from: String, to: String, amount: Int)
typealias ResultTuple = (from: Idx, to: Idx, amount: Int)
typealias BinIndex = Int

struct PersonStruct {
    let name: String
    var spentAmount: Int
    var idx: Idx
}
extension PersonStruct: Hashable {
    
}

class DutchResultTest: XCTestCase {
    // Bit Operator Helpers
    func poweredInt(base: Int = 2, exponent: Int) -> Int {
        return Int(pow(Double(base), Double(exponent)))
    }
    
    func printBin(target: Int, isPositive: Bool = true) {
        let toPrint = String(target, radix: 2)
        let additionalMsg = isPositive ? "plusRemainders:" : "minusRemainders:"
        print(additionalMsg + " " + toPrint)
    }
    
    func digitFromTheRight(bin: Int, location: Idx) -> Int? {
        let binInStr = String(bin, radix: 2)
//        let idx = binInStr.index(binInStr.endIndex, offsetBy: -location)
        let startIdx = binInStr.startIndex
        let idx = binInStr.index(startIdx, offsetBy: binInStr.count - location - 1)
//        return Int(binInStr[idx])
        print("idx: \(idx)")
        print("binInStr: \(binInStr)")
        let someChar = binInStr[idx]
//        return Int(someChar)
        if someChar == "0" { return 0 }
        else if someChar == "1" { return 1}
        else { return nil }
    }
    
    func test_getIndices()  {
    let indices = getIndicesArr(from: 11) // 1011
        XCTAssertEqual(indices, [0,1,3])
    }
    
    func test_dictionary() {
        var dic: [Int: Int] = [1:2, 2:3]
        
        for (key, value) in dic {
            dic[key] = key
        }
        XCTAssertEqual(dic[1], 1)
    }
    
    func getIndicesArr(from bin: Int) -> [Int] {
        let binInStr = String(bin, radix: 2)
        let length = binInStr.count
        var ret = [Int]()
        
        // 1 만 찾도록 하면 더 빠르게 만들 수 있을 것 같음.
        for idx in 0 ..< binInStr.count {
            let binIdx = binInStr.index(binInStr.startIndex, offsetBy: length - idx - 1)
            if binInStr[binIdx] == "1" {
                ret.append(idx)
            }
        }
        print("ret: \(ret)")
        return ret
    }
    
    func getIndicesSet(from bin: Int) -> Set<Int> {
        let binInStr = String(bin, radix: 2)
        let length = binInStr.count
        var ret = Set<Int>()
        
        // 1 만 찾도록 하면 더 빠르게 만들 수 있을 것 같음.
        for idx in 0 ..< binInStr.count {
            let binIdx = binInStr.index(binInStr.startIndex, offsetBy: length - idx - 1)
            if binInStr[binIdx] == "1" {
//                ret.append(idx)
                ret.update(with: idx)
            }
        }
        print("ret: \(ret)")
        return ret
    }
    
    func test_bitRemainder() {
        let testBin = 0b1101

        XCTAssertEqual(digitFromTheRight(bin: testBin, location: 0), 1)
        XCTAssertEqual(digitFromTheRight(bin: testBin, location: 1), 0)
        XCTAssertEqual(digitFromTheRight(bin: testBin, location: 2), 1)
        XCTAssertEqual(digitFromTheRight(bin: testBin, location: 3), 1)
    }
    
    func test_bitTest() {
        var testBit = 0b00000000
        
//        print(testBig)
        XCTAssertEqual(testBit, 0)
        
        let handledDigits = [0,2,4]
        
        for digit in handledDigits {
//            let newBit: Int = Int(pow(2, digit))
            let newBit: Int = Int(pow(Double(2), Double(digit)))
            
            let newNum = String(newBit, radix: 2)
//            let binaryNum = 0b
            testBit += newBit
            print("testBit: \(testBit)")
//            testBit += newBit
        }
        
        let someBin = 0b00000010
        XCTAssertEqual(testBit, 21)
        testBit = testBit | someBin
        XCTAssertEqual(testBit, 23)
        
        let bin1 = 14 // 01110
        let bin2 = 16 // 10000
        
        let bin2Str = String(bin2, radix: 2)
        let bin3 = bin2 << 1
        
        print("bin2Str: \(bin2Str)")
        print("bin3: \(bin3)")
        
        let resultBin = bin1 | bin2
        XCTAssertEqual(resultBin, 30)
    }
    
    
    func test_fromTheTop_duplicate_UsingBit() {
        
        //        typealias PersonTuple = (name: String, spentAmount: Int)
        //        typealias ResultTuple = (from: String, to: String, amount: Int)
        
//        var personDetails: [PersonTuple] = [
////            PersonStruct(name: <#T##String#>, spentAmount: <#T##Int#>, idx: <#T##Idx#>)
//            ("a0", 1, idx: 0), ("a1", 25, idx: 1), ("a2", 7, idx: 2), ("a3", 4, idx: 3),
//            ("a4", 7, idx: 4), ("a5", 5, idx: 5), ("a6", 2, idx: 6), ("a7", 0, idx: 7),
//            ("a8", 17, idx: 8), ("a9", 7, idx: 9), ("a10", 14, idx: 10),("a11", 7, idx: 11),
//            ("a12", 6, idx: 12),("a13", 6, idx: 13),
//
//            ("b0", -54, idx: 0), ("b1", -13, idx: 1), ("b2", -2, idx: 2), ("b3", -1, idx: 3),
//            ("b4", -5, idx: 4), ("b5", -7, idx: 5),("b6", -7, idx: 6),("b7", -5, idx: 7),
//            ("b8", -2, idx: 8),("b9", -10, idx: 9),("b10", -2, idx: 10)
//        ]
        
        var personDetailsIngre: [PersonTuple] = [
//            PersonStruct(name: <#T##String#>, spentAmount: <#T##Int#>, idx: <#T##Idx#>)
            ("a0", 1, idx: 0), ("a1", 25, idx: 1), ("a2", 7, idx: 2), ("a3", 4, idx: 3),
            ("a4", 7, idx: 4), ("a5", 5, idx: 5), ("a6", 2, idx: 6), ("a7", 0, idx: 7),
            ("a8", 17, idx: 8), ("a9", 7, idx: 9), ("a10", 14, idx: 10),("a11", 7, idx: 11),
            ("a12", 6, idx: 12),("a13", 6, idx: 13),
            
            ("b0", -54, idx: 0), ("b1", -13, idx: 1), ("b2", -2, idx: 2), ("b3", -1, idx: 3),
            ("b4", -5, idx: 4), ("b5", -7, idx: 5),("b6", -7, idx: 6),("b7", -5, idx: 7),
            ("b8", -2, idx: 8),("b9", -10, idx: 9),("b10", -2, idx: 10)
        ]
        
        var personDetails: [PersonStruct] = personDetailsIngre.map { PersonStruct(name: $0.name, spentAmount: $0.spentAmount, idx: $0.idx)}
        

        
        personDetails = personDetails.filter { $0.spentAmount != 0 }
        
//  PersonTuple = (name: String, spentAmount: Int, idx: Idx)
        
//        var positiveTuples = [PersonTuple]()
//        var negativeTuples = [PersonTuple]()
//        var resultTuples = [ResultTuple]()
        
        var plusRemainders = 0
        
        var minusRemainders = 0
        
        var positivePersonSet = Set<PersonStruct>()
        var negativePersonSet = Set<PersonStruct>()
        var resultTuples = [ResultTuple]()
        
        for tup in personDetails {
            if tup.spentAmount > 0 {
//                positiveTuples.append(tup)
                positivePersonSet.update(with: tup)
            } else {
//                negativeTuples.append(tup)
                negativePersonSet.update(with: tup)
            }
        }
        

        
//        print("positiveTuples: \(positiveTuples)")
        print("\npositiveTuples: from the beginning")
        for positiveTuple in positivePersonSet {
            print("remaining positiveTuple: idx: \(positiveTuple.idx), amt: \(positiveTuple.spentAmount)")
        }
        
        print("\nnegativeTuples: from the beginning")
        for negativeTuple in negativePersonSet {
            print("remaining negativeTuple: idx: \(negativeTuple.idx), amt: \(negativeTuple.spentAmount)")
        }
        
        
        XCTAssertEqual(positivePersonSet.count, 13)
        XCTAssertEqual(negativePersonSet.count, 11)
        
        var numOfPlusPeople = positivePersonSet.count
        var numOfMinusPeople = negativePersonSet.count
        


        
        // ---------------------Equal Total Amount Test ----------------------------- //
        let positiveSum = positivePersonSet.map { $0.spentAmount}.reduce(0, +)
        let negativeSum = negativePersonSet.map { $0.spentAmount }.reduce(0, +)
        XCTAssertEqual(positiveSum, -negativeSum)
        // ----------------------------------------------------------------- //
        
        
        // MARK: - Make Dictionary for both signs
        // spentAmount: Index
        var positivesDic: [Int: [Idx]] = [:]
        var negativesDic: [Int: [Idx]] = [:]
        
        for personTuple in positivePersonSet {
            if positivesDic[personTuple.spentAmount] != nil {
                positivesDic[personTuple.spentAmount]!.append(personTuple.idx)
                
            } else {
                positivesDic[personTuple.spentAmount] = [personTuple.idx]
            }
        }
        
        for  personTuple in negativePersonSet {
            if negativesDic[personTuple.spentAmount] != nil {
                negativesDic[personTuple.spentAmount]!.append(personTuple.idx)
                
            } else {
                negativesDic[personTuple.spentAmount] = [personTuple.idx]
            }
        }
        
        print("positivesDic: \(positivesDic)")
        print("negativesDic: \(negativesDic)")
        
        // MARK: - Match 1 on 1 // Using Dynamic approach may reduce time complexity ..
        
        for (pSpentAmount, positivePersonIndices) in positivesDic {
            
            if let validNegativeIndices = negativesDic[-1 * pSpentAmount] {
                // MATCH
                for (forwardingIdx, positivePersonIdx) in positivePersonIndices.enumerated() {
                    if forwardingIdx < validNegativeIndices.count {
                        
                        resultTuples.append((from: validNegativeIndices[forwardingIdx], to: positivePersonIdx, amount: pSpentAmount))
    
                        plusRemainders += poweredInt(exponent: positivePersonIndices[forwardingIdx])
                        minusRemainders += poweredInt(exponent: validNegativeIndices[forwardingIdx])
                        
                    }
                }
            }
        }
        
        print("After 1 : 1 Match, ")
        printBin(target: plusRemainders)
        printBin(target: minusRemainders, isPositive: false)
        
        
//        print("resultTuples: \(resultTuples)")
        for eachTuple in resultTuples {
            print("from idx: \(eachTuple.from), to idx: \(eachTuple.to), amt: \(eachTuple.amount)")
        }
        XCTAssertNotEqual(resultTuples.count, 0)
        
        // Match 1 on 1 후처리
        // Positive Dic, Tuple,
        // Negative Dic, Tuple
        
//        let donePlusIndices = getIndicesArr(from: plusRemainders)
        // 이거 용도는 뭐지...??
        let donePlusIndices = getIndicesSet(from: plusRemainders)
        
//        positiveTuples
        for idx in donePlusIndices {
            let target = positivePersonSet.filter { $0.idx == idx }.first!
            positivePersonSet.remove(target)
        }
        
//        let doneMinusIndices = getIndicesArr(from: minusRemainders)
        let doneMinusIndices = getIndicesSet(from: minusRemainders)
        for idx in doneMinusIndices {
            let target = negativePersonSet.filter { $0.idx == idx }.first!
            negativePersonSet.remove(target)
        }
        
         numOfPlusPeople = positivePersonSet.count
         numOfMinusPeople = negativePersonSet.count
        
//        for some in positi
        
        
        // MARK: - Update positivesDic, negativesDic
        let clonedPositivesDic = positivesDic
        for (amt, indices) in clonedPositivesDic {
            var tempIndices: Set<Idx> = Set(indices)
            
            for eachIdx in tempIndices {
                if donePlusIndices.contains(eachIdx) {
                    tempIndices.remove(eachIdx)
                }
            }
            if tempIndices.count != 0 {
                positivesDic[amt] = Array(tempIndices)
            } else {
                positivesDic[amt] = nil
            }
        }
        
        let clonedNegativesDic = negativesDic
        for (amt, indices) in clonedNegativesDic {
            var tempIndices: Set<Idx> = Set(indices)
            
            for eachIdx in tempIndices {
                if doneMinusIndices.contains(eachIdx) {
                    tempIndices.remove(eachIdx)
                }
            }
            if tempIndices.count != 0 {
                negativesDic[amt] = Array(tempIndices)
            } else {
                negativesDic[amt] = nil
            }
        }
        
        
        print("\npositiveTuples: after 1:1 match")
        for positiveTuple in positivePersonSet {
            print("remaining positiveTuple: idx: \(positiveTuple.idx), amt: \(positiveTuple.spentAmount)")
        }
        print("dictionary: \(positivesDic)")
        
        print("\nnegativeTuples: after 1:1 match")
        for negativeTuple in negativePersonSet {
            print("remaining negativeTuple: idx: \(negativeTuple.idx), amt: \(negativeTuple.spentAmount)")
        }
        print("dictionary: \(negativesDic)")
        
        
        
        
        
        // MARK: - 1: N     positives 1 : negatives N
        print("Stage 2, Matching 1: n")
        
        var negativeCandidates = [Int]()
        var positiveCandidates = [Int]()
        
        // 중복 허용.
        for personInfo in negativePersonSet {
            negativeCandidates.append(-personInfo.spentAmount)
        }
        
        for personInfo in positivePersonSet {
            positiveCandidates.append(personInfo.spentAmount)
        }
    
        negativeCandidates.sort(by: >)  // [54, ... 2, 1, 1]
        positiveCandidates.sort(by: <)  // [1,2,3, ... ]
       
        // include updating negativesDic, positivesDic
        for positiveCandidateAmt in positiveCandidates {
            let targetAmt = positiveCandidateAmt
            
            let negativeResultIndexes = combinationSum(candidates: negativeCandidates, target: targetAmt)
            
//            convertResult2(source: [Int], indexes: [Int]) -> [Int]
            let negativesResults = convertResult2(source: negativeCandidates, indexes: negativeResultIndexes)
            print("found pair! \(negativesResults)")
            // found pair
            if negativeResultIndexes != [] {
               
                let pPersonIdx = positivesDic[targetAmt]!.removeFirst()
                
                for negativeValue in negativesResults {
                    var nPersonIdx: Idx
                    
                    nPersonIdx = negativesDic[-negativeValue]!.removeFirst()
                    
                    if negativesDic[-negativeValue]!.count == 0 {
                        negativesDic[-negativeValue] = nil
                    }
                    
                    let resultTuple: (ResultTuple) = (from: nPersonIdx, to: pPersonIdx, amount: negativeValue)
                    resultTuples.append(resultTuple)
                    
                    
                    let ntargetPerson = negativePersonSet.filter { $0.spentAmount == -negativeValue}.first!
                    negativePersonSet.remove(ntargetPerson)
                    
                    let ntargetIdx = ntargetPerson.idx
                    minusRemainders += poweredInt(exponent: ntargetIdx)
                }
                
                let ptargetPerson = positivePersonSet.filter { $0.idx == pPersonIdx}.first!
                positivePersonSet.remove(ptargetPerson)
                
                let ptargetIdx = ptargetPerson.idx
                plusRemainders += poweredInt(exponent: ptargetIdx)
                
                
                if positivesDic[targetAmt]!.count == 0 {
                    positivesDic[targetAmt] = nil
                }
                
                // update  NegativeCandidates using negativesDic
                negativeCandidates = [Int]()
                for (amt, _) in negativesDic {
                    negativeCandidates.append(-amt)
                }
                negativeCandidates.sort(by: >)
                
            }
        }
        
        
        // MARK: - n : n (not implemented Yet.. )
        print("in the end of 1:n , resultTuples:")
        
        for eachTuple in resultTuples {
            print("from idx: \(eachTuple.from), to idx: \(eachTuple.to), amt: \(eachTuple.amount)")
        }
        print("positivesDic: \(positivesDic)")
        print("negativesDic: \(negativesDic)")
        
        for eachPerson in positivePersonSet {
            print("person idx: \(eachPerson.idx), amt: \(eachPerson.spentAmount)")
        }
        
        for eachPerson in negativePersonSet {
            print("person idx: \(eachPerson.idx), amt: \(eachPerson.spentAmount)")
        }

        numOfPlusPeople = positivePersonSet.count
        numOfMinusPeople = negativePersonSet.count
        print("numOfPositives: \(numOfPlusPeople)") // 7
        print("numOfNegatives: \(numOfMinusPeople)") // 4
        

        printBin(target: plusRemainders)
        printBin(target: minusRemainders, isPositive: false)
        
//  MARK: - 여기까지 정상 작동 확인함. !!! 이제.. n:n 처리하기!
        
        
        
        
        
        
        
        
        
        
        
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
        
        // 이미 1:n 에 대해 했기 때문에 굳이 할 필요가 없어보임.
//        if positivesDic.count == 1, let lastPositiveElement = negativesDic.first,
//           lastPositiveElement.value.count == 1 {
//            let lastpName = lastPositiveElement.value[0]
//            for (amt, names) in negativesDic {
//                for name in names {
//                    let resultTuple: (ResultTuple) = (from: name, to: lastpName, amount: -amt)
//                    resultTuples.append(resultTuple)
//                }
//            }
//            let value = lastPositiveElement.key
//            positivesDic[value] = nil
//        }
        
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
    
    
//    func test_fromTheTop_duplicate() {
//
//        //        typealias PersonTuple = (name: String, spentAmount: Int)
//        //        typealias ResultTuple = (from: String, to: String, amount: Int)
//
//        var personDetails: [PersonTuple] = [
//            ("a1", 1), ("a2", 25), ("a3", 7), ("a4", 4),
//            ("a5", 7), ("a6", 5), ("a7", 2), ("a8", 0),
//            ("a9", 17), ("a10", 7), ("a11", 14),("a12", 7),("a13", 6),("a14", 6),
//
//            ("b1", -54), ("b2", -13), ("b3", -2), ("b4", -1),
//            ("b5", -5), ("b6", -7),("b7", -7),("b8", -5),
//            ("b9", -2),("b10", -10),("b11", -2) ]
//
//        personDetails = personDetails.filter { $0.spentAmount != 0 }
//
//        var positiveTuples = [PersonTuple]()
//        var negativeTuples = [PersonTuple]()
//        var resultTuples = [ResultTuple]()
//
//
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
//
//        var matchedPeopleName = Set<String>()
//
//        for (spentAmount, positivePersonNames) in positivesDic {
//            print("flag 1, spentAmount: \(spentAmount)")
//            if let validNegativeNames = negativesDic[-1 * spentAmount] {
//                // MATCH
//                print("flag 2, validNegativeNames: \(validNegativeNames)")
//                for (idx, positivePersonName) in positivePersonNames.enumerated() {
//                    if idx < validNegativeNames.count {
//
//                        print("flag 3, idx: \(idx), validNegativenames.count: \(validNegativeNames.count)")
//                        resultTuples.append((from: validNegativeNames[idx], to: positivePersonName, amount: spentAmount))
//                        matchedPeopleName.insert(validNegativeNames[idx])
//                        matchedPeopleName.insert(positivePersonName)
//                    }
//                }
//            }
//        }
//
//        print("resultTuples: \(resultTuples)")
//        XCTAssertNotEqual(resultTuples.count, 0)
//
//        // Match 1 on 1 후처리 ;; 추후 반드시 수정 필요.
//        // create new personDetails
//        var newPersonDetails = [PersonTuple]()
//
//        for eachPersonInfo in personDetails {
//            if matchedPeopleName.contains(eachPersonInfo.name) == false {
//                newPersonDetails.append(eachPersonInfo)
//            }
//        }
//
//        positivesDic = [:]
//        negativesDic = [:]
//
//        positiveTuples = [PersonTuple]()
//        negativeTuples = [PersonTuple]()
//
//        for tup in newPersonDetails {
//            if tup.spentAmount > 0 {
//                positiveTuples.append(tup)
//            } else if tup.spentAmount < 0 {
//                negativeTuples.append(tup)
//            }
//        }
//
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
//        print("newPersonDetails: \(newPersonDetails)\n")
//        print("newPositiveDic: \(positivesDic)")
//        print("newNegativeDic: \(negativesDic)")
//
//        // MARK: - 1: n
//        print("Stage 2, Matching 1: n")
//
//        var negativeCandidates = [Int]()
//        var positiveCandidates = [Int]()
//
//        for (amt, _) in negativesDic {
//            negativeCandidates.append(-amt)
//        }
//
//        for (amt, _) in positivesDic {
//            positiveCandidates.append(amt)
//        }
//
//        negativeCandidates.sort(by: >)  // [54, ... 2, 1, 1]
//        positiveCandidates.sort(by: <) // [1,2,3, ... ]
//
//        for positiveCandidate in positiveCandidates {
//            let target = positiveCandidate

//            let negativeResultIndexes = combinationSum(candidates: negativeCandidates, target: target)

////            let negativeResults = convert // Array of Values
//            let negativesResults = convertResult2(source: negativeCandidates, indexes: negativeResultIndexes)
//            if negativeResultIndexes != [] {
//                // found pair
//                let pPersonName = positivesDic[target]!.removeFirst()
//
//                for negativeValue in negativesResults {
//                    var nPersonName: String
//                    print("negativeValue: \(negativeValue)")
//                    print("negativeCandidate: \(negativeCandidates)")
//                    nPersonName = negativesDic[-negativeValue]!.removeFirst()
//
//                    if negativesDic[-negativeValue]!.count == 0 { negativesDic[-negativeValue] = nil }
//
//                    let resultTuple: (ResultTuple) = (from: nPersonName, to: pPersonName, amount: negativeValue)
//                    resultTuples.append(resultTuple)
//                    print("resultTuple: \(resultTuple)")
//                }
//                if positivesDic[target]!.count == 0 { positivesDic[target] = nil }
//
//
//                // update negativesDic, NegativeCandidates,
//                negativeCandidates = [Int]()
//                for (amt, _) in negativesDic {
//                    negativeCandidates.append(-amt)
//                }
//                negativeCandidates.sort(by: >)
//
//            }
//        }
//
//
//        // MARK: - n : n (not implemented Yet.. )
//
//
//
//        print("in the end, resultTuples: \(resultTuples)")
//        print("positivesDic: \(positivesDic)")
//        print("negativesDic: \(negativesDic)")
//
//
//        // MARK: - 하나 남았을 때 처리
//
//        if negativesDic.count == 1, let lastNagativeElement = negativesDic.first, lastNagativeElement.value.count == 1 {
//            let lastnName = lastNagativeElement.value[0]
//            for (amt, names) in positivesDic {
//                for name in names {
//                    let tupleResult: (ResultTuple) = (from: lastnName, to: name, amount: amt)
//                    resultTuples.append(tupleResult)
//                }
//                positivesDic[amt] = nil
//            }
//            let value = lastNagativeElement.key
//            negativesDic[value] = nil
//        }
//
//
//        if positivesDic.count == 1, let lastPositiveElement = negativesDic.first,
//           lastPositiveElement.value.count == 1 {
//            let lastpName = lastPositiveElement.value[0]
//            for (amt, names) in negativesDic {
//                for name in names {
//                    let resultTuple: (ResultTuple) = (from: name, to: lastpName, amount: -amt)
//                    resultTuples.append(resultTuple)
//                }
//            }
//            let value = lastPositiveElement.key
//            positivesDic[value] = nil
//        }
//
//        print("in the very end, resultTuples: \(resultTuples)")
//        print("positivesDic: \(positivesDic), negativesDic: \(negativesDic)")
//    }
    
//    func test_fromTheTop() {
//
//        //        typealias PersonTuple = (name: String, spentAmount: Int)
//        //        typealias ResultTuple = (from: String, to: String, amount: Int)
//
//        var personDetails: [PersonTuple] = [
//            ("a1", 1), ("a2", 25), ("a3", 7), ("a4", 4),
//            ("a5", 7), ("a6", 5), ("a7", 2), ("a8", 0),
//            ("a9", 17), ("a10", 7), ("a11", 14),("a12", 7),("a13", 6),("a12", 6),
//
//            ("b1", -54), ("b2", -13), ("b3", -2), ("b4", -1),
//            ("b5", -5), ("b6", -7),("b7", -7),("b8", -5),
//            ("b9", -2),("b10", -10),("b11", -2) ]
//
//        personDetails = personDetails.filter { $0.spentAmount != 0 }
//
//        var positiveTuples = [PersonTuple]()
//        var negativeTuples = [PersonTuple]()
//        var resultTuples = [ResultTuple]()
//
//
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
//
//        var matchedPeopleName = Set<String>()
//
//        for (spentAmount, positivePersonNames) in positivesDic {
//            print("flag 1, spentAmount: \(spentAmount)")
//            if let validNegativeNames = negativesDic[-1 * spentAmount] {
//                // MATCH
//                print("flag 2, validNegativeNames: \(validNegativeNames)")
//                for (idx, positivePersonName) in positivePersonNames.enumerated() {
//                    if idx < validNegativeNames.count {
//
//                        print("flag 3, idx: \(idx), validNegativenames.count: \(validNegativeNames.count)")
//                        resultTuples.append((from: validNegativeNames[idx], to: positivePersonName, amount: spentAmount))
//                        matchedPeopleName.insert(validNegativeNames[idx])
//                        matchedPeopleName.insert(positivePersonName)
//                    }
//                }
//            }
//        }
//
//        print("resultTuples: \(resultTuples)")
//        XCTAssertNotEqual(resultTuples.count, 0)
//
//        // Match 1 on 1 후처리 ;; 추후 반드시 수정 필요.
//        // create new personDetails
//        var newPersonDetails = [PersonTuple]()
//
//        for eachPersonInfo in personDetails {
//            if matchedPeopleName.contains(eachPersonInfo.name) == false {
//                newPersonDetails.append(eachPersonInfo)
//            }
//        }
//
//        positivesDic = [:]
//        negativesDic = [:]
//
//        positiveTuples = [PersonTuple]()
//        negativeTuples = [PersonTuple]()
//
//        for tup in newPersonDetails {
//            if tup.spentAmount > 0 {
//                positiveTuples.append(tup)
//            } else if tup.spentAmount < 0 {
//                negativeTuples.append(tup)
//            }
//        }
//
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
//        print("newPersonDetails: \(newPersonDetails)\n")
//        print("newPositiveDic: \(positivesDic)")
//        print("newNegativeDic: \(negativesDic)")
//
//        // MARK: - 1: n
//        print("Stage 2, Matching 1: n")
//
//
//
//
//
//
//        /*
//
//        // FIXME: 후처리 및 중간단계 실시간 처리. How ?? 더 큰 Loop 안에 가두기 ?
//    positiveLoop: for (pValue, pPeople) in positivesDic {
//        negativeLoop: for (nValue, nPeople) in negativesDic {
//            print("flag 7, negativesDic: \(negativesDic)")
//
//            var negativeValueSet = Set<Int>()
//
//            for (nvalue, _) in negativesDic {
//                negativeValueSet.insert(nvalue)
//            }
//
//            var allNums = [Int]()
//
//            for (key, _ ) in negativesDic {
//                allNums.append(key)
//            }
//
//            allNums = allNums.sorted(by: >)
//
//
//            if pValue > -nValue {
//                let diff = pValue + nValue
//
//                if negativeValueSet.contains(-diff) {
//                    if -diff != nValue { // 중복 값 처리.
//                    resultTuples.append((from: nPeople.first!,to: pPeople.first!, amount: -nValue))
//                    let negativePerson = negativesDic[-diff]!.first!
//                    resultTuples.append((from: negativePerson, to: pPeople.first!, amount: diff))
//                        print("found matched ones!")
//                    print("matched ! \(nPeople.first!), \(pPeople.first!), amount: \(-nValue)")
//                    print("matched ! \(negativePerson), \(pPeople.first!), amount: \(diff)")
//                    // TODO: 매칭된 것들 List 에서 지워야함
//                    continue positiveLoop
//                    }
//                } else {
//                    // get ingredients for combinations
//                    var smallerNums = [Int]()
//                    print("flag 5 start to make smallerNums, pValue: \(pValue), nValue: \(nValue), diff: \(diff) ")
//                    makingSmaller: for allNum in allNums {
//                        print("flag 6 diff: \(diff), -allNum: \(-allNum)")
//                        if diff > -allNum && allNum != nValue {
//                            smallerNums.append(allNum)
//                        } else if diff < -allNum { break makingSmaller }
//                    }
//
//
//                    // TODO: 2 ~ n 명까지 골라주기.
//                    // n 범위는 어디까지여? 중복도 허용해야함 ?? 응.. 반드시 허용해야함.
//
//                    let createdComb = createCombination(using: smallerNums, numToPick: 2)
//
//                    if createdComb == [:] { continue negativeLoop }
//
//                    for (key, matchedIndexes) in createdComb {
//                        if key == -diff {
//
//                            let resultTuple1 = (from: nPeople.first!, to: pPeople.first!, amount: -nValue)
//
//                            removePersonFromDic(amt: nValue, negativesDic: &negativesDic)
//
//                            resultTuples.append(resultTuple1)
//                            // TODO: n 개의 elements 에 대해 사용할 수 있는 function 만들기.
//
//                            let result = convertResult(matchedIndexes: matchedIndexes, smallerNums: smallerNums, negativesDic: negativesDic)
//
//                            print("found matched ones! ")
//                            print("unitResult: \(resultTuple1)")
//                            for (amt, value) in result {
//                                let unitResult: ResultTuple = (from:value , to: pPeople.first!, amount:-amt )
//                                print("unitResult: \(unitResult)")
//                                resultTuples.append(unitResult)
//
//                                removePersonFromDic(amt: amt, negativesDic: &negativesDic)
//                            }
//                            continue positiveLoop
//                        }
//                    }
//                }
//            }
//        }
//
//
//        print("\n\n\n\n")
//        print("printing results ")
//        for eachResult in resultTuples {
//            print(eachResult)
//        }
//        print("remained Minuses: \(negativesDic)")
//
//
//    }
//        */
//
//
//        let comboTests = combos(elements: [1,2,3,4,5], k: 2)
//        print("comboTests: \(comboTests)")
//        XCTAssertNotEqual(comboTests.count, 0)
//
//    }
    
    
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
                
                let result = getResult(target: sortedCandidates, indexes: selectedIndexes)
                print("flag 2, result: \(result)")
                // found matched indices
                if result == target {
                    print("flag 3, return : \(selectedIndexes)")
                    return selectedIndexes
                }
                
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
        // no match
        return []
    }

    
    func test_combinationSum() {
        // Index 를 날리는구나 ?
//        let result = combinationSum(candidates: [1,2,3,4,5,6], target: 6)
        let result = combinationSum(candidates: [3,3], target: 6)
        print("final result: \(result)")
        XCTAssertNotEqual(result, [10])
//        XCTAssertEqual(result, [0])
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
