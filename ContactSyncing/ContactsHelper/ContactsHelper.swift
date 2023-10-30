//
//  ContactsHelper.swift
//  ContactSyncing
//
//  Created by Admin on 10/10/23.
//

import Foundation
import Contacts
import UIKit.UIView

struct SyncContactsPopUp: ShowPopUpPropertiesProtocol {
    var image: UIImage? { nil }
    var title: String {
        LocalizedString.syncContactsAndSupportFriends.localized
    }
    var description: String {
        LocalizedString.findWhichFriendsAndLovedOnesAskingForSupport.localized
    }
    
    var filledButtonTitle: String {
        LocalizedString.syncNow.localized
    }
    
    var unfilledButtonTitle: String {
        LocalizedString.cancel.localized
    }
}

fileprivate enum ContactsError: Error {
    case permissionDeniedError
    case someErrorOccurred
    case errorFetchingContacts
}

fileprivate struct SyncContactRequestModel: Codable {
    let userId: String?
    let countryCode: String?
    let phoneNumber: String?
    let contacts: [Contacts]?
    
    struct Contacts: Codable {
        let name: String?
        let phoneNumber: String?
    }
}

extension ContactsError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .someErrorOccurred:
            return LocalizedString.someErrorOccurred.localized
        case .errorFetchingContacts:
            return LocalizedString.errorFetchingContacts.localized
        case .permissionDeniedError:
            return LocalizedString.permissionDeniedError.localized
        }
    }
}

class ContactsHelperWrapper {
    static let shared = ContactsHelperWrapper()
    private init() { }
    
    func checkForContactsSynced() -> Bool {
        UserDefaults.standard.bool(forKey: "isContactSynced")
    }
    
    func showAlertForSyncContacts(on vc: UIViewController, completion: @escaping (Result<Void, Error>) -> ()) {
        let showPopUp = ShowPopUpVC()
        showPopUp
            .setProperties(model: SyncContactsPopUp())
            .setClosures(
                filledButtonClosure: { [weak self] in
                    // sync now button
                    showPopUp.dismiss(animated: true)
                    self?.syncNowButtonTapped(completion: completion)
                },
                unfilledButtonClosure: {
                    // cancel
                    showPopUp.dismiss(animated: true)
                }
            )
            .present(
                on: vc
            )
    }
    
    private func syncNowButtonTapped(completion: @escaping (Result<Void, Error>) -> ()) {
        ContactsHelper.shared.checkforContactPermission { [weak self] result in
            switch result {
            case let .success(contacts):
                self?.syncContacts(contacts, completion: completion)
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func syncContacts(_ contacts: [CNContact], completion: @escaping (Result<Void, Error>) -> ()) {
        let getContacts: [SyncContactRequestModel.Contacts] = contacts.map { SyncContactRequestModel.Contacts(name: $0.fullName, phoneNumber: $0.phoneNumbers.first?.value.stringValue) }
        
        let syncContactRequestModel = SyncContactRequestModel(
            userId: "USER ID",
            countryCode: Locale.current.countryCode,
            phoneNumber: getContacts[1].phoneNumber,
            contacts: getContacts
        )
        print(syncContactRequestModel)
        
        // send syncContactRequestModel to backend
    }
}

class ContactsHelper {
    static let shared = ContactsHelper()
    
    lazy var arrContacts = [CNContact]()
    lazy var arrFilteredContacts = [CNContact]()
    lazy var contactStore = CNContactStore()
    
    private init() { }
    
    func checkforContactPermission(completion: @escaping (Result<[CNContact], Error>) -> ()) {
        switch CNContactStore.authorizationStatus(for: .contacts) {
            
        case .authorized:
            fetchContacts(completion: completion)
            
        case .notDetermined:
            contactStore.requestAccess(for: .contacts) { [weak self] succeeded, err in
                guard err == nil && succeeded else {
                    completion(.failure(err!))
                    return
                }
                self?.fetchContacts(completion: completion)
            }
            
        default:
            print("Not handled")
            completion(.failure(ContactsError.permissionDeniedError))
        }
    }
    
    func fetchContacts(completion: @escaping (Result<[CNContact], Error>) -> ()) {
        // reset contact list
        arrContacts.removeAll()
        
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactEmailAddressesKey,
            CNContactPhoneNumbersKey,
            CNContactImageDataKey] as [Any]
        
        // Get all the containers
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
            completion(.failure(ContactsError.errorFetchingContacts))
        }
        
        
        // Iterate all containers and append their contacts to our results array
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                arrContacts.append(contentsOf: containerResults)
                completion(.success(arrContacts))
            } catch {
                print("Error fetching results for container")
                completion(.failure(ContactsError.errorFetchingContacts))
            }
        }
    }
}

extension CNContact {
    
    var fullName: String {
        var name = ""
        if !self.givenName.isEmpty {
            name = self.givenName
        }
        if !self.middleName.isEmpty {
            name = name + " " + self.middleName
        }
        
        if !self.familyName.isEmpty {
            name = name + " " + self.familyName
        }
        return name
    }
        
    var dictionaryValue : [[String : Any]]? {
        var contacts = [[String : Any]]()
        var contactInfo = [String : Any]()
        var name = ""
        if !self.givenName.isEmpty {
            name = self.givenName
            contactInfo["name"] = name
        }
        if !self.middleName.isEmpty {
            name = name + " " + self.middleName
            contactInfo["name"] = name
        }
        
        if !self.familyName.isEmpty {
            name = name + " " + self.familyName
            contactInfo["name"] = name
        }
        if self.areKeysAvailable([CNContactEmailAddressesKey as CNKeyDescriptor]) {
            for email in self.emailAddresses{
                if !(email.value as String).isEmpty{
                    contactInfo["contactEmail"] = email.value as String
                    break;
                }
            }
        }
        
        for phone in self.phoneNumbers {
            let mobileNumber = removeSpecialCharactersFromContactNumberOfUser(phone.value.stringValue)
            if !mobileNumber.isEmpty {
                
                if name.isEmpty {
                    contactInfo["name"] = mobileNumber
                }
                contactInfo["mobile"] = mobileNumber
                contactInfo["displayMobile"] = phone.value.stringValue
                contactInfo["id"] = self.identifier + "--" + phone.identifier
                contacts.append(contactInfo)
            }
        }
        return contacts
    }
    
    fileprivate func removeSpecialCharactersFromContactNumberOfUser(_ contactNo : String) -> String {
        
        if contactNo.isAlphaNumeric { return "" }

        let digits = CharacterSet(charactersIn: "+0123456789").inverted
        var modifiedMobileString = contactNo.components(separatedBy: digits).joined(separator: "")
        
        let countryCode = Locale.current.countryCode ?? "+91"
        
        if modifiedMobileString.hasPrefix("+"){
            return modifiedMobileString
        }else{
            modifiedMobileString = countryCode + modifiedMobileString.trimLeadingZeroes
            return modifiedMobileString
        }
    }
    
}

extension Locale {
    var countryCode: String? {
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            print(countryCode)
            return countryCode
        }
        return nil
    }
}

extension String {
    func customError() -> Error {
        return NSError(domain: self, code: 201, userInfo: nil)
    }
    
    var trimLeadingZeroes: String {
        return "\(Int64(self) ?? 0)"
    }
    
    public var isAlphaNumeric: Bool {
        let hasLetters = rangeOfCharacter(from: .letters, options: .numeric, range: nil) != nil
        let hasNumbers = rangeOfCharacter(from: .decimalDigits, options: .literal, range: nil) != nil
        let comps = components(separatedBy: .alphanumerics)
        return comps.joined(separator: "").count == 0 && hasLetters && hasNumbers
    }
}
