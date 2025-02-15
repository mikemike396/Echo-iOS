//
//  CoordinatorAction.swift
//  Echo
//
//  Created by Michael Kushinski on 11/15/23.
//

import SwiftUI

struct CoordinatorPushAction {
    let action: (any Hashable) -> Void

    func callAsFunction(_ value: any Hashable) {
        action(value)
    }
}

struct CoordinatorPopAction {
    let action: () -> Void

    func callAsFunction() {
        action()
    }
}

extension EnvironmentValues {
    @Entry var push = CoordinatorPushAction { _ in
        debugPrint("Push action was invoked, but no value is set")
    }

    @Entry var pop = CoordinatorPopAction {
        debugPrint("Pop action was invoked, but no value is set")
    }

    @Entry var popToRoot = CoordinatorPopAction {
        debugPrint("Pop to root action was invoked, but no value is set")
    }
}
