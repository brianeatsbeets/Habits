//
//  APIRequest.swift
//  Habits
//
//  Created by Aguirre, Brian P. on 1/25/23.
//

import Foundation

// This protocol provides a generic, efficient template for creating network requests
protocol APIRequest {
    
    // Store the type of object returned by the request
    associatedtype Response
    
    // Request data
    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
    var request: URLRequest { get }
    var postData: Data? { get }
}

// This extension provides default values for the host and port, which will never change
extension APIRequest {
    var host: String { "localhost" }
    var port: Int { 8080 }
}

// This extension returns nil for queryItems and postData since they will be unused most of the time
extension APIRequest {
    var queryItems: [URLQueryItem]? { nil }
    var postData: Data? { nil }
}

// This extension constructs the API request
extension APIRequest {
    var request: URLRequest {
        var components = URLComponents()
        
        components.scheme = "http"
        components.host = host
        components.port = port
        components.path = path
        components.queryItems = queryItems
        
        var request = URLRequest(url: components.url!)
        
        // If we have data to post, create a POST request
        if let data = postData {
            request.httpBody = data
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
        }
        
        return request
    }
}

// This enum contains cases for API request errors
enum APIRequestError: Error {
    case itemsNotFound
    case requestFailed
}

// This extension sends requests and handles the results
// Only usable by types with a Response type that conforms to Decodable
extension APIRequest where Response: Decodable {
    func send() async throws -> Response {
        
        // Initiate the data task
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Make sure we have a valid response
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIRequestError.itemsNotFound
        }
        
        // Attempt to decode the data
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Response.self, from: data)
        
        return decoded
    }
}
