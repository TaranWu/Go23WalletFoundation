//
//  RPCServerOrAuto.swift
//  Go23Wallet
//
//  Created by Taran.
//

import Foundation

public enum RPCServerOrAuto: Hashable {
    case auto
    case server(RPCServer)
}
