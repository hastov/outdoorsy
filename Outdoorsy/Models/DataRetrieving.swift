//
//  DataRetrieving.swift
//  Outdoorsy
//
//  Created by hristoathristov
//

import Foundation

typealias Rental = (name: String, imageURL: URL?)
typealias RentalHandler = (Result<[Rental]?, Error>) -> Void

protocol Cancellable {
    func cancel()
}

extension URLSessionDataTask: Cancellable {}

protocol DataRetrieving {
    @discardableResult
    func get(filter: String, completion: @escaping RentalHandler) -> Cancellable
    @discardableResult
    func get(filter: String, limit: Int?, offset: Int?, completion: @escaping RentalHandler) -> Cancellable
}
