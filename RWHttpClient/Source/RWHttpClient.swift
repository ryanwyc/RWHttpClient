//
//  RWHttpClient.swift
//  RWHttpClient
//
//  Created by Ryan Wu on 2018-08-18.
//  Copyright © 2018 Ryan Wu. All rights reserved.
//

import Foundation

public class RWHttpClient {
    public static let shared = RWHttpClient()
    private let defaultSession = URLSession(configuration: .default)
    private init() {}
    
    /*
     To excute REST request with URLSessionDataTask
     - Parameter
     operation: A url operation string. e.g. /apod
     queryItems: A array of URLQueryItems for query parameters
     configuration: RESTClientConfiguration for request config
     completion: A closure to handle task completion
     - Returns: A URLSessionDataTask excuted the request
     */
    @discardableResult
    public func execute<T: Codable>(operation: String,
                                    queryItems: [URLQueryItem]? = nil,
                                    configuration: RWHttpClientConfiguration,
                                    completion: @escaping (RWHttpClientResult<T>) -> Void) -> URLSessionDataTask? {
        
        guard let urlString = configuration.fullUrlString(operation: operation, urlQueryItems: queryItems),
            let url = URL(string: urlString) else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidUrl))
                }
                return nil
        }
        let request = URLRequest(url: url)
        return self.execute(request: request, completion: completion)
    }
    
    /*
     To excute REST request with URLSessionDataTask
     - Parameter
     request: A URLRequest for URLSessionDataTask
     completion: A closure to handle task completion
     - Returns: A URLSessionDataTask excuted the request
     */
    @discardableResult
    public func execute<T: Codable>(request: URLRequest,
                                    completion: @escaping (RWHttpClientResult<T>) -> Void) -> URLSessionDataTask {
        
        let dataTsak = defaultSession.dataTask(with: request) { (data, urlResponse, error) in
            
            if let error = error {
                print("DataTask error: " + error.localizedDescription + "\n")
                completion(.failure(.unknown))
            } else if let data = data, let response = urlResponse as? HTTPURLResponse {
                
                let json = String(data: data, encoding: .utf8)
                print(json ?? "")
                let decoder = JSONDecoder()
                if response.statusCode == RWHttpClientHttpStatusCode.ok.rawValue ||
                    response.statusCode == RWHttpClientHttpStatusCode.accepted.rawValue {
                    // YYYY-MM-dd
                    decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Short)
                    do {
                        let response = try decoder.decode(T.self, from: data)
                        completion(.success(response))
                    } catch (let jsonError) {
                        completion(.failure(.jsonParse(jsonError)))
                    }
                } else {
                    // try decode error response
                    do {
                        let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
                        completion(.failure(.response(errorResponse)))
                    } catch (let jsonError) {
                        completion(.failure(.jsonParse(jsonError)))
                    }
                }
            } else {
                print("DataTask error: something worng\n")
                completion(.failure(.unknown))
            }
        }
        dataTsak.resume()
        return dataTsak
    }
}

// RESTClient Result
public enum RWHttpClientResult<T: Codable> {
    case success(T)
    case failure(RWHttpClientError)
}

// RESTClient HttpResponse Error Code
public enum RWHttpClientHttpStatusCode: Int {
    case ok = 200
    case accepted = 202
}

public enum RWHttpClientError: Error, LocalizedError {
    case unknown
    case noInternetConnection
    case invalidUrl
    case unAuthenticated
    case jsonParse(Error)
    case response(ErrorResponse)
}

open class RWHttpClientConfiguration {
    
    public let host: String
    public let apiKey: String
    
    static public func `default`() -> RWHttpClientConfiguration {
        return RWHttpClientConfiguration(host: "https://api.nasa.gov", apiKey: "NNKOjkoul8n1CH18TWA9gwngW1s1SmjESPjNoUFo")
    }
    static public func demo() -> RWHttpClientConfiguration {
        return RWHttpClientConfiguration(host: "https://api.nasa.gov", apiKey: "DEMO_KEY")
    }
    
    public init(host: String, apiKey: String) {
        self.host = host
        self.apiKey = apiKey
    }
    
    public func fullUrlString(operation: String, urlQueryItems: [URLQueryItem]? = nil) -> String? {
        var components = URLComponents(string: host+operation)
        components?.queryItems = urlQueryItems
        return components?.string
    }
}

extension DateFormatter {
    
    static let iso8601Short: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
}

public struct ErrorResponse: Codable {
    public let code: String
}

