//
//  AppColors.swift
//  ContactSyncing
//
//  Created by Admin on 10/10/23.
//

import UIKit.UIColor

enum AppColors: String {
    case greyBlackTextColor
    case greyDisableColor
    case greenButtonColor
}

extension AppColors {
    var color: UIColor {
        UIColor(named: rawValue) ?? .gray
    }
}
