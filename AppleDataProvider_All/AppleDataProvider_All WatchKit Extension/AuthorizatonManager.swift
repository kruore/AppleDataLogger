//
//  AuthorizatonManager.swift
//  AppleDataProvider_All WatchKit Extension
//
//  Created by SangBin Jeon on 2021/12/22.
//


import HealthKit

class AuthorizationManager {

    static func requestAuthorization(completionHandler: @escaping() -> Void) {
        // Create health store.
        let healthStore = HKHealthStore()

        // Check if there is health data available.
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let readTypes = Set([heartRateType])
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            completionHandler()
            if let error = error {
                print(error)
            }
        }
    }
}
