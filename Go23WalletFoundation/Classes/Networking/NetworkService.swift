//
//  NetworkService.swift
//  Go23WalletFoundation
//
//  Created by Vladyslav Shepitko on 14.12.2022.
//

import Foundation
import Alamofire
import Combine
import Go23WalletCore

public typealias URLRequestConvertible = Alamofire.URLRequestConvertible
public typealias URLEncoding = Alamofire.URLEncoding
public typealias JSONEncoding = Alamofire.JSONEncoding
public typealias Parameters = Alamofire.Parameters
public typealias HTTPHeaders = Alamofire.HTTPHeaders
public typealias HTTPMethod = Alamofire.HTTPMethod
public typealias MultipartFormData = Alamofire.MultipartFormData

extension URLRequest {
    public typealias Response = (data: Data, response: HTTPURLResponse)
}

public protocol NetworkService {
    func dataTask(_ request: URLRequestConvertible) async throws -> URLRequest.Response
    func dataTaskPublisher(_ request: URLRequestConvertible, callbackQueue: DispatchQueue) -> AnyPublisher<URLRequest.Response, SessionTaskError>
    func upload(multipartFormData: @escaping (MultipartFormData) -> Void, usingThreshold: UInt64, with request: URLRequestConvertible, callbackQueue: DispatchQueue) -> AnyPublisher<URLRequest.Response, SessionTaskError>
}

extension NetworkService {
    func dataTaskPublisher(_ request: URLRequestConvertible) -> AnyPublisher<URLRequest.Response, SessionTaskError> {
        dataTaskPublisher(request, callbackQueue: .main)
    }

    func upload(multipartFormData: @escaping (MultipartFormData) -> Void,
                usingThreshold encodingMemoryThreshold: UInt64 = MultipartFormData.encodingMemoryThreshold,
                with request: URLRequestConvertible,
                callbackQueue: DispatchQueue = .main) -> AnyPublisher<URLRequest.Response, SessionTaskError> {
        upload(
            multipartFormData: multipartFormData,
            usingThreshold: encodingMemoryThreshold,
            with: request,
            callbackQueue: callbackQueue)
    }

}

public class BaseNetworkService: NetworkService {
    private let analytics: AnalyticsLogger
    private let session: Session

    public init(analytics: AnalyticsLogger, configuration: URLSessionConfiguration = .default) {
        self.session = Session(configuration: configuration)
        self.analytics = analytics
    }

    public func upload(
        multipartFormData: @escaping (MultipartFormData) -> Void,
        usingThreshold encodingMemoryThreshold: UInt64 = MultipartFormData.encodingMemoryThreshold,
        with request: URLRequestConvertible,
        callbackQueue: DispatchQueue) -> AnyPublisher<URLRequest.Response, SessionTaskError> {
            return session.upload(multipartFormData: multipartFormData, with: request)
                .publishData(queue: callbackQueue)
                .tryMap {
                    if let data = $0.data, let response = $0.response {
                        return (data, response)
                    } else {
                        throw NonHTTPURLResponseError(error: $0.error)
                    }
                }.mapError { SessionTaskError.requestError($0) }
                .eraseToAnyPublisher()
    }

    public func dataTaskPublisher(_ request: URLRequestConvertible,
                                  callbackQueue: DispatchQueue) -> AnyPublisher<URLRequest.Response, SessionTaskError> {

        return session.request(request)
            .publishData(queue: callbackQueue)
            .tryMap {
                if let data = $0.data, let response = $0.response {
                    return (data, response)
                } else {
                    throw NonHTTPURLResponseError(error: $0.error)
                }
            }.mapError { SessionTaskError.requestError($0) }
            .eraseToAnyPublisher()
    }

    public func dataTask(_ request: URLRequestConvertible) async throws -> URLRequest.Response {
        let response = try await session.request(request)
        if let data = response.data, let response = response.response {
            return (data, response)
        } else {
            throw NonHTTPURLResponseError(error: response.error)
        }
    }

}

extension BaseNetworkService {
    class functional {}
}

struct NonHTTPURLResponseError: Error {
    let error: AFError?
}
