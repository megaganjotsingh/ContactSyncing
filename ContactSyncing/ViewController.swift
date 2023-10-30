//
//  ViewController.swift
//  ContactSyncing
//
//  Created by Admin on 10/10/23.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func syncContacts(_ button: UIButton) {
        ContactsHelperWrapper.shared.showAlertForSyncContacts(on: self) { result in
            print(result)
        }
    }
}
