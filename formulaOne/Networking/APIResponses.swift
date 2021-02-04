//
//  APIResponses.swift
//  formulaOne
//
//  Created by Anna Kulaieva on 18.01.2021.
//

import Foundation

// MARK: - RaceResults
struct APIResponse<T: Decodable>: Decodable {
    let data: ResponseData<T>

    enum CodingKeys: String, CodingKey {
        case data = "MRData"
    }
}

// MARK: - Response data
struct ResponseData<T: Decodable>: Decodable {
    var limit, offset, total: String
    var result: APIResult<T>

    enum CodingKeys: String, CodingKey {
        case limit, offset, total, result
        case resultRace = "RaceTable"
        case resultSeason = "SeasonTable"
    }

    // required to support multiple key values
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            result = try values.decode(APIResult<T>.self, forKey: .resultRace)
        } catch {
            result = try values.decode(APIResult<T>.self, forKey: .resultSeason)
        }
        limit = try values.decode(String.self, forKey: .limit)
        offset = try values.decode(String.self, forKey: .offset)
        total = try values.decode(String.self, forKey: .total)
    }
}

// MARK: - APIResult
struct APIResult<T: Decodable>: Decodable {
    let results: [T]

    enum CodingKeys: String, CodingKey {
        case results
        case resultsRace = "Races"
        case resultsSeason = "Seasons"
    }

    // required to support multiple key values
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            results = try values.decode([T].self, forKey: .resultsRace)
        } catch {
            results = try values.decode([T].self, forKey: .resultsSeason)
        }
    }
}

// MARK: - Race
struct Race: Decodable {
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
struct ResultInfo: Decodable {
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
struct Driver: Decodable {
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
struct ResultTime: Decodable {
    let millis, time: String
}

// MARK: - Season
struct Season: Decodable {
    let season: String
    let url: String
}
