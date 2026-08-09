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
        do {
            (data, _) = try await URLSession.shared.data(for: request)
        } catch {
            throw Errors.NetworkClient.requestFailed(underlying: error)
        }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw Errors.NetworkClient.decodingFailed(underlying: error)
        }
    }
}
