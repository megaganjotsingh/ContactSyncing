//
//  LocalizedString.swift
//  ContactSyncing
//
//  Created by Admin on 10/10/23.
//

import Foundation

enum LocalizedString: String {
    case syncContactsAndSupportFriends
    case findWhichFriendsAndLovedOnesAskingForSupport
    case syncNow
    case cancel
    
    case errorFetchingContacts
    case someErrorOccurred
    case permissionDeniedError
}


extension LocalizedString {
    var localized: String {
        NSLocalizedString(rawValue, comment: rawValue)
    }
}
