//
//  AppDelegate.swift
//  VaccinationMonitor
//
//  Created by Christian Lobach on 04.06.21.
//

import Cocoa
import Combine
import UserNotifications

@main
class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {

    
    private var statusBarItem: NSStatusItem?
    private let publisher = APIClient().newPublisher()
    private var cancellable: AnyCancellable?
    private var lastUpdate: Date?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        UNUserNotificationCenter.current().delegate = self

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

        let openVenues = infos.filter(\.open)
        let center = UNUserNotificationCenter.current()

        center.getDeliveredNotifications { deliveredNotifications in

            let openVenueIDs = openVenues.map(\.id)
            print("currently open: \(openVenueIDs)")

            let notificationsToRemove = deliveredNotifications
                .map { $0.request.identifier }
                .filter { !openVenueIDs.contains($0) }

            print("removing notifications for \(notificationsToRemove)")
            center.removeDeliveredNotifications(withIdentifiers: notificationsToRemove)

            for info in openVenues {

                let identifier = info.id

                if deliveredNotifications.contains(where: { $0.request.identifier == identifier }) { continue }

                let content = UNMutableNotificationContent()
                content.title = info.name
                content.body = "New vaccination appointments just became available."
                if let url = info.url {
                    content.userInfo = [
                        "url": url.absoluteString
                    ]
                }

                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
                print("showing notification for \(identifier)")
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }

        }

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


    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        defer { completionHandler() }
        guard let urlString = response.notification.request.content.userInfo["url"] as? String,
           let url = URL(string: urlString) else { return }

        NSWorkspace.shared.open(url)
    }
}
