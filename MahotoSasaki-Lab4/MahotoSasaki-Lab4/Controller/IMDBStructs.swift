//
//  IMDBStructs.swift
//  MahotoSasaki-Lab4
//
//  Created by Mahoto Sasaki on 10/27/20.
//  Copyright © 2020 mo3aru. All rights reserved.
//

import Foundation

struct APIResults:Decodable {
    let page: Int
    let total_results: Int
    let total_pages: Int
    let results: [Movie]
}

struct Movie: Decodable {
    let id: Int!
    let poster_path: String?
    let title: String
    let release_date: String?
    let vote_average: Double
    let overview: String
    let vote_count:Int!
}

struct Session: Encodable {
    let request_token:String
}
struct SessionResponse:Decodable {
    let success:Bool
    let session_id:String
}

struct deleteSessionStruct: Encodable {
    let session_id:String
}

struct updateAccountStruct: Encodable {
    let media_type: String
    let media_id: Int
    let favorite: Bool
}
