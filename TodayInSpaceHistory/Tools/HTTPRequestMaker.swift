//
//  HTTPRequestMaker.swift
//  TodayInSpaceHistory
//
//  Created by Mikołaj Linczewski on 26/09/2021.
//

import Foundation
import Combine

enum Endpoints: String {
    case search = "/search?"
    case asset = "/asset/"
    case captions = "/captions/"
    case album = "/album/"
}

protocol HTTPRequestMakerProtocol: AnyObject {
    var baseURL: String { get }
    
    func makeRequestAndParse<T: Decodable>(endpoint: Endpoints, arguments: [String]) -> AnyPublisher<T, Error>?
    func makeSearchRequest<T: Decodable>(arguments: [String]) -> AnyPublisher<[T], Error>?
}

class HTTPRequestMaker: HTTPRequestMakerProtocol {
    var baseURL: String = "https://images-api.nasa.gov"
    var APIkey: String = "LZbLlqQvVsMEUol6sIwGCIJbGEYzDerhRIFZN212"
    func makeRequestAndParse<T>(endpoint: Endpoints, arguments: [String]) -> AnyPublisher<T, Error>? where T : Decodable {
        switch endpoint {
        case .search:
            return makeSearchRequest(arguments: arguments)
        default:
            print("Mikołaj: unknown")
        }
        return nil
    }
    
    func makeSearchRequest<T>(arguments: [String]) -> AnyPublisher<T, Error>? where T : Decodable {
        let searchArguments = arguments.joined(separator: "%20")
        guard let url = URL(string: baseURL + Endpoints.search.rawValue + "description=" + searchArguments + "&media_type=image") else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return URLSession.shared.dataTaskPublisher(for: request)
            .map ({ $0.data })
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func makeRequest<T>(url: String) -> AnyPublisher<T, Error>? where T: Decodable {
        guard let url = URL(string: url) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return URLSession.shared.dataTaskPublisher(for: request)
            .map ({ $0.data })
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
