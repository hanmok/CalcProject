//
//  SettingsViewModel.swift
//  Caliy
//
//  Created by Mac mini on 2021/10/16.
//  Copyright © 2021 Mac mini. All rights reserved.
//

import UIKit

struct SettingsViewModel {
    var attributedLabel: NSMutableAttributedString  {
        return NSMutableAttributedString(string: "", attributes: [:]) }
    var hasFullButton: Bool { return true }
    var hasSwitch: Bool { return true}
}
