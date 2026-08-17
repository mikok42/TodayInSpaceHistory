//
//  Endpoints.swift
//  TodayInSpaceHistory
//
//  Created by Mikołaj Linczewski on 26/09/2021.
//

import Foundation

enum Endpoints: String {
    case search = "/search"
    case asset = "/asset/"
    case captions = "/captions/"
    case album = "/album/"
    
    var queryParams: [URLQueryItem] {
        switch self {
        case .search:
            return [
                URLQueryItem(
                    name: "description",
                    value: Date.todayDayMonthComponents().joined(separator: " ")
                ),
                URLQueryItem(name: "media_type", value: "image")
            ]
        case .asset, .captions, .album:
            return []
        }
    }
    
    var url: URL? {
        switch self {
        case .search:
            var components = URLComponents(string: APIConstants.baseURL + rawValue)
            components?.queryItems = queryParams
            return components?.url
        case .asset, .captions, .album:
            return nil
        }
    }
    
    var method: HTTPMethods {
        switch self {
        case .search: return .get
        case .asset: return .get
        case .captions: return .get
        case .album: return .get
        }
    }
}
