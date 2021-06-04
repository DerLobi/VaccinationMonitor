//
//  APIClient.swift
//  VaccinationMonitor
//
//  Created by Christian Lobach on 04.06.21.
//

import Foundation
import Combine

struct APIResponse: Decodable {
    let stats: [VenueInfo]
}

class APIClient {
    private let apiURL = URL(string: "https://api.impfstoff.link/?robot=1")!
    private let pollingInterval: TimeInterval = 2

    func newPublisher() -> AnyPublisher<[VenueInfo], Error> {

        let timer = Timer
            .publish(every: pollingInterval, on: .main, in: .default)
            .autoconnect()

        let publisher = URLSession.shared.dataTaskPublisher(for: apiURL)
            .retry(0)
            .tryMap { data, response -> [VenueInfo] in
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .millisecondsSince1970
                let response = try decoder.decode(APIResponse.self, from: data)
                return response.stats
            }

        return timer
            .flatMap { _ in publisher }
            .eraseToAnyPublisher()
    }

}


func decodeResponse() {


}
