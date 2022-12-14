// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct ArrayResponse<T: Decodable>: Decodable {
    private enum CodingKeys: CodingKey {
        case result
    }
    let result: [T]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            result = try container.decode([T].self, forKey: .result)
        } catch let error {
            if case DecodingError.typeMismatch(_, _) = error {
                result = []
            } else {
                throw error
            }
        }
    }
}
