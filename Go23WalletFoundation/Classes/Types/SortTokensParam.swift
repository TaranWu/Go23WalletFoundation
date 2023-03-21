//
//  SortTokensParam.swift
//  Go23Wallet
//
//  Created by Taran.
//

import Foundation

/// Enum represents value sorting direction
public enum SortDirection: Int {
    case ascending
    case descending
}

public extension Token {
    /// Helper enum represents fields available for sorting
    enum Field: Int {
        case name
        case value
    }
}

/// Enum represents token objects sorting cases
public enum SortTokensParam: CaseIterable, Equatable {
    case byField(field: Token.Field, direction: SortDirection)
    case mostUsed

    public static var allCases: [SortTokensParam] = Constants.defaultSortTokensParams
}
