//
//  UIApplication+.swift
//
//
//  Created by Michael Kushinski on 10/24/23.
//

import UIKit

extension UIApplication {
    /// Finds the first window via the UIApplication Connected Scenes
    public var firstKeyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }?
            .keyWindow
    }
}
