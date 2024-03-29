//
//  ActivityOrTransactionInstance.swift
//  Go23Wallet
//
//  Created by Vladyslav Shepitko on 18.02.2022.
//

import Foundation

public enum ActivityOrTransactionInstance {
    case activity(Activity)
    case transaction(TransactionInstance)

    public var blockNumber: Int {
        switch self {
        case .activity(let activity):
            return activity.blockNumber
        case .transaction(let transaction):
            return transaction.blockNumber
        }
    }

    public var transaction: TransactionInstance? {
        switch self {
        case .activity:
            return nil
        case .transaction(let transaction):
            return transaction
        }
    }
    public var activity: Activity? {
        switch self {
        case .activity(let activity):
            return activity
        case .transaction:
            return nil
        }
    }
}
