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
    private static let apiURL = URL(string: "https://api.impfstoff.link/?robot=1")!

    static func newPublisher(with pollingInterval: TimeInterval) -> AnyPublisher<Result<[VenueInfo], Error>, Never> {
        print("newPublisher")


        let timer = Timer
            .publish(every: pollingInterval, on: .main, in: .default)
            .autoconnect()

        let publisher = URLSession.shared.dataTaskPublisher(for: apiURL)
            .tryMap { data, response -> Result<[VenueInfo], Error> in
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .millisecondsSince1970
                let response = try decoder.decode(APIResponse.self, from: data)
                return .success(response.stats)
            }
            .catch { error in
                return Just(.failure(error))
            }

        return timer
            .flatMap { _ in publisher }
            .eraseToAnyPublisher()
    }

}
