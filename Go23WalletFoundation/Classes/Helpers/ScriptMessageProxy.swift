// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import WebKit

public final class ScriptMessageProxy: NSObject, WKScriptMessageHandler {

    private weak var delegate: WKScriptMessageHandler?

    public init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.userContentController(userContentController, didReceive: message)
    }
}
