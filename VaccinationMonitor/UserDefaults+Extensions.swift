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
            "pollingInterval": 5,
            "arenaFilter": true,
            "tempelhofFilter": true,
            "messeFilter": true,
            "velodromFilter": true,
            "tegelFilter": true,
            "erikaFilter": true
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

    // MARK: - Venue Filters

    @objc var arenaFilter: Bool {
        get {
            return bool(forKey: "arenaFilter")
        }
        set {
            set(newValue, forKey: "arenaFilter")
        }
    }

    @objc var tempelhofFilter: Bool {
        get {
            return bool(forKey: "tempelhofFilter")
        }
        set {
            set(newValue, forKey: "tempelhofFilter")
        }
    }

    @objc var messeFilter: Bool {
        get {
            return bool(forKey: "messeFilter")
        }
        set {
            set(newValue, forKey: "messeFilter")
        }
    }

    @objc var velodromFilter: Bool {
        get {
            return bool(forKey: "velodromFilter")
        }
        set {
            set(newValue, forKey: "velodromFilter")
        }
    }

    @objc var tegelFilter: Bool {
        get {
            return bool(forKey: "tegelFilter")
        }
        set {
            set(newValue, forKey: "tegelFilter")
        }
    }

    @objc var erikaFilter: Bool {
        get {
            return bool(forKey: "erikaFilter")
        }
        set {
            set(newValue, forKey: "erikaFilter")
        }
    }
}
