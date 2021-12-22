//
//  AuthorizatonManager.swift
//  AppleDataProvider_All WatchKit Extension
//
//  Created by SangBin Jeon on 2021/12/22.
//

import HealthKit

class AuthorizationManager {

    static func requestAuthorization(completionHandler: ((_ success: Bool) -> Void)) {
        // Create health store.
        let healthStore = HKHealthStore()

        // Check if there is health data available.
        if (!HKHealthStore.isHealthDataAvailable()) {
            print("No health data is available.")
            completionHandler(false)
            return
        }

        // Create quantity type for heart rate.
        guard let heartRateQuantityType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            print("Unable to create quantity type for heart rate.")
            completionHandler(false)
            return
        }
    }
}
