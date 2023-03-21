//
//  SwapTokenUsing.swift
//  Go23Wallet
//
//  Created by Taran.
//

import Foundation

public enum SwapTokenUsing {
    case url(url: URL, server: RPCServer?)
    case native(swapPair: SwapPair)
}
