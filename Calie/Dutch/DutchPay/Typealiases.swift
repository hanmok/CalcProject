//
//  Typealiases.swift
//  Calie
//
//  Created by Mac mini on 2022/09/03.
//  Copyright © 2022 Mac mini. All rights reserved.
//

import Foundation

typealias OverallPersonInfo = (name: String, relativePaidAmount: Double, attendedPlaces: String)

typealias PersonPaymentInfo = (name: String, paidAmt: Double, toGet: Double, sum: Double)

typealias DetailState = (spentAmount: Double, isAttended: Bool)

typealias InitialState = (place: String, amount: String, date: Date)



typealias Idx = Int
typealias Amt = Int

typealias PersonTuple = (name: String, spentAmount: Int, idx: Idx)

typealias ResultTuple = (from: Idx, to: Idx, amount: Int)

typealias BinIndex = Int

//typealias ResultTupleWithId = (from: UUID, to: UUID, amount: Int)
//typealias ResultTupleWithName = (from: String, to: String, amount: Int)
typealias ResultTupleWithId = (from: UUID, to: UUID, amount: Double)
typealias ResultTupleWithName = (from: String, to: String, amount: Double)

typealias NewNameAction = (Result<String, DutchError>) -> Void

typealias GatheringInfo = (title: String, totalPrice: String)


typealias ResultTest = (Result<Gathering, DutchError>) -> Void
