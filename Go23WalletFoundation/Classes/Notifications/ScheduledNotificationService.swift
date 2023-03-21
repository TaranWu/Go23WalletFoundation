//
//  ScheduledNotificationService.swift
//  Go23Wallet
//
//  Created by Taran.
//

import Foundation
import UserNotifications

public protocol ScheduledNotificationService: AnyObject {
    func schedule(notification: LocalNotification)
}

