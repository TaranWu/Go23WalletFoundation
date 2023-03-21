//
//  SaveCustomRpcOverallModel.swift
//  Go23Wallet
//
//  Created by Taran.
//

import Foundation

public struct SaveCustomRpcOverallModel {
    public let manualOperation: SaveOperationType
    public let browseModel: [CustomRPC]

    public init(manualOperation: SaveOperationType, browseModel: [CustomRPC]) {
        self.manualOperation = manualOperation
        self.browseModel = browseModel
    }
}
