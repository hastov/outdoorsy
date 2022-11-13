//
//  DataRetrieving.swift
//  Outdoorsy
//
//  Created by Guest on 12.11.22.
//

import Foundation

typealias Rental = (name: String, image: URL?)
typealias RentalHandler = (Result<[Rental]?, Error>) -> Void

protocol DataRetrieving {
    func get(filter: String, completion: @escaping RentalHandler)
    func get(filter: String, limit: Int?, offset: Int?, completion: @escaping RentalHandler)
}

class OutdoorsyAPI {
    let base: URL = URL(string: "https://search.outdoorsy.co")!
}

class DataManager {
    private let api: OutdoorsyAPI
    private lazy var session = URLSession.shared
    
    init(api: OutdoorsyAPI = OutdoorsyAPI()) {
        self.api = api
    }
}

typealias JSON = Dictionary<AnyHashable, Any>

extension DataManager: DataRetrieving {
    func get(filter: String, completion: @escaping RentalHandler) {
        get(filter: filter, limit: nil, offset: nil, completion: completion)
    }
    
    func get(filter: String, limit: Int?, offset: Int?, completion: @escaping RentalHandler) {
        var request = URLRequest(url: api.base
            .appendingPathComponent("rentals")
            .appending(contentsOf: [
                URLQueryItem(name: "filter[keywords]", value: filter),
                URLQueryItem(name: "bounds[ne]", value: "85%2C180"),
                URLQueryItem(name: "bounds[sw]", value: "-85%2C-180")
            ])
        )
        if let limit = limit, let offset = offset {
            request.url?.append(contentsOf: [
                URLQueryItem(name: "page[limit]", value: limit.description),
                URLQueryItem(name: "page[offset]", value: offset.description)
            ])
        }
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                return completion(.failure(error))
            }
            guard let data = data else {
                return completion(.success(nil))
            }
            do {
                guard let json = try JSONSerialization.jsonObject(with: data) as? JSON else {
                    return completion(.failure(URLError(.cannotParseResponse)))
                }
                guard let jsonData = json["data"] as? [JSON] else {
                    return completion(.success(nil))
                }
                let jsonIncluded = json["included"] as? [JSON]
                completion(.success(self?.rentals(data: jsonData, included: jsonIncluded)))
            } catch let serializationError {
                completion(.failure(serializationError))
            }
        }
        task.resume()
    }
    
    private func rentals(data: [JSON], included: [JSON]?) -> [Rental]? {
        data.compactMap { json -> Rental? in
            guard let name = (json["attributes"] as? JSON)?["name"] as? String else {
                return nil
            }
            var url: URL?
            if let relationships = json["relationships"] as? JSON,
               let primaryData = relationships["primary_image"] as? JSON,
               let imageData = primaryData["data"] as? JSON,
               let imageID = imageData["id"] as? String,
               let includedImage = included?.first(where: { ($0["id"] as? String) == imageID }) as? JSON,
               let imageAttributes = includedImage["attributes"] as? JSON,
               let string = imageAttributes["url"] as? String {
                url = URL(string: string)
            }
            return Rental(name, url)
        }
    }
}

extension URL {
    func appending(contentsOf items: [URLQueryItem]) -> URL {
        urlComponents(with: items)?.url ?? self
    }
    
    mutating func append(contentsOf items: [URLQueryItem]) {
        if let url = urlComponents(with: items)?.url {
            self = url
        }
    }
    
    func urlComponents(with items: [URLQueryItem]) -> URLComponents? {
        guard var components = URLComponents(string: absoluteString) else {
            return nil
        }
        components.queryItems = (components.queryItems ?? []) + items
        return components
    }
}
