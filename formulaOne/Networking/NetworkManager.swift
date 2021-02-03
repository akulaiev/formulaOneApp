//
//  NetworkManager.swift
//  formulaOne
//
//  Created by Anna Kulaieva on 24.12.2020.
//

import Foundation
import UIKit

protocol Requestable {
    var pathComponent: String { get }
}

enum Request {
    case currentWinners
    case raceResults(year: String, round: String)
    case pastRaces(year: String, place: String)
    case allSeasons
}

extension Request: Requestable {
    var pathComponent: String {
        switch self {
        case .currentWinners:
            return "/current/results/1"
        case let .raceResults(year, round):
            return "/\(year)/\(round)/results"
        case .pastRaces(year: let year, place: let place):
            return "/\(year)/results/\(place)"
        case .allSeasons:
            return "/seasons"
        }
    }
}

struct NetworkManager {
    
    private let requestLimit: Int
    private var baseString: String = "https://ergast.com"
    private var isLoading = false
        
    init(requestLimit: Int) {
        self.requestLimit = requestLimit
    }
    
    func performRequest<Response>(request: Request, requestOffset: Int, completion: @escaping (Result<Response, Error>) -> Void) where Response : Decodable {
        guard let builtRequest = build(request: request, requestOffset: requestOffset) else {
                completion(.failure(NetworkManagerError.urlError(nil)))
                return
            }
        let dataTask: URLSessionDataTask = URLSession.shared.dataTask(with: builtRequest) { data, _, error in
            DispatchQueue.main.async {
                guard let data = data else {
                    completion(.failure(NetworkManagerError.networkRequestFailure(error!)))
                    return
                }
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    let decodedData = try decoder.decode(Response.self, from: data)
                    completion(.success(decodedData))
                } catch {
                    completion(.failure(NetworkManagerError.decoderError(error)))
                }
            }
        }
        dataTask.resume()
    }

    //MARK: - Helper
    private func build(request: Request, requestOffset: Int) -> URLRequest? {
        guard var components = URLComponents(url: URL(string: baseString)!, resolvingAgainstBaseURL: true) else {
            fatalError(NetworkManagerError.urlError(nil).localizedDescription)
            
        }
        components.path = "/api/f1" + request.pathComponent + ".json"
        components.queryItems = [URLQueryItem]()
        components.queryItems?.append(contentsOf: [URLQueryItem(name: "offset", value: "\(requestOffset)"), URLQueryItem(name: "limit", value: "\(requestLimit)")])
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}
