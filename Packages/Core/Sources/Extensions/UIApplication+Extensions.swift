//
//  File.swift
//
//
//  Created by Michael Kushinski on 10/24/23.
//

import UIKit

extension UIApplication {
    public var firstKeyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .first?.keyWindow
    }
}
