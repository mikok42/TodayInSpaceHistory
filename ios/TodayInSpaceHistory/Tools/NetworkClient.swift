//
//  NetworkClient.swift
//  TodayInSpaceHistory
//
//  Created by Mikołaj Linczewski on 26/09/2021.
//

import Foundation

protocol NetworkClientProtocol: AnyObject {
    func makeRequest<T: Decodable>(endpoint: Endpoints) async throws -> T
    func fetchImages<T: Decodable>(url: String) async throws -> T
}

class NetworkClient: NetworkClientProtocol {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchImages<T: Decodable>(url: String) async throws -> T {
        guard let url = URL(string: url) else {
            throw Errors.NetworkClient.invalidURL(endpointOrPath: url)
        }
        return try await perform(request: URLRequest(url: url), decoder: JSONDecoder())
    }
    
    func makeRequest<T: Decodable>(endpoint: Endpoints) async throws -> T {
        guard let url = endpoint.url else {
            throw Errors.NetworkClient.invalidURL(endpointOrPath: endpoint.rawValue)
        }
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try await perform(request: request, decoder: decoder)
    }
    
    private func perform<T: Decodable>(request: URLRequest, decoder: JSONDecoder) async throws -> T {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw Errors.NetworkClient.requestFailed(underlying: error)
        }
        if let httpResponse = response as? HTTPURLResponse,
           !(200..<300).contains(httpResponse.statusCode) {
            throw Errors.NetworkClient.unacceptableStatusCode(httpResponse.statusCode)
        }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw Errors.NetworkClient.decodingFailed(underlying: error)
        }
    }
}
