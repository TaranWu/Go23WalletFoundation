//
//  SchemaCheckError.swift
//  Go23Wallet
//
//  Created by Taran.
//

import Foundation

public struct SchemaCheckError: LocalizedError {
    var msg: String
    public var errorDescription: String? {
        return msg
    }
}

public enum OpenURLError: Error {
    case unsupportedTokenScriptVersion
    case copyTokenScriptURL(_ url: URL, _ destinationURL: URL, error: Error)
}
