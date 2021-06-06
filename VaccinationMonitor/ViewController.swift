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

    @IBOutlet weak var stepper: NSStepper!
    @IBOutlet weak var updateLabel: NSTextField!

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

        setUpAccessibility()
        setUpPublishers()

        notificationsEnabled = UserDefaults.standard.notificationsEnabled

        checkNotificationSettings()
    }

    private func setUpPublishers() {
        NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.checkNotificationSettings()
            }
            .store(in: &cancellables)

        let pollingIntervalTitle = UserDefaults.standard
            .publisher(for: \.pollingInterval)
            .map { interval in
                String(format: NSLocalizedString("update.interval.title",
                                                                      comment: ""),
                                            Int(interval))
            }

        pollingIntervalTitle
            .assign(to: \.intervalText, on: self)
            .store(in: &cancellables)

        pollingIntervalTitle
            .sink { [weak self] title in
                self?.stepper.setAccessibilityValue(title)
            }
            .store(in: &cancellables)
    }

    private func setUpAccessibility() {
        updateLabel.setAccessibilityRole(nil)
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
