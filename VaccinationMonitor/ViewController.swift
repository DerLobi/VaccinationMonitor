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
                            UserDefaults.standard.set(true, forKey: "notificationsEnabled")
                        } else {
                            self?.notificationsEnabled = false
                        }
                    }
            } else {
                UserDefaults.standard.set(false, forKey: "notificationsEnabled")
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
            .sink { [weak self] interval in
                self?.intervalText = "Update every \(Int(interval)) seconds"
            }
            .store(in: &cancellables)

        checkNotificationSettings()
    }

    func checkNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.canEnableNotifications = settings.authorizationStatus != .denied
            }
        }
    }

    @IBAction func openSystemPreferences(_ sender: Any) {
        let notificationSettingsURL = URL(string: "x-apple.systempreferences:com.apple.preference.notifications")!
        NSWorkspace.shared.open(notificationSettingsURL)
    }
}
