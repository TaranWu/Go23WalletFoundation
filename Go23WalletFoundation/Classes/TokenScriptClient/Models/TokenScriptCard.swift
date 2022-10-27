// Copyright © 2020 Stormbird PTE. LTD.

import Foundation

public struct TokenScriptCard {
    public let name: String
    public let eventOrigin: EventOrigin
    public let view: (html: String, style: String)
    public let itemView: (html: String, style: String)
    public let isBase: Bool
}
