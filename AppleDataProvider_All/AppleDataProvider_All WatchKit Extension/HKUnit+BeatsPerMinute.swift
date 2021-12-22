//
//  HKUnit+BeatsPerMinute.swift
//  AppleDataProvider_All WatchKit Extension
//
//  Created by SangBin Jeon on 2021/12/22.
//

import Foundation

import HealthKit

extension HKUnit {

    static func beatsPerMinute() -> HKUnit {
        return HKUnit.count().unitDivided(by: HKUnit.minute())
    }
    
}
