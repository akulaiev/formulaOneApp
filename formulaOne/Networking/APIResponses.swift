//
//  APIResponses.swift
//  formulaOne
//
//  Created by Anna Kulaieva on 18.01.2021.
//

import Foundation

// MARK: - RaceResults
struct APIResponse<T: Codable>: Codable {
    let data: ResponseData<T>

    enum CodingKeys: String, CodingKey {
        case data = "MRData"
    }
}

// MARK: - Response data
struct ResponseData<T: Codable>: Codable {
    var limit, offset, total: String
    var result: APIResult<T>

    enum CodingKeys: String, CodingKey {
        case limit, offset, total
        case result = "RaceTable"
    }
    
    enum AnotherCodingKeys: String, CodingKey {
        case limit, offset, total
        case result = "SeasonTable"
    }

    // required to support multiple key values
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            result = try values.decode(APIResult<T>.self, forKey: .result)
            limit = try values.decode(String.self, forKey: .limit)
            offset = try values.decode(String.self, forKey: .offset)
            total = try values.decode(String.self, forKey: .total)
        } catch {
            do {
                let values = try decoder.container(keyedBy: AnotherCodingKeys.self)
                result = try values.decode(APIResult<T>.self, forKey: .result)
                limit = try values.decode(String.self, forKey: .limit)
                offset = try values.decode(String.self, forKey: .offset)
                total = try values.decode(String.self, forKey: .total)
            }
        }
    }
}

// MARK: - APIResult
struct APIResult<T: Codable>: Codable {
    let results: [T]

    enum CodingKeys: String, CodingKey {
        case results = "Races"
    }

    enum AnotherCodingKeys: String, CodingKey {
        case results = "Seasons"
    }

    // required to support multiple key values
    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            results = try values.decode([T].self, forKey: .results)
        } catch {
            do {
                let values = try decoder.container(keyedBy: AnotherCodingKeys.self)
                results = try values.decode([T].self, forKey: .results)
            }
        }
    }
}

// MARK: - Race
struct Race: Codable {
    let season, round: String
    let url: String
    let raceName: String
    let date: String
    var resultsInfo: [ResultInfo]

    enum CodingKeys: String, CodingKey {
        case season, round, url, raceName
        case date
        case resultsInfo = "Results"
    }
}

// MARK: - ResultInfo
struct ResultInfo: Codable {
    let number, position, positionText, points: String
    let driver: Driver
    let grid, laps, status: String
    let time: ResultTime?

    enum CodingKeys: String, CodingKey {
        case number, position, positionText, points
        case driver = "Driver"
        case grid, laps, status
        case time = "Time"
    }
}

// MARK: - Driver
struct Driver: Codable {
    let driverID: String
    let permanentNumber: String?
    let url: String
    let givenName, familyName, dateOfBirth, nationality: String

    enum CodingKeys: String, CodingKey {
        case driverID = "driverId"
        case permanentNumber, url, givenName, familyName, dateOfBirth, nationality
    }
}

// MARK: - ResultTime
struct ResultTime: Codable {
    let millis, time: String
}

// MARK: - Season
struct Season: Codable {
    let season: String
    let url: String
}
