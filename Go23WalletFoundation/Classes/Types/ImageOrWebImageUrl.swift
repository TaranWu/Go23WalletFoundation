//
//  ImageOrWebImageUrl.swift
//  Go23Wallet
//
//  Created by Taran.
//

import UIKit

public enum ImageOrWebImageUrl {
    case url(WebImageURL)
    case image(RawImage)
}

public enum RawImage {
    case generated(image: UIImage, symbol: String)
    case loaded(image: UIImage)
    case none
}
