////
////  DutchpayManager.swift
////  Calie
////
////  Created by Mac mini on 2022/07/12.
////  Copyright © 2022 Mac mini. All rights reserved.
////
//
//import Foundation
//import CoreData
//
//// fetch 만 하면 지랄이군.. DK.. 설마...
//struct SampleManager {
//    let mainContext: NSManagedObjectContext
//
//    init(mainContext: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
//        self.mainContext = mainContext
//    }
//
//    @discardableResult
//    func createSampleGathering(title: String) -> SampleGathering? {
//        let gathering = SampleGathering(context: mainContext)
//
//        gathering.title = title
////        gathering.setValue(title, forKey: .Gathering.title)
//
//        do {
//            try mainContext.save()
//            return gathering
//        } catch let error {
//            print("Failed to create: \(error)")
//        }
//        return nil
//    }
//
//    func fetchSampleGatherings() -> [SampleGathering]? {
//
////        let fetchRequest = NSFetchRequest<Gathering>(entityName: "Gathering")
//        let fetchRequest = NSFetchRequest<SampleGathering>(entityName: "SampleGathering")
//
//        do {
//            let gatherings = try mainContext.fetch(fetchRequest)
//            return gatherings
//        } catch let error {
//            print("Failed to fetch companies: \(error)")
//        }
//        return nil
//    }
//
//    func fetchSampleGathering(withTitle title: String) -> SampleGathering? {
//
////        let fetchRequest = NSFetchRequest<Gathering>(entityName: "Gathering")
//        let fetchRequest = NSFetchRequest<SampleGathering>(entityName: "SampleGathering")
//        fetchRequest.fetchLimit = 1
//        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
//
//        do {
//            let gatherings = try mainContext.fetch(fetchRequest)
//            return gatherings.first
//        } catch let error {
//            print("Failed to fetch: \(error)")
//        }
//
//        return nil
//    }
//
//    func updateSampleGathering(sampleGathering: SampleGathering) {
//        do {
//            try mainContext.save()
//        }catch let error {
//            print("Failed to update: \(error)")
//        }
//    }
//
//    func deleteSampleGathering(sampleGathering: SampleGathering) {
//        mainContext.delete(sampleGathering)
//
//        do {
//            try mainContext.save()
//        } catch let error {
//            print("Failed to delete: \(error)")
//        }
//    }
//}
