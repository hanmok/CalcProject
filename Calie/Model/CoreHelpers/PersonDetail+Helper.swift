//
//  PersonDetail+Helper.swift
//  Calie
//
//  Created by Mac mini on 2022/06/02.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import UIKit
import CoreData

extension PersonDetail : Comparable {
    public static func < (lhs: PersonDetail, rhs: PersonDetail) -> Bool {
        return lhs.person! < rhs.person!
    }
}
