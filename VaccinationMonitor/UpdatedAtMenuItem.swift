//
//  UpdatedAtMenuItem.swift
//  VaccinationMonitor
//
//  Created by Christian Lobach on 04.06.21.
//

import Cocoa

class UpdatedAtMenuItem: NSMenuItem {

    let updatedAt: Date?

    init(updatedAt: Date?) {
        self.updatedAt = updatedAt
        super.init(title: "Not updated", action: nil, keyEquivalent: "")
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static let updateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        formatter.locale = .autoupdatingCurrent
        return formatter
    }()

    override var title: String {
        get {
            if let updatedAt = updatedAt {
                return "Last updated " + Self.updateFormatter.localizedString(for: updatedAt, relativeTo: Date())
            } else {
                return "Not updated yet"
            }
        }
        set {}
    }
}
