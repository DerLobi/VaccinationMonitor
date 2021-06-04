//
//  UserDefaults+Extensions.swift
//  VaccinationMonitor
//
//  Created by Christian Lobach on 04.06.21.
//

import Foundation

extension UserDefaults {

    func registerDefaults() {
        register(defaults: [
            "notificationsEnabled": false,
            "pollingInterval": 5
        ])
    }

    @objc var notificationsEnabled: Bool {
        get {
            return bool(forKey: "notificationsEnabled")
        }
        set {
            set(newValue, forKey: "notificationsEnabled")
        }
    }

    @objc var pollingInterval: TimeInterval {
        get {
            return double(forKey: "pollingInterval")
        }
        set {
            set(newValue, forKey: "pollingInterval")
        }
    }
}
