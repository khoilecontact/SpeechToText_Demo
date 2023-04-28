//
//  Utils.swift
//  SpeechToText_Demo
//
//  Created by KhoiLe on 15/04/2023.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlert(title: String? = nil,
                   message: String,
                   titleButton: String = "Ok",
                   completion: (() -> Void)? = nil) {
        let message = title == nil ? message : "\n\(message)"

        let ac = UIAlertController(title: title,
                                   message: message,
                                   preferredStyle: .alert)

        let okAction = UIAlertAction(title: titleButton, style: .cancel) { _ in
            completion?()
        }
        ac.addAction(okAction)

        let titleAtt = NSAttributedString(
            string: title ?? "",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.red,
                         NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)]
        )
        ac.setValue(titleAtt, forKey: "attributedTitle")

        let messageAtt = NSAttributedString(
            string: message,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.black,
                         NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
        )
        ac.setValue(messageAtt, forKey: "attributedMessage")

        ac.actions.first?.setValue(UIColor.blue, forKey: "titleTextColor")

        present(ac, animated: true, completion: nil)
    }
}
