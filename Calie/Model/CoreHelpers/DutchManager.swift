//
//  DutchpayManager.swift
//  Calie
//
//  Created by Mac mini on 2022/07/12.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import Foundation
import CoreData


struct DutchManager {
    let mainContext: NSManagedObjectContext

    init(mainContext: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.mainContext = mainContext
    }
}



// MARK:  - Gathering Helpers
extension DutchManager {
    
    @discardableResult
    func createGathering(title: String) -> Gathering {
        let gathering = Gathering(context: mainContext)
        
        gathering.title = title
        gathering.createdAt = Date()
        do {
            try mainContext.save()
            return gathering
        } catch let error {
            print("Failed to create: \(error)")
            fatalError("failed to create Gathering")
        }
    }
    
    @discardableResult
    func createGathering(title: String, people: [Person]) -> Gathering {
        let gathering = Gathering(context: mainContext)
        
        gathering.people = Set(people)
        gathering.isOnWorking = true
        gathering.title = title
        gathering.createdAt = Date()
        do {
            try mainContext.save()
            return gathering
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }

    func fetchGatherings() -> [Gathering] {
        
        let fetchRequest = NSFetchRequest<Gathering>(entityName: String.EntityName.Gathering)
        // inverse order
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: .GatheringKeys.createdAt, ascending: false)]
        
        do {
            let gatherings = try mainContext.fetch(fetchRequest)
            return gatherings
        } catch let error {
            fatalError("fail to get gatherings, \(error.localizedDescription)")
        }
    }

    
    func fetchGathering(_ option: GatheringFetchingEnum) -> Gathering? {
        let fetchRequest = NSFetchRequest<Gathering>(entityName: String.EntityName.Gathering)
        fetchRequest.fetchLimit = 1
        
        switch option {
        case .latest:
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: .GatheringKeys.createdAt, ascending: false)]
            
        case .title(let name):
            fetchRequest.predicate = NSPredicate(format: "\(String.GatheringKeys.title) == %@", name)
        }
        
        do {
            let gatherings = try mainContext.fetch(fetchRequest)
            return gatherings.first
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }

    
    func update() {
        mainContext.saveCoreData()
    }

    func deleteGathering(gathering: Gathering, completion: @escaping () -> Void) {
        mainContext.delete(gathering)

        update()
        completion()
        
    }
    
    
    /// dutchUnit added with new People -> add personDetails to existing dutchUnits  & update gathering's people
    func addDutchUnit(of dutchUnit: DutchUnit, to gathering: Gathering) {

        let peopleInUnit = Set(dutchUnit.personDetails.map { $0.person! })
        
        let originalPeople = gathering.people
        //  인원이 감소하는 경우는? 없음.
        let appendedPeople = peopleInUnit.subtracting(originalPeople)
        
        for eachPerson in appendedPeople {
            gathering.people.update(with: eachPerson)
            
            let appendedDetail = createPersonDetail(person: eachPerson, isAttended: false, spentAmount: 0)
            
            for eachDutchUnit in gathering.dutchUnits.sorted() {
                eachDutchUnit.personDetails.update(with: appendedDetail)
            }
        }
        
        
        gathering.dutchUnits.update(with: dutchUnit)
        
        update()
    }
    
// 모든 DutchUnit 의 SpentAmount 와 PersonDetails 의 합이 같다고 가정.
    func getRelativeTobePaidAmountForEachPerson(from gathering: Gathering) -> [Double] {

//        [0 0 0 0 0 .. ]
        var result = Array(repeating: 0.0, count: gathering.people.count)
        print("\ngetOverallResult, numOfElements:\(result.count)")

        for eachUnit in gathering.dutchUnits.sorted() {
            let eachResult = getRelativeTobePaidAmount(from: eachUnit)

            for (idx, element) in eachResult.enumerated() {
                result[idx] += element
            }
        }
        
        print("overall Result: \(result)")
        return result
    }
    
    // 이게 반드시 Int 이어야하나 ? 대부분의 경우, Yes.
//    func getRelativeTobePaidAmount(from dutchUnit: DutchUnit) -> [Double] {
    
    /// 각 dutchUnit 에 대한 연산, 나머지 처리 되어있음.
    func getRelativeTobePaidAmount(from dutchUnit: DutchUnit) -> [Double] {
        
        // 각 amt 가 소숫점이 있는지 확인해야함
        // 어떤 자릿수에서 끊을 것인지 알아야함
        
//        let isUsingFloatingPoint = true // 나중에 사용하기!
        
        // TODO: fetch from UserDefault
        let digitToCut = 1
        
        var totalAmount: Double
        
        if dutchUnit.isAmountEqual {
            totalAmount = dutchUnit.spentAmount
        } else {
            let totalSpentAmount = dutchUnit.personDetails.map { $0.spentAmount }.reduce(0, +)
            totalAmount = totalSpentAmount
        }
        
        // 불참 인원은 Average 계산에서 제외.
//        let average = getAverage(totalAmount: totalAmount, numOfPeople: dutchUnit.personDetails.filter { $0.isAttended }.count)
        
        let participants = dutchUnit.personDetails.filter {$0.isAttended}.count
        
        let averageAmt = totalAmount / Double(participants)
        
        // 불참인 경우 -1 대입 ( flag )
        let paidAmtArr = dutchUnit.personDetails.sorted().map { $0.isAttended ? $0.spentAmount : -1 }
       


        // TODO: 여기 연산만 현재는 손보면 됨.
        // 불참인 경우 계산 없이 0, 그 외: 본인 지불한 비용 - Average (개인당 지불해야하는 비용)



        var rawResult = paidAmtArr.map { $0 < 0 ? 0 : dropDigits(amt: $0 - averageAmt, digitLocationToCut: digitToCut) }
        
        let remaining = rawResult.reduce(0, +) // 상대 금액의 차이
        
//        if let targetIdx = rawResult.firstIndex(where: { $0 > 0 }) {
        if let targetAmt = rawResult.filter({ $0 > 0}).max(), let targetIdx = rawResult.firstIndex(where: {$0 == targetAmt}) {
//             rawResult[targetIdx] += targetAmt + remaining
            rawResult[targetIdx] = targetAmt - remaining
        }
        
        print("relative flag, dutchUnit info: ")
        for personDetail in dutchUnit.personDetails {
            print("name: \(personDetail.person!.name), isAttended: \(personDetail.isAttended), spentAmt: \(personDetail.spentAmount)")
        }
        print("relative flag, result: \(rawResult)")
        
        
        print("getRelativeTobePaidAmount result: \(rawResult)\n\n")
        return rawResult
    }
    
    /// digitLocationToCut: 1 -> 일의 자리 버림. 0 -> 소숫점 버림.
    func dropDigits(amt: Double, digitLocationToCut: Int) -> Double {
        // if digitLocationToCut == 1 (일의 자리 버림)
        // 123.45 -> 12345 -> (12345 / 1000) * 1000 -> 12000 -> 120
        // amt: 123.45
        // multipledAmt: 12345
        // digitLocationToCut: 1
        // multipliedDigit: 100
        let multipliedAmt = Int(amt * 100)
        let multipliedDigit = poweredInt(base: 10, exponent: digitLocationToCut) * 100
       
        // 120
        let cutAmt = (multipliedAmt / multipliedDigit) * multipliedDigit //
        let dividedResult = Double(cutAmt) / Double(100)
        
        return dividedResult
    }
    
    
    func getAverage(totalAmount: Double, numOfPeople: Int) -> Double {
        return totalAmount / Double(numOfPeople)
    }
    
    // [이름, 받아야 하는 금액, 참여 항목]
    func createOverallInfo(gathering: Gathering) -> [OverallPersonInfo] {
//        if gathering.people.contains(person) == false { fatalError("no target person found") }
        var amtToPay = Array(repeating: 0.0, count: gathering.people.count)
        print("\ngetOverallResult, numOfElements:\(amtToPay.count)")

        // FIXME: - 총 지출비용으로 하는게 나아.
        // TODO: 음.. 각 Cell 별로 Detail 한 내용도 알려줄까 ??
        
        for eachUnit in gathering.dutchUnits.sorted() {
            let eachResult = getRelativeTobePaidAmount(from: eachUnit)

            for (idx, element) in eachResult.enumerated() {
                amtToPay[idx] += element
            }
        }
        
        print("overall Result: \(amtToPay)")
        
        let people = gathering.sortedPeople
        let peopleNames = people.map { $0.name }
        
        
        var attendedPlacesForPerson: [String] = []
        
        for idx in 0 ..< people.count {
            var attendedPlaces: [String] = []
            for eachUnit in gathering.dutchUnits.sorted() {
                let targetDetail = eachUnit.personDetails.sorted()[idx]
                if targetDetail.isAttended == true {
                    attendedPlaces.append(eachUnit.placeName)
                }
            }
            let attendedPlacesInLine = attendedPlaces.joined(separator: ", ")
            attendedPlacesForPerson.append(attendedPlacesInLine)
        }
        
        var result = [OverallPersonInfo]()
        
        for idx in 0 ..< people.count {
            let each: OverallPersonInfo = (peopleNames[idx], amtToPay[idx], attendedPlacesForPerson[idx])
            print("overallResult: \(each)")
            result.append(each)
        }
        
        return result
    }
    
    // FIXME: What's the meaning of 'sum' ??
    func createPersonPayInfos(gathering: Gathering) -> [PersonPaymentInfo] {
        
        var amtToPay = Array(repeating: 0.0, count: gathering.people.count)
        print("\ngetOverallResult, numOfElements:\(amtToPay.count)")
        let names = gathering.sortedPeople.map { $0.name }
        
        var spentAmount = Array(repeating: 0.0, count: gathering.people.count)
        var sum = Array(repeating: 0.0, count: gathering.people.count)
        
        // FIXME: - 총 지출비용으로 하는게 나아.
        // TODO: 음.. 각 Cell 별로 Detail 한 내용도 알려줄까 ??
        
        for eachUnit in gathering.dutchUnits.sorted() {
            let eachResult = getRelativeTobePaidAmount(from: eachUnit)

            for (idx, element) in eachResult.enumerated() {
                amtToPay[idx] += element
            }
            
            let spentAmountsForUnit = eachUnit.personDetails.sorted().map { $0.spentAmount }
            
            for idx in 0 ..< spentAmountsForUnit.count {
                spentAmount[idx] += spentAmountsForUnit[idx]
                print("paymentFlag 1, idx:\(idx), spentAmountsForUnit:\(spentAmountsForUnit[idx])")
            }
        }
        
        // 부호 변환 (의미 혼동 방지)
//        amtToPay = -amtToPay
//        for idx in 0 ..< amtToPay.count {
//            amtToPay[idx] = -amtToPay[idx]
//        }
        
        var result = [PersonPaymentInfo]()
        
        for idx in 0 ..< amtToPay.count {
            sum[idx] = amtToPay[idx] + spentAmount[idx]
            let eachResult: PersonPaymentInfo = (name: names[idx], paidAmt: spentAmount[idx], toGet: amtToPay[idx], sum: sum[idx])
            result.append(eachResult)
        }
        
        for person in gathering.sortedPeople {
            print("personName: \(person.name), order: \(person.order)")
        }
        
        print("result of personPaymentInfo: \(result)")
        
        return result
    }
}




extension DutchManager {
    
    enum GatheringFetchingEnum {
        case latest
        case title(String)
    }
}


// MARK: - DutchUnit Helper
extension DutchManager {
    func createDutchUnit(spentTo placeName: String,
                         spentAmount: Double,
                         personDetails: [PersonDetail],
                         spentDate: Date = Date()) -> DutchUnit {
        
        let dutchUnit = DutchUnit(context: mainContext)
        
        dutchUnit.placeName = placeName
        
        

        dutchUnit.spentAmount = spentAmount
        dutchUnit.personDetails = Set(personDetails)
        let totalPrice = personDetails.map { $0.spentAmount }.reduce(0) { partialResult, element in
            return partialResult + element
        }
        
        dutchUnit.isAmountEqual = totalPrice == spentAmount
        
        dutchUnit.spentDate = spentDate
        
        dutchUnit.id = UUID()
        
        do {
            try mainContext.save()
            return dutchUnit
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    @discardableResult
    func updateDutchUnit(target dutchUnit: DutchUnit,
                         spentTo placeName: String?,
                         spentAmount: Double,
                         personDetails: [PersonDetail],
                         spentDate: Date?) -> DutchUnit {

//        dutchUnit.placeName = placeName
        
        dutchUnit.spentAmount = spentAmount
        dutchUnit.personDetails = Set(personDetails)

        let totalPrice = personDetails.map { $0.spentAmount }.reduce(0) { partialResult, element in
            return partialResult + element
        }

        dutchUnit.isAmountEqual = totalPrice == spentAmount

//        dutchUnit.spentDate = spentDate
        if spentDate != nil {
            dutchUnit.spentDate = spentDate!
        }

        if placeName != nil {
            dutchUnit.placeName = placeName!
        }
        
        do {
            try mainContext.save()
            return dutchUnit
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
}


// MARK: -PersonDetail
extension DutchManager {
    
    @discardableResult
    func createPersonDetail(person: Person,
                     isAttended: Bool = true,
                     spentAmount: Double = 0) -> PersonDetail {
        
        let personDetail = PersonDetail(context: mainContext)
        
        personDetail.person = person
        personDetail.isAttended = isAttended
        personDetail.spentAmount = spentAmount
        
        do {
            try mainContext.save()
            return personDetail
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
}

// MARK: - People Helper
extension DutchManager {
    @discardableResult
//    func createPerson(name: String, prevPeople: [Person]? = nil, givenIndex: Int = 100 ) -> Person {
    func addPersonToGathering(name: String, currentGathering: Gathering ) -> Person {
        
         let person = Person(context: mainContext)
         
         person.name = name
        person.id = UUID()
        
        let numOfPeople = currentGathering.people.count
        person.order = Int64(numOfPeople)
        
        currentGathering.people.insert(person)
        
        if currentGathering.dutchUnits.count == 0 { return person }
        
        do {
             try mainContext.save()
             return person
         } catch let error {
             fatalError(error.localizedDescription)
         }
     }
    
    func createPerson(name: String, using currentGathering: Gathering) -> Person {
        let person = Person(context: mainContext)
        
        person.name = name
       person.id = UUID()
       
       let numOfPeople = currentGathering.people.count
       person.order = Int64(numOfPeople)

       if currentGathering.dutchUnits.count == 0 { return person }
       
       do {
            try mainContext.save()
            return person
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    func changePersonOrder(of first: Person, with second: Person) {
        let tempOrder = first.order
        
        first.order = second.order
        second.order = tempOrder
        update()
    }
    
    func addPeople(addedPeople: [Person], currentGathering: Gathering) {
        
        if addedPeople.count == 0 { return }
        // name check needed each time person name input
        
        addedPeople.forEach { currentGathering.people.update(with: $0)}
        print("numOfPeople: \(currentGathering.people.count)")
        update()
        
        if currentGathering.dutchUnits.count == 0 { return }
        
        // add PersonDetails to each of dutchUnits
        for (idx, eachUnit) in currentGathering.dutchUnits.sorted().enumerated() {
            print("dutchUnit idx: \(idx), placeName: \(eachUnit.placeName)")
            
            var addedPersonDetails2 = [PersonDetail]()
            
            for eachPerson in addedPeople {
                let newPersonDetail = createPersonDetail(person: eachPerson, isAttended: false, spentAmount: 0)
                addedPersonDetails2.append(newPersonDetail)
                
                for eachDetail in addedPersonDetails2 {
                    eachUnit.personDetails.update(with: eachDetail)
                }
            }
            
            
        }
        update()
    }
    
    func removePeople(from gathering: Gathering, removedPeople: [Person]) {
        if removedPeople.count == 0 { return }
        
        for removedPerson in removedPeople {
            for dutchUnit in gathering.dutchUnits.sorted() {
                for eachDetail in dutchUnit.personDetails {
                    if eachDetail.person! == removedPerson {
                        dutchUnit.personDetails.remove(eachDetail)
                    }
                }
            }
            gathering.people.remove(removedPerson)
        }
        update()
    }
    
    // TODO: 여기서 고쳐야함.
    func updateAllDetailsWithNewPeople(updatedPeople: [Person], currentGathering: Gathering) {
        // 이름 바꾸는 경우는 어떻게 처리하지... ??
        // 사람을 추가할 수도, 제거할 수도 있는 경우.
        let originalMemberSet = Set(currentGathering.people)
        let updatedMemberSet = Set(updatedPeople)
        
        print("updating DutchUnit flag, originalMember: ")
        printPeople(peopleSet: originalMemberSet)
        
        print("updating DutchUnit flag, updatedMember:")
        printPeople(peopleSet: updatedMemberSet)
        let addedPeopleSet = updatedMemberSet.subtracting(originalMemberSet)
        
//        let removedPeopleSet = originalMemberSet.subtracting(updatedMemberSet)
        print("people flag 2, addedPeopleSet: \(addedPeopleSet)")
        
        print("updating DutchUnit flag, addedPeopleSet: ")
        printPeople(peopleSet: addedPeopleSet)
        
        
        
        
        // addedPeopleSet
        if addedPeopleSet.count != 0 {
            
            // 이게.. 존재하지 않아서 call 되지 않음.
            for eachUnit in currentGathering.dutchUnits.sorted() {
                for eachPerson in addedPeopleSet {
                    let newPersonDetail = self.createPersonDetail(person: eachPerson, isAttended: false, spentAmount: 0)
                    // 순서가 중요함 !! 내부에서 새로 personDetail 만든 후 update 할 것!
                    eachUnit.personDetails.update(with: newPersonDetail)
                    print("people flag 3, currentGathering's people: \(currentGathering.people)")
                }
            }
            
            for eachPerson in addedPeopleSet {
                currentGathering.people.update(with: eachPerson)
            }
        }
        
        update() // update 했는데 왜... ??
    }
    
    func addPerson(name: String) {
//        let newPerson =
    }
    
    
    
    // MARK: - Test Funcs
    
    
    
}


extension DutchManager {
    func swapPersonOrder(of person1: Person, with person2: Person) {
        let tempOrder = person2.order
        
        person2.order = person1.order
        person1.order = tempOrder
        
        //        update()
        
    }
}

