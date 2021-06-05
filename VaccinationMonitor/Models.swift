//
//  Models.swift
//  VaccinationMonitor
//
//  Created by Christian Lobach on 04.06.21.
//

import Foundation

struct VenueInfo: Decodable {

    private static let urls = [
        "arena": "https://www.doctolib.de/institut/berlin/ciz-berlin-berlin?pid=practice-158431",
        "tempelhof": "https://www.doctolib.de/institut/berlin/ciz-berlin-berlin?pid=practice-191611",
        "messe": "https://www.doctolib.de/institut/berlin/ciz-berlin-berlin?pid=practice-158434",
        "velodrom": "https://www.doctolib.de/institut/berlin/ciz-berlin-berlin?pid=practice-158435",
        "tegel": "https://www.doctolib.de/institut/berlin/ciz-berlin-berlin?pid=practice-158436",
        "erika": "https://www.doctolib.de/institut/berlin/ciz-berlin-berlin?pid=practice-158437"
    ]

    let id: String
    let name: String
    let open: Bool
    let lastUpdate: Date?
    let statsPerDate: [String: VenueStat]

    var url: URL? {
        Self.urls[id]
            .flatMap(URL.init(string:))
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, open, lastUpdate
        case statsPerDate = "stats"
    }
}

struct VenueStat: Decodable {
    let percent: Double
    let count: Int
    let last: Date
}
