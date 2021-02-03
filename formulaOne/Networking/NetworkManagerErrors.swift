//
//  NetworkManagerErrors.swift
//  formulaOne
//
//  Created by Anna Kulaieva on 19.01.2021.
//

import Foundation

enum NetworkManagerError: Error {
    case urlError(Error?)
    case networkRequestFailure(Error?)
    case decoderError(Error?)
    case networkError(Error?)
}

extension NetworkManagerError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .urlError(error):
            if let error = error {
                return error.localizedDescription
            }
            return "Could not perform networfing request because of invalid url provided"
        case let .networkRequestFailure(error):
            if let error = error {
                return error.localizedDescription
            }
            return "Networking request is failed"
        case let .decoderError(error):
            if let error = error {
                return error.localizedDescription
            }
            return "Could not perform networking data deciding"
        case let .networkError(error):
            if let error = error {
                return error.localizedDescription
            }
            return "Something went wrong with networking"
        }
    }
}
