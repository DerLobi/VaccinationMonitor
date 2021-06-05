//
//  Logger+Default.swift
//  VaccinationMonitor
//
//  Created by Christian Lobach on 05.06.21.
//

import Foundation
import OSLog

extension Logger {
    static let app = Logger(subsystem: "de.christian-lobach.VaccinationMonitor", category: "VaccinationMonitor")
}
