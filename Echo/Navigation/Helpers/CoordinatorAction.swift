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
    private enum CoordinatorPushKey: EnvironmentKey {
        static let defaultValue = CoordinatorPushAction { _ in
            debugPrint("Push action was invoked, but no value is set")
        }
    }

    var push: CoordinatorPushAction {
        get { self[CoordinatorPushKey.self] }
        set { self[CoordinatorPushKey.self] = newValue }
    }
    
    private enum CoordinatorPopKey: EnvironmentKey {
        static let defaultValue = CoordinatorPopAction {
            debugPrint("Pop action was invoked, but no value is set")
        }
    }

    var pop: CoordinatorPopAction {
        get { self[CoordinatorPopKey.self] }
        set { self[CoordinatorPopKey.self] = newValue }
    }

    private enum CoordinatorPopToRootKey: EnvironmentKey {
        static let defaultValue = CoordinatorPopAction {
            debugPrint("Pop to root action was invoked, but no value is set")
        }
    }
    
    var popToRoot: CoordinatorPopAction {
        get { self[CoordinatorPopToRootKey.self] }
        set { self[CoordinatorPopToRootKey.self] = newValue }
    }
}
