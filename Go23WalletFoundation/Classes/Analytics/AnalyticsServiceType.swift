//
//  AnalyticsServiceType.swift
//  DerbyWalletFoundation
//
//  Created by Tatan.
//

import Foundation

public protocol AnalyticsServiceType: AnalyticsLogger {
    func applicationDidBecomeActive()
    func application(continue userActivity: NSUserActivity)
    func application(open url: URL, sourceApplication: String?, annotation: Any)
    func application(open url: URL, options: [UIApplication.OpenURLOptionsKey: Any])
    func application(didReceiveRemoteNotification userInfo: [AnyHashable: Any])
}
