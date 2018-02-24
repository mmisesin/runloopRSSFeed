//
//  SimpleAlert.swift
//  RunloopRssFeed
//
//  Created by Artem Misesin on 2/24/18.
//  Copyright © 2018 misesin. All rights reserved.
//

import Foundation
import UIKit

class SimpleAlert {
    @discardableResult static func showAlert(title: String? = nil, alert: String, delegate: UIViewController) -> UIAlertController {
        let titleString: String
        if let title = title {
            titleString = title
        } else {
            titleString = ""
        }
        let alertController = UIAlertController(title: titleString, message: alert, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
        delegate.present(alertController, animated: true, completion: nil)
        return alertController
    }
}
