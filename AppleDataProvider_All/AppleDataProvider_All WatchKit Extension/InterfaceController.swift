//
//  InterfaceController.swift
//  AppleDataProvider_All WatchKit Extension
//
//  Created by SangBin Jeon on 2021/12/20.
//

import WatchKit
import Foundation
import CoreMotion
import WatchConnectivity
import HealthKit
import UIKit

class InterfaceController: WKInterfaceController,WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    func session(_ session:WCSession,didReceiveUserInfo userInfo:[String:Any]=[:])
    {
    }
    
    @IBOutlet weak var gyroslabel: WKInterfaceLabel!
    @IBOutlet weak var acclabel: WKInterfaceLabel!
    @IBOutlet weak var heartRate: WKInterfaceLabel!
    @IBOutlet weak var startButton: WKInterfaceButton!
    
    // Properties
    private let workoutManager = WorkoutManager()
    let session = WCSession.default
    var n = 0
    var bupdate = false
    var accdatas = String()
    var datas = String()
    let healthStore = HKHealthStore()
    let motionManager = CMMotionManager()
    var heartbit = String(0)
    
    
    var sendMessage_Final = String()
    
    override func awake(withContext context: Any?) {
        
        // Configure interface objects here.
        session.delegate=self
        session.activate()
    }
    
    override func willActivate() {
        super.willActivate()
        
      
      
        
        let allTypes = Set([HKObjectType.workoutType(),
                            HKObjectType.quantityType(forIdentifier: .heartRate)!])

        healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
            if !success {
                print("Error")
                // Handle the error here.
            }
        }
        
        
        workoutManager.delegate = self
        
        // This method is called when watch view controller is about to be visible to user
        if WCSession.isSupported()
        {
            if session.activationState==WCSessionActivationState.notActivated
            {
                let session=WCSession.default
                session.delegate=self
                session.activate()
            }
        }
    }
    
   
    
    
    //Permission
    func requestHealthkit(_ healthStore:HKHealthStore) {
        let writableTypes: Set<HKSampleType> = [
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
            HKWorkoutType.workoutType(),
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        ]
        let readableTypes: Set<HKSampleType> = [
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
            HKWorkoutType.workoutType(),
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        ]


        healthStore.requestAuthorization(toShare: writableTypes, read: readableTypes) { (success, error) -> Void in
            if success {
                print("[HealthKit] request Authorization succeed!")
            } else {
                print("[HealthKit] request Authorization failed!")
            }
            if let error = error { print("[HealthKit] An error occurred: \(error)") }
        }
    }
    
    
    
    @IBAction func didTapButton() {
        switch workoutManager.state {
        case .started:
            // Stop current workout.
            workoutManager.stop()
            motionManager.stopGyroUpdates()
            motionManager.stopAccelerometerUpdates()
            motionManager.stopDeviceMotionUpdates()
            motionManager.stopMagnetometerUpdates()
            break
        case .stopped:
            // Start new workout.
            workoutManager.start()
            motionManager.startDeviceMotionUpdates()
            motionManager.startGyroUpdates()
            motionManager.startAccelerometerUpdates()
            //motionManager.accelerometerUpdateInterval=1
            UpdateDatas()
            break
        }
    }
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }
    //    @IBAction func UpdateButtonPress() {
    //        bupdate=(!bupdate)
    //        //motionManager.accelerometerUpdateInterval=1
    //        UpdateDatas()
    //    }
    func UpdateDatas()
    {
        if (!motionManager.isDeviceMotionActive)
        {
            motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: OperationQueue.main) { (motion: CMDeviceMotion?, error: Error?) in
                
                // optional binding for safety
                if let deviceMotion = motion {
                    let timestamp = Date().timeIntervalSince1970 * 1000
                  
//                    let deviceOrientationRx = deviceMotion.attitude.pitch
//                    let deviceOrientationRy = deviceMotion.attitude.roll
//                    let deviceOrientationRz = deviceMotion.attitude.yaw
//
//                    let deviceOrientationQx = deviceMotion.attitude.quaternion.x
//                    let deviceOrientationQy = deviceMotion.attitude.quaternion.y
//                    let deviceOrientationQz = deviceMotion.attitude.quaternion.z
//                    let deviceOrientationQw = deviceMotion.attitude.quaternion.w

//                    let magneticFieldX = deviceMotion.magneticField.field.x
//                    let magneticFieldY = deviceMotion.magneticField.field.y
//                    let magneticFieldZ = deviceMotion.magneticField.field.z
                    
                    let accx = String(format: "%0.3f", deviceMotion.userAcceleration.x);
                    let accy = String(format: "%0.3f", deviceMotion.userAcceleration.y);
                    let accz = String(format: "%0.3f", deviceMotion.userAcceleration.z);

                    let gravityAccx = String(format: "%0.3f", deviceMotion.userAcceleration.x * 9.81);
                    let gravityAccy = String(format: "%0.3f", deviceMotion.userAcceleration.y * 9.81);
                    let gravityAccz = String(format: "%0.3f", deviceMotion.userAcceleration.z * 9.81);
                    
                    let currentdatetime=String(format: "%0.0f",Date().timeIntervalSince1970 * 1000)
                    let gyrox=String(format: "%0.3f", deviceMotion.rotationRate.x )
                    let gyroy=String(format: "%0.3f", deviceMotion.rotationRate.y )
                    let gyroz=String(format: "%0.3f", deviceMotion.rotationRate.z )

//                    let deviceHeadingAngle = deviceMotion.heading
                    self.gyroslabel.setText("\(gyrox),\(gyroy),\(gyroz)")
                    self.acclabel.setText("\(gravityAccx),\(gravityAccy),\(gravityAccz)")
                    self.datas += "\(currentdatetime),\(gyrox),\(gyroy),\(gyroz),\(accx),\(accy),\(accz),\(self.heartbit);"
                    let sendmessage = self.datas
                   // print(sendmessage)
                    self.datas = ""
                    self.session.sendMessage(["watch":sendmessage as String], replyHandler: nil,errorHandler: nil)
                    
               
                }
            }
        }
    }
}

extension InterfaceController: WorkoutManagerDelegate {
    
    func workoutManager(_ manager: WorkoutManager, didChangeStateTo newState: WorkoutState) {
        // Update title of control button.
        startButton.setTitle(newState.actionText())
        print("START")
    }
    
    func workoutManager(_ manager: WorkoutManager, didChangeHeartRateTo newHeartRate: HeartRate) {
        print(newHeartRate.bpm)
        // Update heart rate label.
        heartRate.setText(String(format: "%.0f", newHeartRate.bpm))
        self.heartbit =  String(format: "%.0f", newHeartRate.bpm)
        print(newHeartRate.bpm)
    }
}
