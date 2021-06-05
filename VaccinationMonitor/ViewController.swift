//
//  ViewController.swift
//  VaccinationMonitor
//
//  Created by Christian Lobach on 04.06.21.
//

import Cocoa
import Combine
import UserNotifications
import OSLog

class ViewController: NSViewController {

    @objc dynamic var intervalText: String = ""

    @objc dynamic var notificationsEnabled = false {
        didSet {
            if notificationsEnabled {

                UNUserNotificationCenter.current()
                    .requestAuthorization(options: [.alert, .sound]) { [weak self] granted, authorizationError in

                        if let authorizationError = authorizationError {
                            Logger.app.error("Error while requesting authorization: \(authorizationError.localizedDescription, privacy: .public)")
                        }
                        Logger.app.info("Notification authorization granted: \(granted)")

                        if granted {
                            UserDefaults.standard.notificationsEnabled = true
                        } else {
                            self?.notificationsEnabled = false
                        }
                    }
            } else {
                UserDefaults.standard.notificationsEnabled = false
                UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            }
        }
    }

    @objc dynamic var canEnableNotifications = true

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        notificationsEnabled = UserDefaults.standard.notificationsEnabled

        NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.checkNotificationSettings()
            }
            .store(in: &cancellables)

        UserDefaults.standard
            .publisher(for: \.pollingInterval)
            .map { interval in
                String(format: NSLocalizedString("update.interval.title",
                                                                      comment: ""),
                                            Int(interval))
            }
            .assign(to: \.intervalText, on: self)
            .store(in: &cancellables)

        checkNotificationSettings()
    }

    private func checkNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.canEnableNotifications = settings.authorizationStatus != .denied
            }
        }
    }

    @IBAction private func openSystemPreferences(_ sender: Any) {
        let notificationSettingsURL = URL(string: "x-apple.systempreferences:com.apple.preference.notifications")!
        NSWorkspace.shared.open(notificationSettingsURL)
    }
}
