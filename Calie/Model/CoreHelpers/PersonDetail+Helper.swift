//
//  PersonDetail+Helper.swift
//  Calie
//
//  Created by Mac mini on 2022/06/02.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import UIKit
import CoreData

extension PersonDetail {
    @discardableResult
    static func save(person: Person,
                     isAttended: Bool = true,
                     spentAmount: Double = 0) -> PersonDetail {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "PersonDetail", in: managedContext) else { fatalError("failed to get entity from subject ")}
        guard let personDetail = NSManagedObject(entity: entity, insertInto: managedContext) as? PersonDetail else {
            fatalError("failed to case to Subject during saving ")
        }
        
        personDetail.setValue(person, forKey: "person")
        personDetail.setValue(isAttended, forKey: "isAttended")
        personDetail.setValue(spentAmount, forKey: "spentAmount")
        
        managedContext.saveCoreData()
        return personDetail
    }
}



//struct PersonDetail2 {
//    var person: Person2
//    var spentAmount: Double = 0
//    var isAttended: Bool = true
//}
