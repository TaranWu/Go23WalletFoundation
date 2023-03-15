// Copyright © 2020 Stormbird PTE. LTD.

import Foundation
import APIKit
import Go23JSONRPCKit
import PromiseKit

extension APIKitSession {

    private class func sendImpl<Request: APIKit.Request>(_ request: Request, server: RPCServer, analytics: AnalyticsLogger, callbackQueue: CallbackQueue? = nil) -> Promise<Request.Response> {
        let (promise, seal) = Promise<Request.Response>.pending()
        APIKitSession.send(request, callbackQueue: callbackQueue) { result in
            switch result {
            case .success(let result):
                seal.fulfill(result)
            case .failure(let error):
                if let friendlyErr = convertToUserFriendlyError(error: error, server: server, baseUrl: request.baseURL) {
                    if let err = friendlyErr as? RpcNodeRetryableRequestError {
                        logRpcNodeError(err, analytics: analytics)
                    }
                    seal.reject(friendlyErr)
                } else {
                    seal.reject(error)
                }
            }
        }

        return promise
    }

    private static func logRpcNodeError(_ rpcNodeError: RpcNodeRetryableRequestError, analytics: AnalyticsLogger) {
        switch rpcNodeError {
        case .rateLimited(let server, let domainName):
            analytics.log(error: Analytics.WebApiErrors.rpcNodeRateLimited, properties: [Analytics.Properties.chain.rawValue: server.chainID, Analytics.Properties.domainName.rawValue: domainName])
        case .invalidApiKey(let server, let domainName):
            analytics.log(error: Analytics.WebApiErrors.rpcNodeInvalidApiKey, properties: [Analytics.Properties.chain.rawValue: server.chainID, Analytics.Properties.domainName.rawValue: domainName])
        case .possibleBinanceTestnetTimeout, .networkConnectionWasLost, .invalidCertificate, .requestTimedOut:
            return
        }
    }

    public class func send<Request: APIKit.Request>(_ request: Request, server: RPCServer, analytics: AnalyticsLogger, callbackQueue: CallbackQueue? = nil) -> Promise<Request.Response> {
        let promise = sendImpl(request, server: server, analytics: analytics, callbackQueue: callbackQueue)
        return firstly {
            promise
        }.recover { error -> Promise<Request.Response> in
            if error is RpcNodeRetryableRequestError {
                return sendImpl(request, server: server, analytics: analytics, callbackQueue: callbackQueue)
            } else {
                return promise
            }
        }
    }

    //TODO we should make sure we only call this RPC nodes because the errors we map to mentions "RPC"
    public static func convertToUserFriendlyError(error: SessionTaskError, server: RPCServer, baseUrl: URL) -> Error? {
        switch error {
        case .connectionError(let err):
            let message = err.localizedDescription
            if message.hasPrefix("The network connection was lost") {
                return RpcNodeRetryableRequestError.networkConnectionWasLost
            } else if message.hasPrefix("The certificate for this server is invalid") {
                return RpcNodeRetryableRequestError.invalidCertificate
            } else if message.hasPrefix("The request timed out") {
                return RpcNodeRetryableRequestError.requestTimedOut
            }
            return nil
        case .requestError(let err):
            return nil
        case .responseError(let err):
            if let jsonRpcError = err as? JSONRPCError {
                switch jsonRpcError {
                case .responseError(let code, let message, _):
                    //Lowercased as RPC nodes implementation differ
                    if message.lowercased().hasPrefix("insufficient funds") {
                        return SendTransactionNotRetryableError.insufficientFunds(message: message)
                    } else if message.lowercased().hasPrefix("execution reverted") || message.lowercased().hasPrefix("vm execution error") || message.lowercased().hasPrefix("revert") {
                        return SendTransactionNotRetryableError.executionReverted(message: message)
                    } else if message.lowercased().hasPrefix("nonce too low") || message.lowercased().hasPrefix("nonce is too low") {
                        return SendTransactionNotRetryableError.nonceTooLow(message: message)
                    } else if message.lowercased().hasPrefix("transaction underpriced") {
                        return SendTransactionNotRetryableError.gasPriceTooLow(message: message)
                    } else if message.lowercased().hasPrefix("intrinsic gas too low") || message.lowercased().hasPrefix("Transaction gas is too low") {
                        return SendTransactionNotRetryableError.gasLimitTooLow(message: message)
                    } else if message.lowercased().hasPrefix("intrinsic gas exceeds gas limit") {
                        return SendTransactionNotRetryableError.gasLimitTooHigh(message: message)
                    } else if message.lowercased().hasPrefix("invalid sender") {
                        return SendTransactionNotRetryableError.possibleChainIdMismatch(message: message)
                    } else if message == "Upfront cost exceeds account balance" {
                        //Spotted for Palm chain (mainnet)
                        return SendTransactionNotRetryableError.insufficientFunds(message: message)
                    } else {
                    }
                case .responseNotFound(_, let object): break
                case .resultObjectParseError(let err): break
                case .errorObjectParseError(let err): break
                case .unsupportedVersion(let str): break
                case .unexpectedTypeObject(let obj): break
                case .missingBothResultAndError(let obj): break
                case .nonArrayResponse(let obj): break
                }
                return nil
            }

            if let apiKitError = err as? APIKit.ResponseError {
                switch apiKitError {
                case .nonHTTPURLResponse: break
                case .unacceptableStatusCode(let statusCode):
                    if statusCode == 401 {
                        return RpcNodeRetryableRequestError.invalidApiKey(server: server, domainName: baseUrl.host ?? "")
                    } else if statusCode == 429 {
                        return RpcNodeRetryableRequestError.rateLimited(server: server, domainName: baseUrl.host ?? "")
                    } else {
                    }
                case .unexpectedObject(let obj): break
                }
                return nil
            }

            if RPCServer.binance_smart_chain_testnet.rpcURL.absoluteString == baseUrl.absoluteString, err.localizedDescription == "The data couldn’t be read because it isn’t in the correct format." {
                return RpcNodeRetryableRequestError.possibleBinanceTestnetTimeout
            }
            return nil
        }
    }
}

extension RPCServer {
    public static func serverWithRpcURL(_ string: String) -> RPCServer? {
        RPCServer.availableServers.first { $0.rpcURL.absoluteString == string }
    }
}
