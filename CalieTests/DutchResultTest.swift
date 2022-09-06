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


//typealias Idx = Int
//typealias Amt = Int
//typealias PersonTuple = (name: String, spentAmount: Int, idx: Idx)
////typealias ResultTuple = (from: String, to: String, amount: Int)
//typealias ResultTuple = (from: Idx, to: Idx, amount: Int)
//typealias BinIndex = Int


struct PersonStruct {
    var name: String?
    var spentAmount: Amt
    var idx: Idx
    
    init(idx: Idx, spentAmount: Amt) {
        self.spentAmount = spentAmount
        self.idx = idx
    }
    
    init(name: String, spentAmount: Amt, idx: Idx) {
        self.name = name
        self.spentAmount = spentAmount
        self.idx = idx
    }
}

extension PersonStruct {
    
    mutating func updateSpentAmt(to amt: Amt) {
        self.spentAmount = amt
    }
    
}

extension PersonStruct: Hashable { }

class DutchResultTest: XCTestCase {
    // Bit Operator Helpers
    func poweredInt(base: Int = 2, exponent: Int) -> Int {
        return Int(pow(Double(base), Double(exponent)))
    }
//    [Amt : [BinIndex]]
    func printBinIndexDictionary(dic: [Amt: [BinIndex]]) {
        for (key, value) in dic {
            let result = key
            var idxes = [[Int]]()
            for eachValue in value {
//                let binStr = String(eachValue, radix: 2)
//                print("amt: \(key), bin: \(binStr)")
                let idxArr = convertBinIntoArr(using: eachValue)
//                print(idxArr)
                idxes.append(idxArr)
            }
            print("value: \(result), idxes: \(idxes)")
        }
    }
    
//    func test_basicTest() {
//        let num1 = 0.1
//        let num2 = 1.1
//        let num3 = 1.2
//
//        XCTAssertEqual(num1 + num2, num3)
//    }
    
//    [(from: BinIndex, to: BinIndex)]
    func printBinResults(res: [(from:BinIndex, to: BinIndex)]) {
        for each in res {
            let from = convertBinIntoArr(using: each.from)
            let to = convertBinIntoArr(using: each.to)
            
            print("from: \(from), to: \(to)")
        }
    }
    
    func binIndexDictionaryStr(dic: [Amt: [BinIndex]]) -> String {
        var resultStr = ""
        for (key, value) in dic {
            let result = key
            var idxes = [[Int]]()
            for eachValue in value {
//                let binStr = String(eachValue, radix: 2)
//                print("amt: \(key), bin: \(binStr)")
                let idxArr = convertBinIntoArr(using: eachValue)
//                print(idxArr)
                idxes.append(idxArr)
            }
            let ret = "value: \(result), idxes: \(idxes)"
            resultStr += ret + "\n"
        }
        
        return resultStr
    }
    
//    [Amt : [Idx]]
    
    
    func getArrCountFromDictionary<T: Hashable>(dic: [T: [T]]) -> Int {
        var amt = 0
        for (_, valueArr) in dic {
            amt += valueArr.count
        }
        return amt
    }
    
    func returnOppositeSignOfArr(arr: [Int]) -> [Int] {
        var ret = arr
        for idx in 0 ..< ret.count {
            ret[idx] = -ret[idx]
        }
        return ret
    }
    
    func printDictionary<T: Hashable>(dic: [T: [Any]]) {
        for (key, value) in dic {
            print("key: \(key), value: \(value))")
        }
    }
    
    func strCandidateDic<T: Hashable>(dic: [T: [Any]]) -> String {
        var result = ""
        for (key, value) in dic {
            let ret = "key: \(key), value: \(value))"
            result += ret + "\n"
        }
        return result
        
    }
    
    func printBin(target: Int, isPositive: Bool = true) {
        let toPrint = String(target, radix: 2)
        let additionalMsg = isPositive ? "plusRemainders:" : "minusRemainders:"
        print(additionalMsg + " " + toPrint)
    }
    // 7 -> [1,2,3]
    func convertBinIntoArr(using binIdx: BinIndex) -> [Idx] {
        
        let binStr = String(binIdx, radix: 2)
        let length = binStr.count
        let startIdx = binStr.startIndex
        let endIdx = binStr.endIndex
        
        var ret = [Int]()
        
        for idx in 0 ..< length {
            let some = binStr.index(startIdx, offsetBy: length - idx - 1, limitedBy: endIdx)
            let char = String(binStr[some!])
            if char == "1" { ret.append(idx)}
//            if char == "0" { ret.append(0)}
        }

        return ret
    }
    
    func test_convertBin() {
//        let ret = convertBinIntoArr(using: 0)
//        XCTAssertEqual(ret, [1])
        let ret2 = convertBinIntoArr(using: 1)
        XCTAssertEqual(ret2, [0])
        let ret3 = convertBinIntoArr(using: 2)
        XCTAssertEqual(ret3, [1])
        let ret4 = convertBinIntoArr(using: 3)
        XCTAssertEqual(ret4, [0,1])
    }
    
    func test_idxSet() {
        let test = convertBinIntoArr(using: 10)
        print("idxSet test: \(test)")
        XCTAssertNotEqual(test, [])
    }
    
    func createBin(using arr: [Int]) -> BinIndex {
        var ret = 0
        for element in arr {
            ret += poweredInt(exponent: element)
        }
        return ret
    }
    
    func test_createBin() {
        let arr = [1,3,4] // 11010 -> 26
        let ret = createBin(using: arr)
        print("testing createBin, ret: \(ret)")

        XCTAssertEqual(ret, 26)
    }
    
    func test_duplicateDigits() {
        let num1 = 0b1010101
        let num2 = 0b0101010
        print("num1: \(num1), num2: \(num2), and operation: \(num1 & num2)")
        XCTAssertEqual(num1 & num2, 0)
    }
    
    func checkIfDuplicate(num1: Int, num2: Int) -> Bool {
        let ret = num1 & num2
        return ret != 0
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
        
        let personDetailsIngre: [PersonTuple] = [
//            PersonStruct(name: <#T##String#>, spentAmount: <#T##Int#>, idx: <#T##Idx#>)
            ("a0", 1, idx: 0), ("a1", 25, idx: 1), ("a2", 7, idx: 2), ("a3", 4, idx: 3),
            ("a4", 7, idx: 4), ("a5", 5, idx: 5), ("a6", 2, idx: 6),
            ("a7", 6, idx: 7),
            ("a8", 17, idx: 8), ("a9", 7, idx: 9), ("a10", 14, idx: 10),("a11", 7, idx: 11),
            ("a12", 6, idx: 12),
            
            ("b0", -54, idx: 0), ("b1", -13, idx: 1), ("b2", -2, idx: 2), ("b3", -1, idx: 3),
            ("b4", -5, idx: 4), ("b5", -7, idx: 5),("b6", -7, idx: 6),("b7", -5, idx: 7),
            ("b8", -2, idx: 8),("b9", -10, idx: 9),("b10", -2, idx: 10)
        ]
        
        var personDetails: [PersonStruct] = personDetailsIngre.map { PersonStruct(name: $0.name, spentAmount: $0.spentAmount, idx: $0.idx)}
        
        let positivePersonDetails: [PersonStruct] = personDetails.filter { $0.spentAmount > 0 }
        let negativePersonDetails: [PersonStruct] = personDetails.filter { $0.spentAmount < 0 }
        
        personDetails = personDetails.filter { $0.spentAmount != 0 }
        
        //  PersonTuple = (name: String, spentAmount: Int, idx: Idx)

        var plusRemainders = 0
        
        var minusRemainders = 0
        
        var positivePersonSet = Set<PersonStruct>()
        var negativePersonSet = Set<PersonStruct>()
        var resultTuples = [ResultTuple]()
        
        for tup in personDetails {
            if tup.spentAmount > 0 {
                positivePersonSet.update(with: tup)
            } else {
                negativePersonSet.update(with: tup)
            }
        }
        

        print("\npositiveTuples: from the beginning")
        for positiveTuple in positivePersonSet.sorted(by: { $0.idx < $1.idx }) {
            print("remaining positiveTuple: idx: \(positiveTuple.idx), amt: \(positiveTuple.spentAmount)")
        }
        
        print("\nnegativeTuples: from the beginning")
        for negativeTuple in negativePersonSet.sorted(by: { $0.idx < $1.idx }) {
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
        var positivesDic: [Amt: [Idx]] = [:]
        var negativesDic: [Amt: [Idx]] = [:]
        
        for personTuple in positivePersonSet.sorted(by: { $0.idx < $1.idx }) {
            if positivesDic[personTuple.spentAmount] != nil {
                positivesDic[personTuple.spentAmount]!.append(personTuple.idx)
                
            } else {
                positivesDic[personTuple.spentAmount] = [personTuple.idx]
            }
        }
        
        for  personTuple in negativePersonSet.sorted(by: { $0.idx < $1.idx }) {
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
        for eachTuple in resultTuples.sorted(by: { $0.from < $1.from }) {
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
        

        let doneMinusIndices = getIndicesSet(from: minusRemainders)
        for idx in doneMinusIndices {
            let target = negativePersonSet.filter { $0.idx == idx }.first!
            negativePersonSet.remove(target)
        }
        
         numOfPlusPeople = positivePersonSet.count
         numOfMinusPeople = negativePersonSet.count
        
        
        
        
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
        
        
        // Printing
        print("\npositiveTuples: after 1:1 match")
        for positiveTuple in positivePersonSet.sorted(by: { $0.idx < $1.idx }) {
            print("remaining positiveTuple: idx: \(positiveTuple.idx), amt: \(positiveTuple.spentAmount)")
        }
        print("dictionary: \(positivesDic)")
        
        print("\nnegativeTuples: after 1:1 match")
        for negativeTuple in negativePersonSet.sorted(by: { $0.idx < $1.idx }) {
            print("remaining negativeTuple: idx: \(negativeTuple.idx), amt: \(negativeTuple.spentAmount)")
        }
        print("dictionary: \(negativesDic)")
        // Printing
        
        
        
        
        // MARK: - 1: N     positives 1 : negatives N
        print("Stage 2, Matching 1: n")
        
        var negativeCandidates = [Int]()
        var positiveCandidates = [Int]()
        
        // 중복 허용.
        for personInfo in negativePersonSet.sorted(by: { $0.idx < $1.idx }) {
            negativeCandidates.append(-personInfo.spentAmount)
        }
        
        for personInfo in positivePersonSet.sorted(by: { $0.idx < $1.idx }) {
            positiveCandidates.append(personInfo.spentAmount)
        }
        
        negativeCandidates.sort(by: >)  // [54, ... 2, 1, 1]
        positiveCandidates.sort(by: <)  // [1,2,3, ... ]
       
        // include updating negativesDic, positivesDic
        for positiveCandidateAmt in positiveCandidates {
            let targetPositiveAmt = positiveCandidateAmt
            
//            func makeTargetNumUsingCombination(candidates: [Int], target: Int) -> [Int], 내부에서 sorting 과정 거침.
            let negativeResultIndexes = makeTargetNumUsingCombination(of: negativeCandidates, target: targetPositiveAmt)
            
//            returnArrayOfValues(of source: [Int], indexes: [Int]) -> [Int]
           
            
            // found pair
            if negativeResultIndexes != [] {
               
                let pPersonIdx = positivesDic[targetPositiveAmt]!.removeFirst() // return first pPersonIdx, remove
                
                let negativesResults = returnArrayOfValues(of: negativeCandidates, indexes: negativeResultIndexes)
                print("found pair! \(negativesResults)")
                
                // unsignedNegativeValue > 0, append matched Negative values to resultTuples with (positive) value
                for unsignedNegativeValue in negativesResults {
                    var nPersonIdx: Idx
                    
                    nPersonIdx = negativesDic[-unsignedNegativeValue]!.removeFirst()
                    
                    if negativesDic[-unsignedNegativeValue]!.count == 0 {
                        negativesDic[-unsignedNegativeValue] = nil
                    }
                    
                    let resultTuple: (ResultTuple) = (from: nPersonIdx, to: pPersonIdx, amount: unsignedNegativeValue)
                    resultTuples.append(resultTuple)
                    
                    
                    let ntargetPerson = negativePersonSet.filter { $0.spentAmount == -unsignedNegativeValue}.first!
                    negativePersonSet.remove(ntargetPerson)
                    
                    let ntargetIdx = ntargetPerson.idx
                    minusRemainders += poweredInt(exponent: ntargetIdx)
                }
                
                let ptargetPerson = positivePersonSet.filter { $0.idx == pPersonIdx}.first!
                positivePersonSet.remove(ptargetPerson)
                
                let ptargetIdx = ptargetPerson.idx
                plusRemainders += poweredInt(exponent: ptargetIdx)
                
                
                if positivesDic[targetPositiveAmt]!.count == 0 {
                    positivesDic[targetPositiveAmt] = nil
                }
                
                // update  NegativeCandidates using negativesDic
                negativeCandidates = [Int]()
                for (amt, _) in negativesDic {
                    negativeCandidates.append(-amt)
                }
                negativeCandidates.sort(by: >)
                
            }
        }
        
        numOfPlusPeople = positivePersonSet.count
        numOfMinusPeople = negativePersonSet.count
        
        
        
        // Printing
        print("\n\nin the end of 1:n")
        
        print("resultTuples: ")
        for eachTuple in resultTuples.sorted(by: { $0.from < $1.from }) {
            print("from idx: \(eachTuple.from), to idx: \(eachTuple.to), amt: \(eachTuple.amount)")
        }


        print("\n\nremainedPeople: ")
//        print("positivesDic: \(positivesDic)")
        
        for eachPerson in positivePersonSet.sorted(by: { $0.idx < $1.idx }) {
            print("person idx: \(eachPerson.idx), amt: \(eachPerson.spentAmount)")
        }
        print("\nnumOfPositives: \(numOfPlusPeople)") // 7
//        print("\nnegativesDic: \(negativesDic)")
        
        for eachPerson in negativePersonSet.sorted(by: { $0.idx < $1.idx }) {
            print("person idx: \(eachPerson.idx), amt: \(eachPerson.spentAmount)")
        }
        print("\nnumOfNegatives: \(numOfMinusPeople)") // 4
        

        printBin(target: plusRemainders)
        printBin(target: minusRemainders, isPositive: false)
        // Printing
        
        
        
        
        
        // MARK: - n : n
        
//        Duplication Check 는 num1 & num2 == 0 이면 겹치는 1 이 없음.
        
        // 사용할 변수들:
        // positivesDic, negativesDic ( [Int: [Idx]] )
        // positivePersonSet, negativePersonSet Set<PersonStruct> , (struct: spentAmount, Idx)
        // numOfPlusPeople, numOfMinusPeople,
        // plusRemainders, minusRemainders ( Int numbers (Binary)
        
        // 사용할 함수들:
        // Combination 을 만들어줄 함수.
        // Duplication Check
        
        // TODO:
        // Combination 을 양쪽에서 번갈아 만들어가며 비교.
        // 만약 어떤 값이라도 매치될 경우, plusRemainders, minusRemainders 와 비교하여 사용된 값이면 해당 값 제외
        // 이미 사용되지 않은 값이면 Combination 에 사용될 Var, plusRemainders, minusRemainders Update,
        //
        
        // 만들어질 변수
        // positiveCombinations: [Int: [Idx]], (idx: binary Int)
        // negativeCombinations: [Int: [Idx]], (idx: binary Int)
        
        var positiveCombinations = [Amt: [BinIndex]]()
        var negativeCombinations = [Amt: [BinIndex]]()
        
        // set for single element
        for (amt, idx) in positivesDic {
//            positiveCombinations[amt] = [poweredInt(exponent: idx)]
            for eachIdx in idx {
                if positiveCombinations[amt] != nil {
                    positiveCombinations[amt]?.append(poweredInt(exponent: eachIdx))
                }
                positiveCombinations[amt] = [poweredInt(exponent: eachIdx)]
            }
        }
        
        for (amt, idx) in negativesDic {
//            negativeCombinations[amt] = [poweredInt(exponent: idx)]
            for eachIdx in idx {
                if negativeCombinations[amt] != nil {
                    negativeCombinations[amt]?.append(poweredInt(exponent: eachIdx))
                }
                negativeCombinations[amt] = [poweredInt(exponent: eachIdx)]
            }
        }
        print("negativeComb initialized")
        print("negativeComb: \(negativeCombinations)")
        

        var numToPickForCombination = 2
        var resultBinIndices = [(from: BinIndex, to: BinIndex)]()
        
        var testCount = 0
        var smallerLoopCount = 0
        var bigLoopCount = 0
        
//        bigLoop: while((numOfPlusPeople != 0 && numOfMinusPeople != 0) && testCount < 10) {
    bigLoop: while(numOfPlusPeople != 0 && numOfMinusPeople != 0) {
        
            bigLoopCount += 1
//            testCount += 1
            
            var higherNumOfPeople = max(numOfPlusPeople, numOfMinusPeople)
            
            smallerLoop: while (numToPickForCombination <= higherNumOfPeople) {
               smallerLoopCount += 1
                // make comb of plusPeople first ( (positive) 1:n (negative) executed before)
                if numOfPlusPeople >= numToPickForCombination {
                    
                    var negativeAmtTargets = [Amt]()
                    for (amt, idxes) in negativeCombinations {
                        let amtsArr = Array(repeating: amt, count: idxes.count)
                        negativeAmtTargets += amtsArr
                    }
                    
                    // make combinations of positive people using candidates, numToPick and compare to targets
                    // then, return unmatched, matched results, remainedCandidates, and matchedTargets
                    let ret = somefunc(numToPick: numToPickForCombination, candidatesDic: positivesDic, targetArr: negativeAmtTargets)
                    
                    let unmatchedCandidatesComb = ret.unmatchedResults // [Amt : [BinIndex]]
                    let remainedCandidates = ret.remainedCandidates //  [Amt : [Idx]]
                    let matchedCandidatesComb = ret.matchedResults //  [Amt : [BinIndex]]
                    let matchedTargets = ret.matchedTargets //  [Amt]
                    
                    // handle unmatchedCandidatesComb
                    for (amt, binIdx) in unmatchedCandidatesComb {
                        if positiveCombinations[amt] != nil {
                            for eachBinIdx in binIdx {
                                positiveCombinations[amt]!.append(eachBinIdx)
                            }
                        } else {
                            positiveCombinations[amt] = binIdx
                        }
                    }
                    
                    // update positivesDic with latest Version ( remainedCandidates)
                    positivesDic = remainedCandidates
                    printDictionary(dic: positivesDic)
//                    numOfPlusPeople = getArrCountFromDictionary(dic: positivesDic) //
                    
                    
                    //  match ( matchedCandidatesComb, and matchedTargets)
                    for matchedTarget in matchedTargets.sorted(by: { $0 < $1 }) {
                        
                        // 둘 갯수에 차이가 있을 수 있음.  두 BinIndices 중 적은 갯수만큼만 ResultBinInDices 에 담기.
                        guard let positiveBinIndices = matchedCandidatesComb[matchedTarget], // [BinIndex]
                              let negativeBinIndices = negativeCombinations[-matchedTarget] else { fatalError() }
                        
                        // negativeCombinations: [0, 1, 2, .. ]
                        let numOfMatchedTargets = min(positiveBinIndices.count, negativeBinIndices.count)
                    
                        for idx in 0 ..< numOfMatchedTargets {
//                            let negativeBinIndex = poweredInt(exponent: negativeBinIndices[idx])
                            let negativeBinIndex = negativeBinIndices[idx]
                            resultBinIndices.append((from: negativeBinIndex, to: positiveBinIndices[idx]))
                            print("resultBinIndices changed! \(resultBinIndices), \(#line)")
                            print("negagaveBinIndices: \(negativeBinIndices), at idx \(idx) : \(negativeBinIndices[idx])")
                            print("positiveBinDicies:\(positiveBinIndices[idx])")
                            printBinResults(res: resultBinIndices)
                            guard let usedIndices = negativeCombinations[-matchedTarget],
                                  let firstIndices = usedIndices.first else { fatalError() } // BinIndex
                            
                            // um.. 하나하나 찾아야 하는건가..??
                            // dictionary 보단 candidate 쓰는게 더 .. 나아 보인다.
                            // 여기선 candidate 사용하고 dic 필요할 땐 candidate -> dic 생성? 음... 너무 복잡해짐..;;
                            let corrIndices = convertBinIntoArr(using: firstIndices)
                            
                            
                            
                            // dictionary.. [] 라서 하나하나 찾아봐야 할 것 같은데.....
                            // 아니면, 통째로 업데이트!
                            
                            for (key, eachNegativeIndices) in negativesDic {
                                
                                let originalIndicesSet = Set(eachNegativeIndices)
                                
                                var doesContainValue = false
                                var matchedIndices = Set<Idx>()
                                
                                for corrIndex in corrIndices {
                                    if originalIndicesSet.contains(corrIndex) {
                                        doesContainValue = true
                                        matchedIndices.insert(corrIndex)
                                    }
                                }
                                
                                if doesContainValue {
                                    let newIdxArr = originalIndicesSet.subtracting(matchedIndices)
                                    negativesDic[key] = Array(newIdxArr)
                                }
                            }
                            
                            
                            if negativeCombinations[-matchedTarget]!.count > 1 {
                                negativeCombinations[-matchedTarget]!.removeFirst() // [Amt : [BinIndex]]
                            } else {
                                negativeCombinations[-matchedTarget] = nil
                            }
                        }
                    }
                }
                
                // TODO: update negativeCandidates. How ? using.. negativeCombinations!
                print("end of postives loop ")
                
                // TODO: Repeat same process for negative People
                // TODO: Before that, review if any missing part exist.
                
                if numOfMinusPeople >= numToPickForCombination {
                    var positiveAmtTargets = [Amt]()
                    for (amt, idxes) in positiveCombinations {
                        let amtsArr = Array(repeating: amt, count: idxes.count)
                        positiveAmtTargets += amtsArr
                    }

                    let ret = somefunc(numToPick: numToPickForCombination, candidatesDic: negativesDic, targetArr: positiveAmtTargets)
                    
                    let unmatchedCandidatesComb = ret.unmatchedResults // [Amt : [BinIndex]]
                    let remainedCandidates = ret.remainedCandidates //  [Amt : [Idx]]
                    let matchedCandidatesComb = ret.matchedResults //  [Amt : [BinIndex]]
                    let matchedTargets = ret.matchedTargets //  [Amt]
                    
                    for (amt, binIdx) in unmatchedCandidatesComb {
                        if negativeCombinations[amt] != nil {
                            for eachBinIdx in binIdx {
                                negativeCombinations[amt]!.append(eachBinIdx)
                            }
                        } else {
                            negativeCombinations[amt] = binIdx
                        }
                    }
                    
                    negativesDic = remainedCandidates
                    numOfMinusPeople = getArrCountFromDictionary(dic: negativesDic)
                    // TODO: 부호 다시 한번 살펴보기.
                    for matchedTarget in matchedTargets.sorted(by: { $0 < $1 }) {
                        guard let negativeBinIndices = matchedCandidatesComb[matchedTarget],
                              let positiveBinIndices = positiveCombinations[-matchedTarget] else { fatalError() }
                        
                        let numOfMatchedTargets = min(positiveBinIndices.count, negativeBinIndices.count)
                        
                        for idx in 0 ..< numOfMatchedTargets {
                            print("some error here, \(negativeBinIndices[idx])")
//                            let negativeBinIndex = poweredInt(exponent: negativeBinIndices[idx])
                            let negativeBinIndex = negativeBinIndices[idx]
                            resultBinIndices.append((from: negativeBinIndex, to: positiveBinIndices[idx]))
                            
                            guard let usedIndices = positiveCombinations[-matchedTarget],
                                  let firstIndices = usedIndices.first else { fatalError() } // BinIndex
                            
                            let corrIndices = convertBinIntoArr(using: firstIndices)
                            
                            for (key, eachPositiveIndices) in positivesDic {
                                let originalIndicesSet = Set(eachPositiveIndices)
                                
                                var doesContainValue = false
                                var matchedIndices = Set<Idx>()
                                
                                for corrIndex in corrIndices {
                                    if originalIndicesSet.contains(corrIndex) {
                                        doesContainValue = true
                                        matchedIndices.insert(corrIndex)
                                    }
                                }
                                
                                if doesContainValue {
                                    let newIdxArr = originalIndicesSet.subtracting(matchedIndices)
                                    positivesDic[key] = Array(newIdxArr)
                                }
                            }
                            
                            
                            if positiveCombinations[-matchedTarget]!.count > 1 {
                                positiveCombinations[-matchedTarget]!.removeFirst()
                            } else {
                                positiveCombinations[-matchedTarget] = nil
                            }
                        }
                    }
//                    print("                print("end of postives loop ")")
                    print("end of negatives loop ")
                }
                
                numToPickForCombination += 1
                
                numOfPlusPeople = getArrCountFromDictionary(dic: positivesDic)
                numOfMinusPeople = getArrCountFromDictionary(dic: negativesDic)
                
//                higherNumOfPeople = max(numOfPlusPeople, numOfMinusPeople)
                
                print("resultBinIndices:")
                printBinResults(res: resultBinIndices)
                print("smaller loop is running, smallerLoop: \(smallerLoopCount)")
                print("numOfPlusPeople: \(numOfPlusPeople), numOfMinusPeople:\(numOfMinusPeople)")
            }
            print("big loop is running, bigLoop: \(bigLoopCount)")
        }
        
        // TODO: update ResultTuple using resultBinIndices
        // 음.. 각 Idx 들.. 많이 줘야하는 애들부터 많이 받아야하는애들한테 보내기.
        // Amt 는 어떻게 알지 ?? ㅠㅠㅠㅠㅠ

        //       resultBinIndices          ->  resultTuples
//        [(from: BinIndex, to: BinIndex)] -> [ResultTuple]  ResultTuple: (from: Idx, to: Idx, amount: Int)
        // idx 에 대한 정보는 Dic 에.. 있나 ?? 업데이트 했을텐데 ?? 처음 것에서 받아오기.
        
        // personDetails [PersonStruct] 쓰면 될 것 같은데 ??
        // 먼저, 음...
        
        
        // TODO: update ResultTuple using resultBinIndices
        
        for eachBinCouple in resultBinIndices {
            
            let senderIdxBin = eachBinCouple.from
            let receiverIdxBin = eachBinCouple.to
            
            // convert Bin idx to idx array
            let sendersIdx = convertBinIntoArr(using: senderIdxBin)
            let receiversIdx = convertBinIntoArr(using: receiverIdxBin)
            
            
            // -------------  Prepare senders, receivers (with idx and amt) --------------------
            var sendersStruct = [PersonStruct]()
            for senderIdx in sendersIdx {
//                guard let matchedPerson = personDetails.filter({ $0.idx == senderIdx}).first else { fatalError() }
                guard let matchedPerson = negativePersonDetails.filter({ $0.idx == senderIdx}).first else { fatalError() }
                let spentAmt = matchedPerson.spentAmount
                let senderPerson = PersonStruct(idx: senderIdx, spentAmount: spentAmt)
                sendersStruct.append(senderPerson)
            }
            
            // convert sign ( - -> + )
            print("prev senders: \(sendersStruct)")
            sendersStruct = sendersStruct.map { (personStruct) -> PersonStruct in
                let newPersonStruct = PersonStruct(idx: personStruct.idx, spentAmount: -personStruct.spentAmount)
                return newPersonStruct
            }
            print("after senders: \(sendersStruct)")
            sendersStruct.sort(by: {$0.spentAmount > $1.spentAmount })
            
            
            var receiversStruct = [PersonStruct]()
            for receiverIdx in receiversIdx {
//                guard let matchedPerson = personDetails.filter({ $0.idx == receiverIdx}).first else { fatalError() }
                guard let matchedPerson = positivePersonDetails.filter({ $0.idx == receiverIdx}).first else { fatalError() }
                let spentAmt = matchedPerson.spentAmount
                let receiverPerson = PersonStruct(idx: receiverIdx, spentAmount: spentAmt)
                receiversStruct.append(receiverPerson)
            }
            
            receiversStruct.sort(by: { $0.spentAmount > $1.spentAmount }) // decending order
            // ----------------------------------------------------------------------------------
            


            // 부호 조심해야함. sender: - ,  receiver: +
            //  -------- make resultTuple with each sendersStruct and receiversStruct -----------------
            print("current senders: \(sendersStruct)")
            print("current receivers: \(receiversStruct)")
            while (sendersStruct.count != 0) {
                if var sender = sendersStruct.first, var receiver = receiversStruct.first {
                        
                    if sender.spentAmount == receiver.spentAmount {
                        let amt = sender.spentAmount
                        let resultTuple = ResultTuple(from: sender.idx, to: receiver.idx, amount: amt)
                       print("appended resultTuple: \(resultTuple)")
                        resultTuples.append(resultTuple)
                        sendersStruct.removeFirst()
                        receiversStruct.removeFirst()
                    }
                    else if sender.spentAmount > receiver.spentAmount {
                        let receiverAmt = receiver.spentAmount
                        
                        let resultTuple = ResultTuple(from: sender.idx, to: receiver.idx, amount: receiverAmt)
                        print("appended resultTuple: \(resultTuple)")
                        resultTuples.append(resultTuple)
                        
                        let updatedSpentAmt = sender.spentAmount - receiver.spentAmount
                        sender.updateSpentAmt(to: updatedSpentAmt)
                        
                        sendersStruct[0] = sender
                        receiversStruct.removeFirst()
                    
                    }
                    else if sender.spentAmount < receiver.spentAmount {
                        let senderAmt = sender.spentAmount
                        
                        let resultTuple = ResultTuple(from: sender.idx, to: receiver.idx, amount: senderAmt)
                        resultTuples.append(resultTuple)
                        print("appended resultTuple: \(resultTuple)")
                        let updatedSpentAmt = receiver.spentAmount - sender.spentAmount
                        receiver.updateSpentAmt(to: updatedSpentAmt)
                        
                        receiversStruct[0] = receiver
                        sendersStruct.removeFirst()
                    }
                }
            }
            // ---------------------------------------------------------------------------------------------
        }
        
        print("end of n:n operation \n\n")
        
        
        
        
        

        
        // MARK: - 하나 남았을 때 처리
        
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
        
    /// [1,2,3,4,5] -> [[1, 2], [1, 3], [1, 4], [1, 5], [2, 3], [2, 4], [2, 5], [3, 4], [3, 5], [4, 5]]
//    func combosWithoutDuplication<T: Hashable>(elements: Array<T>, k: Int) -> [[T]] {
    func combosWithoutDuplication(numOfElements: Int, numToPick: Int) -> [[Int]] {
        
        var elements = Array(repeating: 0, count: numOfElements)
        
        for idx in 0 ..< numOfElements {
            elements[idx] = idx
        }
        
        let comboResult = combos(elements: ArraySlice(elements), k: numToPick)
        
        var ret = [[Int]]()
        for eachArr in comboResult {
            let set = Set(eachArr)
            if set.count == numToPick {
                ret.append(eachArr)
            }
        }
        
//        print("combos flag, ret: \(ret)")
        return ret
    }
    
    func createCombination(using array: [Int], numToPick: Int) -> [Int: [Int]] {
        
// arr = [0,1,2, ... array.count-1]
        var arr = Array(repeating: 0, count: array.count)
        
        for (idx, _) in array.enumerated() {
            arr[idx] = idx
        }
//        var arr = array
        
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
            result[unitResult] = eachCombo
        }
        

        return result
    }
    
    func test_createCombination() {
//        let arr = [1,2,3,4,5]
//        let ret = createCombination(using: arr, numToPick: 2)
//        let ret = combosWithoutDuplication(elements: arr, k: 2)
        let ret = combosWithoutDuplication(numOfElements: 5, numToPick: 2)
        print("combination test, ret: \(ret)")
        
        for a in ret.sorted { $0.first! < $1.first!} {
            print("result: \(a)")
        }
        
        XCTAssertNotEqual(ret, [[]])
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
    
    func returnArrayOfValues(of source: [Int], indexes: [Int]) -> [Int]{
        
        var result = [Int]()
        for index in indexes {
            result.append(source[index])
        }
        return result
    }
    
    func returnArrayOfOptionalValues(of source: [Int?], indexes: [Int]) -> [Int]{
        
        var result = [Int]()
        for index in indexes {
            result.append(source[index]!)
        }
        return result
    }
    
    
    
    func hasOneElement<T: Hashable>(dic: [T:[T]], input: T) -> Bool? {
//        if dic[input
        if dic[input] != nil {
            return dic[input]!.count == 1
        } else {
            return nil
        }
    }
    
    
    
}


extension DutchResultTest {
    // sortedCandidates
    /// return Indexes of candidates in [Int]
    func makeTargetNumUsingCombination(of candidates: [Int], target: Int) -> [Int] {
        
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
//                getResult(target: [Int], indexes: [Int]) -> Int
                let result = returnSum(of: sortedCandidates, in: selectedIndexes)
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
    

    func somefunc(numToPick: Int, candidatesDic: [Amt: [Idx]], targetArr: [Amt]) ->
    (unmatchedResults: [Amt: [BinIndex]], matchedResults: [Amt: [BinIndex]],remainedCandidates: [Amt: [Idx]], matchedTargets: [Amt]) {
        print("someFunc flag 1, input: \nnumToPick: \(numToPick), \ncandidatesDic: \(candidatesDic), \ntargetArr: \(targetArr)\n\n")
        
        var candidatesDic = candidatesDic
//        var targetArr = targetArr // convert sign
        var targetArr = returnOppositeSignOfArr(arr: targetArr)
        var matchedResults = [Amt:[BinIndex]]()
        
        var newResults = [Amt: [BinIndex]]()
        var matchedTargets = [Amt]()
        // 실시간으로 하나씩만 업데이트.
        var allCandidates = [(Amt, Idx)?]()
        
        for (amt, numOfIdx) in candidatesDic.sorted(by: {$0.key < $1.key }) {
            for idx in 0 ..< numOfIdx.count {
                allCandidates.append((amt, numOfIdx[idx]))
            }
        }
        
        var length = candidatesDic.map { $0.value.count }.reduce(0, +) // num of all candidates
        
        let combinations = combosWithoutDuplication(numOfElements: length, numToPick: numToPick) // length 개의 Int Arr 로 comb 생성 [1,2,3..]
        print("createdCombinations: \(combinations)")
        var valueOnlyCandidates: [Amt?] = allCandidates.map { $0!.0 } // $0.amt
        combLoop: for eachCombo in combinations {
//            let valueOnlyCandidates = allCandidates.map { $0.0 } // $0.amt
            valueOnlyCandidates = allCandidates.map { $0?.0 }
            let targetArrInSet = Set(targetArr)
            // combination 은 항상 같지만, valueOnlyCandidates 는 줄어들 수 있음 ;; 어떡하지..??
            print("eachCombo: \(eachCombo), valueOnlyCandidates: \(valueOnlyCandidates)")
//            let eachSumOfCombo = returnSum(of: valueOnlyCandidates, in: eachCombo)
            guard let eachSumOfCombo = returnOptionalSum(of: valueOnlyCandidates, in: eachCombo) else { continue combLoop }
//            print("eachSumOfCombo: \(eachSumOfCombo)")
//            let selectedCandidateValues = returnArrayOfValues(of: valueOnlyCandidates, indexes: eachCombo)
            let selectedCandidateValues = returnArrayOfOptionalValues(of: valueOnlyCandidates, indexes: eachCombo)
            print("selectedCandidateValues: \(selectedCandidateValues)")
            
            // matched!
            if targetArrInSet.contains(eachSumOfCombo) {
               
                print("matched! \(eachSumOfCombo)")
                for selectedCandidateValue in selectedCandidateValues {
                    
                    if candidatesDic[selectedCandidateValue]!.count == 1 {
                        candidatesDic[selectedCandidateValue] = nil
                    } else {
                        candidatesDic[selectedCandidateValue]!.removeFirst()
                    }
                    
//                    let idx = valueOnlyCandidates.firstIndex(of: selectedCandidateValue)
//                    allCandidates.remove(at: idx!)
//                    allCandidates[idx!] = nil
                }
                
                guard let targetIdx = targetArr.firstIndex(of: eachSumOfCombo) else { fatalError() }
                let matchedTarget = targetArr.remove(at: targetIdx)
                matchedTargets.append( matchedTarget )
                
                var matchedIndices = [Idx]()
                print("allCandidates: \(allCandidates), eachCombo: \(eachCombo)")
                for eachComboIdx in eachCombo {
                    print("current ComboIdx: \(eachComboIdx)")
                    let candidateIdx = allCandidates[eachComboIdx]!.1
                    matchedIndices.append(candidateIdx)
                    allCandidates[eachComboIdx] = nil
                }
                
                let binaryIndices = createBin(using: matchedIndices)
                if matchedResults[eachSumOfCombo] != nil {
                    matchedResults[eachSumOfCombo]!.append(binaryIndices)
                } else {
                    matchedResults[eachSumOfCombo] = [binaryIndices]
                }
            }
            
            // target not found
            else {
                print("couldn't find target \(eachSumOfCombo)")
                // append selectedCandidates into newResult
                var sumOfSelectedIdx: Idx = 0
                print("current allCandidates: \(allCandidates)")
                print("eachCombo: \(eachCombo)")
                for comboIdx in eachCombo { // eachCombo: [0,1], [0,2], ...
                    let candidate = allCandidates[comboIdx]!
//                    let candidate = valueOnlyCandidates[comboIdx]!
//                    sumOfSelectedIdx += candidate.1
                    sumOfSelectedIdx += poweredInt(exponent: candidate.1)
                }
                
                let selectedBinIndex: BinIndex = sumOfSelectedIdx // candidate.idx
                
                if newResults[eachSumOfCombo] != nil {
                    newResults[eachSumOfCombo]!.append(selectedBinIndex)
                } else {
                    newResults[eachSumOfCombo] = [selectedBinIndex]
                }
                print("newResults updated to ")
                printBinIndexDictionary(dic: newResults)
            }
        }
        
        // updateNewResult after comparing with candidates (using bin operators)
        
        var unusedBinarySum = Set<Idx>()
        
        for (_, indices) in candidatesDic {
            for idx in indices {
                unusedBinarySum.insert(idx)
            }
        }
                
        for (amt, resultBin) in newResults {
            for eachResultBin in resultBin {
                let usedIdxes = convertBinIntoArr(using: eachResultBin)
                let usedIdxesSet = Set(usedIdxes)
                let subtraction = usedIdxesSet.subtracting(unusedBinarySum)
                if subtraction.count != 0 {
                    newResults[amt] = nil
                }
            }
        }

        // newResults: used: 1 [Amt: [BinIndex]]
        // unmatchedResults, matchedResults 이상함.
//        print("someFunc flag 2, output: \nunmatchedResults: \(newResults), \nmatchedResults: \(matchedResults), \nremainedCandidates: \(candidatesDic), \nmatchedTargets: \(matchedTargets)\n\n\n")
        
        print("\n\nsomeFunc flag 2, output: ")
        
        print("unmatchedResults: \n\(binIndexDictionaryStr(dic: newResults))")
        print("matchedResults: \n\(binIndexDictionaryStr(dic: matchedResults))")
        print("remainedCandidates: \n\(strCandidateDic(dic: candidatesDic))")
        print("matchedTargets: \(matchedTargets)")
        return (unmatchedResults: newResults, matchedResults: matchedResults,remainedCandidates: candidatesDic, matchedTargets: matchedTargets)
    }

    
    func test_combinationSum() {
        
//        let result = combinationSum(candidates: [1,2,3,4,5,6], target: 6)
        let result = makeTargetNumUsingCombination(of : [3,3], target: 6)
        print("final result: \(result)")
        XCTAssertNotEqual(result, [10])
//        XCTAssertEqual(result, [0])
    }
    
    func returnSum(of target: [Int], in indexes: [Int]) -> Int {
        
        var result = 0
        for index in indexes {
            result += target[index]
        }
        return result
    }
    
    func returnOptionalSum(of target: [Int?], in indexes: [Int]) -> Int? {
        
        var result = 0
        for idx in indexes {
            if let validTarget = target[idx] {
                result += validTarget
            } else {
                return nil
            }
        }
        return result
    }
    
    
    func backtrack(selectedIndexes: [Int], currentIndex: Int, candidates: [Int], target: Int ) {
        
    }
}


extension DutchResultTest {
    
    func cutDigits(amt: Double, digitLocationToCut: Int) -> Double {
        // if digitLocationToCut == 1 (일의 자리 버림)
        // 123.45 -> 12345 -> (12345 / 1000) * 1000 -> 12000 -> 120
        // amt: 123.45
        // multipledAmt: 12345
        // digitLocationToCut: 1
        // multipliedDigit: 100
        
        let multipliedAmt = Int(amt * 100)
        let multipliedDigit = poweredInt(base: 10, exponent: digitLocationToCut) * 100
       
        // 120
        print("multipliedDigit: \(multipliedDigit)")
        let cutAmt = (multipliedAmt / multipliedDigit) * multipliedDigit //
        print("cutAmt: \(cutAmt)")
        let dividedAmt = Double(cutAmt) / Double(100)
        return Double(dividedAmt)
    }
    
    func test_validDigits() {
        
        let amt = 123.45
        let digitToCut = 1
        
        let cutDigit = cutDigits(amt: amt, digitLocationToCut: digitToCut)
        XCTAssertEqual(cutDigit, Double(120))
    }
    
    func test_max() {
        let someInt = [1,1]
        let max = someInt.max()
        XCTAssertEqual(max, 1)
    }
}