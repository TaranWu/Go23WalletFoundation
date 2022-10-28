//
//  BlockiesImage.swift
//  DerbyWallet
//
//  Created by Tatan.
//

import UIKit
import Go23WalletCore

public enum BlockiesImage {
    case image(image: UIImage, isEnsAvatar: Bool)
    case url(url: WebImageURL, isEnsAvatar: Bool)

    public var isEnsAvatar: Bool {
        switch self {
        case .image(_, let isEnsAvatar):
            return isEnsAvatar
        case .url(_, let isEnsAvatar):
            return isEnsAvatar
        }
    }
}

extension BlockiesImage: Hashable { }
