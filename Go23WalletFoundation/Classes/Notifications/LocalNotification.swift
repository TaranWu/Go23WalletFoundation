//
//  LocalNotification.swift
//  Go23Wallet
//
//  Created by Taran.
//

import Foundation

public enum LocalNotification: Equatable {
    case receiveEther(transaction: String, amount: String, server: RPCServer)
}
