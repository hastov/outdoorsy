//
//  Extensions.swift
//  Outdoorsy
//
//  Created by hristoathristov
//

import Foundation

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

extension Collection {
    subscript (some index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
