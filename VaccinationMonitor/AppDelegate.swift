//
//  AppDelegate.swift
//  VaccinationMonitor
//
//  Created by Christian Lobach on 04.06.21.
//

import Cocoa
import Combine


@main
class AppDelegate: NSObject, NSApplicationDelegate {

    
    private var statusBarItem: NSStatusItem?
    private let publisher = APIClient().newPublisher()
    private var cancellable: AnyCancellable?
    private var lastUpdate: Date?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setUpMenuItem()

        cancellable = publisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
            print(completion)
        }, receiveValue: { [weak self] venueInfos in
            self?.sendNotificationIfNeeded(for: venueInfos)
            self?.updateMenu(for: venueInfos)
            self?.lastUpdate = Date()
        })

    }

    private func sendNotificationIfNeeded(for infos: [VenueInfo]) {

    }

    func setUpMenuItem() {
        guard statusBarItem == nil else { return }
        statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        if let button = statusBarItem?.button {
            button.title = "💉"
            button.setAccessibilityLabel("VaccinationMonitor")
        }

    }

    private func updateMenu(for infos: [VenueInfo]) {
        guard let statusBarItem = statusBarItem else { return }
        let menu = NSMenu(title: "VaccinationMonitor")

        menu.addItem(UpdatedAtMenuItem(updatedAt: lastUpdate))

        for info in infos {
            let item = NSMenuItem()
            item.representedObject = info
            item.title = (info.open ? "🟢 " : "🔴 ") + info.name
            item.target = self
            item.action = #selector(openVenueURL)
            menu.addItem(item)
        }

        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit VaccinationMonitor", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusBarItem.menu = menu
    }

    @objc func openVenueURL(_ sender: NSMenuItem) {
        guard let venue = sender.representedObject as? VenueInfo,
              let url = venue.url else { return }
        NSWorkspace.shared.open(url)
    }

}
