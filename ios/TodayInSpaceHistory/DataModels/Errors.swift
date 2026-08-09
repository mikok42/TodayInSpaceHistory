//
//  Errors.swift
//  TodayInSpaceHistory
//
//  Created by Mikołaj Linczewski on 09/08/2026.
//

import Foundation

protocol DescriptiveError: Error, CustomStringConvertible {
    var description: String { get }
}

struct Errors {}

extension Errors {
    enum NetworkClient: DescriptiveError {
        case invalidURL(endpointOrPath: String)
        case requestFailed(underlying: Error)
        case decodingFailed(underlying: Error)
        
        var description: String {
            switch self {
            case .invalidURL(let endpointOrPath):
                return "[NetworkClient] Failed to build URL from: \(endpointOrPath)"
            case .requestFailed(let underlying):
                return "[NetworkClient] Network request failed: \(underlying.localizedDescription)"
            case .decodingFailed(let underlying):
                return "[NetworkClient] Failed to decode response: \(underlying.localizedDescription)"
            }
        }
    }
}

extension Errors {
    enum ImageProvider: DescriptiveError {
        case noItems
        case missingAssetURL
        
        var description: String {
            switch self {
            case .noItems:
                return "[ImageProvider] NASA returned no images for today's date."
            case .missingAssetURL:
                return "[ImageProvider] Selected item is missing an asset list URL (href)."
            }
        }
    }
}
