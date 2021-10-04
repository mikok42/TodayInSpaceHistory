//
//  APIResponse.swift
//  TodayInSpaceHistory
//
//  Created by Mikołaj Linczewski on 26/09/2021.
//

import Foundation

struct APIResponse: Codable {
    let collection: Collection
}

struct Collection: Codable {
    //let metadata: Metadata?
    let links: [Links]?
    //let version: String?
    let href: String?
    let items: [Item]?
}

struct Metadata: Codable {
    let totalHits: Int
}

struct Links: Codable {
    let prompt: String?
    let rel: String?
    let href: String?
}

struct Item: Codable {
    let data: [SearchResult]?
    let links: [ItemLinks]?
    let href: String?
}

struct ItemLinks: Codable {
    let rel: String?
    let href: String?
    let render: String?
}

struct SearchResult: Codable {
    let center: String?
    let dateCreated: String?
    let description: String?
    let keywords: [String]?
    let media_type: String?
    let nasaId: String?
    let title: String?
}
