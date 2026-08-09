//
//  HTTPRequestMaker.swift
//  TodayInSpaceHistory
//
//  Created by Mikołaj Linczewski on 26/09/2021.
//

import Foundation

struct APIConstants {
    static let baseURL: String = "https://images-api.nasa.gov"
}

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
                    value: Date.todayDayMonthComponents.joined(separator: " ")
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

enum HTTPMethods: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

protocol HTTPRequestMakerProtocol: AnyObject {
    func makeRequest<T: Decodable>(endpoint: Endpoints) async throws -> T
    func fetchImages<T: Decodable>(url: String) async throws -> T
}

class HTTPRequestMaker: HTTPRequestMakerProtocol {
    func fetchImages<T: Decodable>(url: String) async throws -> T {
        guard let url = URL(string: url) else {
            throw URLError(.badURL)
        }
        return try await perform(request: URLRequest(url: url), decoder: JSONDecoder())
    }
    
    func makeRequest<T: Decodable>(endpoint: Endpoints) async throws -> T {
        guard let url = endpoint.url else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try await perform(request: request, decoder: decoder)
    }
    
    private func perform<T: Decodable>(request: URLRequest, decoder: JSONDecoder) async throws -> T {
        let (data, _) = try await URLSession.shared.data(for: request)
        return try decoder.decode(T.self, from: data)
    }
}
