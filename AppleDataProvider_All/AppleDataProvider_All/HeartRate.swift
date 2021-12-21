//
//  HeartRate.swift
//  AppleDataProvider_All
//
//  Created by SangBin Jeon on 2021/12/21.
//
import Foundation
import HealthKit

struct HeartRateEntry: Hashable, Identifiable {
    var heartRate: Double
    var date: Date
    var id = UUID()
}

class HeartHistoryModel: ObservableObject {
    
    @Published var heartData: [HeartRateEntry] = []
    var healthStore: HKHealthStore
    var queryAnchor: HKQueryAnchor?
    var query: HKAnchoredObjectQuery?
    
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        } else {
            fatalError("Health data not available")
        }
        
        self.requestAuthorization { authorised in
            if authorised {
                self.setupQuery()
            }
        }
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void){
        let heartBeat = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        
        self.healthStore.requestAuthorization(toShare: [], read: [heartBeat]) { (success, error) in completion(success)
        }
    }
    
    func setupQuery() {
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            return
        }
        
        let startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())
        
       let predicate = HKQuery.predicateForSamples(withStart: startDate, end: .distantFuture, options: .strictEndDate)
        
        self.query = HKAnchoredObjectQuery(type: sampleType, predicate: predicate, anchor: queryAnchor, limit: HKObjectQueryNoLimit, resultsHandler: self.updateHandler)
        
        self.query!.updateHandler = self.updateHandler
            
        healthStore.execute(self.query!)
    }
    
    func updateHandler(query: HKAnchoredObjectQuery, newSamples: [HKSample]?, deleteSamples: [HKDeletedObject]?, newAnchor: HKQueryAnchor?, error: Error?) {
        if let error = error {
            print("Health query error \(error)")
        } else {
            let unit = HKUnit(from: "count/min")
            if let newSamples = newSamples as? [HKQuantitySample], !newSamples.isEmpty {
                print("Received \(newSamples.count) new samples")
                DispatchQueue.main.async {
                    
                    var currentData = self.heartData
                    
                    currentData.append(contentsOf: newSamples.map { HeartRateEntry(heartRate: $0.quantity.doubleValue(for: unit), date: $0.startDate)
                    })
                    
                    self.heartData = currentData.sorted(by: { $0.date > $1.date })
                }
            }

            self.queryAnchor = newAnchor
        }
        
    }
}
