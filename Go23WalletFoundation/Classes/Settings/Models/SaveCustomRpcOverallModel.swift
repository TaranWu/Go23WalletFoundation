//
//  SaveCustomRpcOverallModel.swift
//  Go23Wallet
//
//  Created by Jerome Chan on 21/12/21.
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
