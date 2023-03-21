//
//  ReachabilityManager.swift
//  Go23Wallet
//
//  Created by Taran.
//

import Alamofire
import Combine
import CombineExt

public protocol ReachabilityManagerProtocol {
    var isReachable: Bool { get }
    var isReachablePublisher: AnyPublisher<Bool, Never> { get }
    var networkBecomeReachablePublisher: AnyPublisher<Void, Never> { get }
}

public class ReachabilityManager {
    private let manager: NetworkReachabilityManager?

    public var isReachable: Bool {
        return manager?.isReachable ?? false
    }

    private lazy var reachabilitySubject = CurrentValueSubject<Bool, Never>(isReachable)

    public init() {
        manager = NetworkReachabilityManager()

        manager?.startListening(onUpdatePerforming: { [weak reachabilitySubject] state in
            switch state {
            case .notReachable, .unknown:
                reachabilitySubject?.send(false)
            case .reachable:
                reachabilitySubject?.send(true)
            }
        })
    }
}

extension ReachabilityManager: ReachabilityManagerProtocol {
    public var networkBecomeReachablePublisher: AnyPublisher<Void, Never> {
        isReachablePublisher
            .filter { $0 }
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    public var isReachablePublisher: AnyPublisher<Bool, Never> {
        reachabilitySubject
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
