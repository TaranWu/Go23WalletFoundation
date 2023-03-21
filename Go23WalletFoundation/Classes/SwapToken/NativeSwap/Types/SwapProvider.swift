//
//  SwapStepType.swift
//  Go23Wallet
//
//  Created by Taran.
//

import Foundation
import BigInt

public struct SwapStep {
    public let tool: String
    public let subSteps: [SwapSubStep]

    public init(tool: String, subSteps: [SwapSubStep]) {
        self.tool = tool
        self.subSteps = subSteps
    }
}

public struct SwapSubStep {
    public let gasCost: SwapEstimate.GasCost
    public let type: String
    public let amount: BigUInt
    public let token: SwapQuote.Token
    public let tool: String

    public init(gasCost: SwapEstimate.GasCost, type: String, amount: BigUInt, token: SwapQuote.Token, tool: String) {
        self.gasCost = gasCost
        self.type = type
        self.amount = amount
        self.token = token
        self.tool = tool
    }
}
