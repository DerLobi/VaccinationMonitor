//
//  AppDelegate.swift
//  VaccinationMonitor
//
//  Created by Christian Lobach on 04.06.21.
//

import Cocoa
import Combine
import UserNotifications
import OSLog

@main
class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {

    private var statusBarItem: NSStatusItem?

    private var networkCancellable: AnyCancellable?
    private var intervalCancellable: AnyCancellable?
    private var lastUpdate: Date?

    private lazy var windowController: NSWindowController = {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateController(identifier: "Preferences") as NSWindowController
        return controller
    }()

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        UserDefaults.standard.registerDefaults()

        UNUserNotificationCenter.current().delegate = self

        setUpMenuItem()

        intervalCancellable = UserDefaults.standard
            .publisher(for: \.pollingInterval)
            .debounce(for: 1, scheduler: DispatchQueue.main)
            .sink { [weak self] interval in
                self?.setUpPublisher(with: interval)
            }

    }

    @objc private func setUpPublisher(with pollingInterval: TimeInterval) {

        self.networkCancellable = APIClient
            .newPublisher(with: pollingInterval)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.lastUpdate = Date()
                self?.sendNotificationIfNeeded(for: result)
                self?.updateMenu(for: result)
            }

    }

    private func sendNotificationIfNeeded(for result: Result<[VenueInfo], Error>) {
        guard UserDefaults.standard.bool(forKey: "notificationsEnabled") else {
            Logger.app.info("Not sending notifications because it is not enabled.")
            return
        }
        guard let infos = try? result.get() else {
            Logger.app.info("Not sending notifications because response was empty or had an error.")
            return
        }
        let openVenues = infos.filter(\.open)
        let center = UNUserNotificationCenter.current()

        center.getDeliveredNotifications { deliveredNotifications in

            let openVenueIDs = openVenues.map(\.id)
            Logger.app.debug("currently open: \(openVenueIDs, privacy: .public)")

            let notificationsToRemove = deliveredNotifications
                .map { $0.request.identifier }
                .filter { !openVenueIDs.contains($0) }

            if !notificationsToRemove.isEmpty {
                Logger.app.info("removing notifications for: \(notificationsToRemove, privacy: .public)")
            }

            center.removeDeliveredNotifications(withIdentifiers: notificationsToRemove)

            for info in openVenues where UserDefaults.standard.bool(forKey: info.id + "Filter") {

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
                Logger.app.info("showing notification for \(identifier, privacy: .public)")

                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        Logger.app.error("Error while adding notification request: \(error.localizedDescription, privacy: .public)")
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
        updateMenu(for: .success([]))
    }

    private func updateMenu(for result: Result<[VenueInfo], Error>) {
        guard let statusBarItem = statusBarItem else { return }
        let menu = NSMenu(title: "VaccinationMonitor")

        menu.addItem(UpdatedAtMenuItem(updatedAt: lastUpdate))

        if let infos = try? result.get() {

            for info in infos where UserDefaults.standard.bool(forKey: info.id + "Filter") {
                let item = NSMenuItem()
                item.representedObject = info
                item.title = (info.open ? "🟩 " : "🟥 ") + info.name
                item.target = self
                item.action = #selector(openVenueURL)
                menu.addItem(item)
            }

        } else {
            let item = NSMenuItem()
            item.title = "⚠️ Connection Error"
            menu.addItem(item)
        }

        menu.addItem(.separator())
        let preferencesItem = NSMenuItem(title: "Preferences", action: #selector(self.showPreferences(_:)), keyEquivalent: ",")
        menu.addItem(preferencesItem)

        menu.addItem(
            NSMenuItem(title: "Quit VaccinationMonitor",
                       action: #selector(NSApplication.terminate(_:)),
                       keyEquivalent: "q"))

        statusBarItem.menu = menu
    }

    @objc func openVenueURL(_ sender: NSMenuItem) {
        guard let venue = sender.representedObject as? VenueInfo,
              let url = venue.url else { return }
        NSWorkspace.shared.open(url)
    }

    @objc func showPreferences(_ sender: NSMenuItem) {
        windowController.window?.makeKeyAndOrderFront(sender)
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        defer { completionHandler() }
        guard let urlString = response.notification.request.content.userInfo["url"] as? String,
           let url = URL(string: urlString) else { return }

        NSWorkspace.shared.open(url)
    }
}
