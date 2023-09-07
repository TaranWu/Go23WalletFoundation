// Copyright © 2021 Stormbird PTE. LTD.

import Foundation

public typealias EmailAttachment = (data: Data, mimeType: String, fileName: String)

public class RemoteLogger {
    private let isActive: Bool

    public static var instance: RemoteLogger = .init()

    private init() {
        guard !Constants.Credentials.paperTrail.host.isEmpty else {
            isActive = false
            return
        }
        guard Constants.Credentials.paperTrail.port > 0 else {
            isActive = false
            return
        }
        isActive = true
    }

    private func logRpcErrorMessage(_ message: String) {

    }

    private func logOtherWebApiErrorMessage(_ message: String) {

    }

    func logRpcOrOtherWebError(_ message: String, url: String) {

    }
}

//TODO have to reconcile with the other logging functions above. Why and how is this different from the rest?
func logError(_ e: Error, pref: String = "", function f: String = #function, rpcServer: RPCServer? = nil, address: Go23Wallet.Address? = nil) {

}
