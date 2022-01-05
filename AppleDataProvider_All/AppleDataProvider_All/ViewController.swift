//
//  ViewController.swift
//  AppleDataProvider_All
//
//  Created by SangBin Jeon on 2021/12/20.
//

import UIKit
import CoreLocation
import CoreMotion
import os.log
import WatchConnectivity
import HealthKit


class ViewController: UIViewController, CLLocationManagerDelegate, CMHeadphoneMotionManagerDelegate, WCSessionDelegate {
    

    var mTimer : Timer?

    func testMain(){
            print("")
            print("===============================")
            print("[Program Start]")
            print("===============================")
            print("")

            // 실시간 반복 작업 시작 실시
            startTimer()
        }


        // [실시간 반복 작업 시작 호출]
        var timer : Timer?
        func startTimer(){
            print("")
            print("===============================")
            print("[startTimer : start]")
            print("===============================")
            print("")
            // [타이머 객체 생성 실시]
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
        }
        // [실시간 반복 작업 수행 부분]
        @objc func timerCallback() {
            print("")
            print("===============================")
            print("[timerCallback : run]")
            print("[intCount : \(heartRate_int)")
            print("===============================")
            print("")
            self.heartrate.text = heartRate_int
            // [처리할 로직 작성 실시]
//            displayText.text = String(intCount) // UI 카운트 값 표시 실시
//            intCount += 1 // 1씩 카운트 값 증가 실시
//            if intCount > 5 { // 카운트 값이 5인 경우
//                stopTimer() // 타이머 종료 실시
//                showAlert(tittle: "카운트 알림", content: "타이머 종료", okBtb: "확인", noBtn: "") // 팝업창 호출

        }
        // [실시간 반복 작업 정지 호출]
        func stopTimer(){
            print("")
            print("===============================")
            print("[stopTimer : end]")
            print("===============================")
            print("")
            // [실시간 반복 작업 중지]
            if timer != nil && timer!.isValid {
                timer!.invalidate()
            }
        }
//
//
    func getSamples() {

        let heathStore = HKHealthStore()

        let heartrate = HKQuantityType.quantityType(forIdentifier: .heartRate)
        let sort: [NSSortDescriptor] = [
            .init(key: HKSampleSortIdentifierStartDate, ascending: false)
        ]

        let sampleQuery = HKSampleQuery(sampleType: heartrate!, predicate: nil, limit: 1, sortDescriptors: sort, resultsHandler: resultsHandler)

        heathStore.execute(sampleQuery)
    }

    func resultsHandler(query: HKSampleQuery, results: [HKSample]?, error: Error?) {
        guard error == nil else {
            print("cant read heartRate data", error!)
            return
        }
        guard let sample = results?.first as? HKQuantitySample else { return }
        // let heartRateUnit: HKUnit = .init(from: "count/min")
        // let doubleValue = sample.quantity.doubleValue(for: heartRateUnit)
        print("heart rate is", sample)
    }

    let healthStore = HKHealthStore()

    func authorizeHealthKit()
    {
        let read = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!])
        let share = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!])

        healthStore.requestAuthorization(toShare: share, read: read) { chk, error in
            if(chk)
            {
                print("Permission granted")
                self.latestHeartRate()
            }
        }
    }

    func latestHeartRate()
    {

        guard let sampleType = HKObjectType.quantityType(forIdentifier: .heartRate) else
        {
            return
        }
        let startData = Calendar.current.date(byAdding: .month, value: -1, to: Date())

        let predicate = HKQuery.predicateForSamples(withStart: startData, end: Date(), options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)


        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]){(sample, result, error) in guard error == nil else{
            return
        }
            let data = result![0] as! HKQuantitySample
            let unit = HKUnit(from: "count/min")
            let latestHr = data.quantity.doubleValue(for: unit)
            self.rate = String(latestHr)
            print("Latest hr\(latestHr) BPM")
            print(latestHr)
        }

        healthStore.execute(query)

    }
    var rate = ""
    //APK(Watch)
    var strarr: Array<String> = Array()
    var heartRate_int = ""
    
    //APK(Airpot)
    let APP_airpot = CMHeadphoneMotionManager()
    var timestampArray : Array<Double> = []
    var count : Int = 0
    
    var string = ""
    
    var lastmessage : CFAbsoluteTime=0
    var vectorvalue : String=""
    var wcsession : WCSession!
    var strarr_airpot: Array<String> = Array()

    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    
    @IBOutlet weak var rxLabel: UILabel!
    @IBOutlet weak var ryLabel: UILabel!
    @IBOutlet weak var rzLabel: UILabel!
    @IBOutlet weak var mxLabel: UILabel!
    @IBOutlet weak var myLabel: UILabel!
    @IBOutlet weak var mzLabel: UILabel!
    
    @IBOutlet weak var accxLabel: UILabel!
    @IBOutlet weak var accyLabel: UILabel!
    @IBOutlet weak var acczLabel: UILabel!
    
    @IBOutlet weak var gyroxLabel: UILabel!
    @IBOutlet weak var gyroyLabel: UILabel!
    @IBOutlet weak var gyrozLabel: UILabel!
    
    @IBOutlet weak var stepCount: UILabel!
    @IBOutlet weak var distance: UILabel!
    
    @IBOutlet weak var watchGyrox: UILabel!
    @IBOutlet weak var watchGyroy: UILabel!
    @IBOutlet weak var watchGyroz: UILabel!
    @IBOutlet weak var watchAccx: UILabel!
    @IBOutlet weak var watchAccy: UILabel!
    @IBOutlet weak var watchAccz: UILabel!
    
    
    @IBOutlet weak var airpotGyrox: UILabel!
    @IBOutlet weak var airpotGyroy: UILabel!
    @IBOutlet weak var airpotGyroz: UILabel!
    @IBOutlet weak var airpotAccx: UILabel!
    @IBOutlet weak var airpotAccy: UILabel!
    @IBOutlet weak var airpotAccz: UILabel!
    
    @IBOutlet weak var heartrate: UILabel!
    
    // constants for collecting data
    let numSensor = 16
    let GYRO_TXT = 0
    let GYRO_UNCALIB_TXT = 1
    let ACCE_TXT = 2
    let LINACCE_TXT = 3
    let GRAVITY_TXT = 4
    let MAGNET_TXT = 5
    let MAGNET_UNCALIB_TXT = 6
    let GAME_RV_TXT = 7
    let GPS_TXT = 8
    let STEP_TXT = 9
    let HEADING_TXT = 10
    let HEIGHT_TXT = 11
    let PRESSURE_TXT = 12
    let BATTERY_TXT = 13
    let AIRPOT_TXT = 14
    let WATCH_TXT = 15
    
    let sampleFrequency: TimeInterval = 200
    let gravity: Double = 9.81
    let defaultValue: Double = 0.0
    var isRecording: Bool = false
    
    
    // various motion managers and queue instances
    let locationManager = CLLocationManager()
    let motionManager = CMMotionManager()
    let pedoMeter = CMPedometer()
    let altimeter = CMAltimeter()
    let customQueue: DispatchQueue = DispatchQueue(label: "leesangjun.me")
    
    // variables for measuring time in iOS clock
    var recordingTimer: Timer = Timer()
    var batteryLevelTimer: Timer = Timer()
    var secondCounter: Int64 = 0 {
        didSet {
            statusLabel.text = interfaceIntTime(second: secondCounter)
        }
    }
    //let mulSecondToNanoSecond: Double = 1000000000
    let mulSecondToNanoSecond: Double = 1000
    
    // text file input & output
    var fileHandlers = [FileHandle]()
    var fileURLs = [URL]()
    let DeviceInfo = UIDevice.current.name
    
    let now = Date()
    
    var fileNames: [String] = ["gyro.txt",
                               "gyro_uncalib.txt",
                               "acce.txt",
                               "linacce.txt",
                               "gravity.txt",
                               "magnet.txt",
                               "magnet_uncalib.txt",
                               "game_rv.txt",
                               "gps.txt",
                               "step.txt",
                               "heading.txt",
                               "height.txt",
                               "pressure.txt",
                               "battery.txt",
                               "airpot.txt",
                               "watch.text"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let session=WCSession.default
        
        session.delegate=self
        session.activate()
        
        
   
                    
      
        //heartrate.text = rate
        
        // default device setting
        statusLabel.text = "Ready"
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.gyroUpdateInterval = 0.2
        
        // define Core Location manager setting
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        // define Core Motion manager setting
        customQueue.async {
            self.startIMUUpdate()
            self.startPedometerUpdate()
            self.startAltimeterUpdate()
            self.startBatteryLevelUpdate()
        }
        startTimer()
        
        APP_airpot.delegate = self

        guard APP_airpot.isDeviceMotionAvailable else { return }
        APP_airpot.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {[weak self] motion, error  in
            guard let motion = motion, error == nil else { return }
            self?.updateLabel_Airpot(motion)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
        customQueue.sync {
            stopIMUUpdate()
           
        }
        stopTimer()
        pedoMeter.stopUpdates()
        altimeter.stopRelativeAltitudeUpdates()
    }
    
    
    // when the Start/Stop button is pressed
    @IBAction func startStopButtonPressed(_ sender: UIButton) {
        if (self.isRecording == false) {
            
            // start GPS/IMU data recording
            customQueue.async {
                if (self.createFiles()) {
                    DispatchQueue.main.async {
                        // reset timer
                        self.secondCounter = 0
                        self.recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (Timer) -> Void in
                            self.secondCounter += 1
                        })
                        
                        // update UI
                        self.startStopButton.setTitle("Stop", for: .normal)
                        
                        // make sure the screen won't lock
                        UIApplication.shared.isIdleTimerDisabled = true
                    }
                    self.isRecording = true
                } else {
                    self.errorMsg(msg: "Failed to create the file")
                    return
                }
            }
        } else {
            
            // stop recording and share the recorded text file
            if (recordingTimer.isValid) {
                recordingTimer.invalidate()
            }
            if (batteryLevelTimer.isValid) {
                batteryLevelTimer.invalidate()
            }
            
            customQueue.async {
                self.isRecording = false
                if (self.fileHandlers.count == self.numSensor) {
                    for handler in self.fileHandlers {
                        handler.closeFile()
                    }
                    DispatchQueue.main.async {
                        let activityVC = UIActivityViewController(activityItems: self.fileURLs, applicationActivities: nil)
                        self.present(activityVC, animated: true, completion: nil)
                    }
                }
            }
            
            // initialize UI on the screen
            self.latitudeLabel.text = String(format:"%.3f", self.defaultValue)
            self.longitudeLabel.text = String(format:"%.3f", self.defaultValue)
        
            self.altitudeLabel.text = String(format:"%.2f", self.defaultValue)
          
            self.rxLabel.text = String(format:"%.3f", self.defaultValue)
            self.ryLabel.text = String(format:"%.3f", self.defaultValue)
            self.rzLabel.text = String(format:"%.3f", self.defaultValue)
            self.mxLabel.text = String(format:"%.3f", self.defaultValue)
            self.myLabel.text = String(format:"%.3f", self.defaultValue)
            self.mzLabel.text = String(format:"%.3f", self.defaultValue)
            
            self.accxLabel.text = String(format:"%.3f", self.defaultValue)
            self.accyLabel.text = String(format:"%.3f", self.defaultValue)
            self.acczLabel.text = String(format:"%.3f", self.defaultValue)
            
            self.gyroxLabel.text = String(format:"%.3f", self.defaultValue)
            self.gyroyLabel.text = String(format:"%.3f", self.defaultValue)
            self.gyrozLabel.text = String(format:"%.3f", self.defaultValue)
            
            self.stepCount.text = String(format:"%04d", self.defaultValue)
            self.distance.text = String(format:"%.1f", self.defaultValue)
            
            self.startStopButton.setTitle("Start", for: .normal)
            self.statusLabel.text = "Ready"
            
            // resume screen lock
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    //Session Active From SessionActivationState
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState ,error: Error?) {
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    }
    func session(_ session:WCSession,didReceiveMessage message:[String:Any])
    {
        if let value=message["watch"] as? String{
            vectorvalue=value
            strarr.append(value)
            updateLabel_Watch()
        }
//        if let watchgyro = message["watchGyro"] as? String{
//            print("Gyro : "  + watchgyro)
//        }
//        if let watchacc = message["watchAcc"] as? String{
//            print("Acc : " + watchacc)
//        }
        APP_airpot.delegate = self
        
        guard APP_airpot.isDeviceMotionAvailable else { return }
        APP_airpot.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {[weak self] motion, error  in
            guard let motion = motion, error == nil else { return }
            self?.updateLabel_Airpot(motion)
        })
        
        
    }
    func updateLabel_Watch()
    {
        let line = self.vectorvalue
        let seperator = line.components(separatedBy: ",")
        DispatchQueue.main.async
        {

            self.watchAccx.text = seperator[1]
            self.watchAccy.text = seperator[2]
            self.watchAccz.text = seperator[3]
            self.watchGyrox.text = seperator[4]
            self.watchGyroy.text = seperator[5]
            self.watchGyroz.text = seperator[6]
            self.heartrate.text = seperator[7]
            print(self.vectorvalue)
        }
        // custom queue to save GPS location data
        self.customQueue.async {
            if ((self.fileHandlers.count == self.numSensor) && self.isRecording) {
                let watchData = ("\(seperator[0]),\(seperator[1]),\(seperator[2]),\(seperator[3]),\(seperator[4]),\(seperator[5]),\(seperator[6]),\(seperator[7])")
                if let locationDataToWrite = watchData.data(using: .utf8) {
                    self.fileHandlers[self.WATCH_TXT].write(locationDataToWrite)
                } else {
                    os_log("Failed to write data record", log: OSLog.default, type: .fault)
                }
            }
        }
    }
    
    func updateLabel_Airpot(_ data: CMDeviceMotion) {
        //print(data)
        let formatter = DateFormatter()
        formatter.dateFormat="yMMddHmss.SSSS"
//        self.string = """
//            Quaternion:
//                x: \(data.attitude.quaternion.x)
//                y: \(data.attitude.quaternion.y)
//                z: \(data.attitude.quaternion.z)
//                w: \(data.attitude.quaternion.w)
//            Attitude:
//                pitch: \(data.attitude.pitch)
//                roll: \(data.attitude.roll)
//                yaw: \(data.attitude.yaw)
//            Gravitational Acceleration:
//                x: \(data.gravity.x)
//                y: \(data.gravity.y)
//                z: \(data.gravity.z)
//            Rotation Rate:
//                x: \(data.rotationRate.x)
//                y: \(data.rotationRate.y)
//                z: \(data.rotationRate.z)
//            Acceleration:
//                x: \(data.userAcceleration.x)
//                y: \(data.userAcceleration.y)
//                z: \(data.userAcceleration.z)
//            Magnetic Field:
//                field: \(data.magneticField.field)
//                accuracy: \(data.magneticField.accuracy)
//            Heading:
//                \(data.heading)
//            """
        let strings_x = String(format : "%.3f",data.gravity.x)
        let strings_y = String(format : "%.3f",data.gravity.y)
        let strings_z = String(format : "%.3f",data.gravity.z)
        
        self.airpotGyrox.text = strings_x
        self.airpotGyroy.text = strings_y
        self.airpotGyroz.text = strings_z
        
        self.airpotAccx.text = String(format : "%.3f",data.userAcceleration.x)
        self.airpotAccy.text = String(format : "%.3f",data.userAcceleration.y)
        self.airpotAccz.text = String(format : "%.3f",data.userAcceleration.z)
        
        //self.string = formatter.string(from: currentdatetime)+","+strings_x+","+strings_y+","+strings_z+";\n"
        let timestamp = Date().timeIntervalSince1970
        // custom queue to save GPS location data
        self.customQueue.async {
            if ((self.fileHandlers.count == self.numSensor) && self.isRecording) {
                let airpotData = String(format: "%.3f %.3f %.3f %.3f %.3f %.3f %.3f \n",
                                          timestamp,
                                        data.gravity.x,
                                        data.gravity.y,
                                        data.gravity.z,
                                        data.userAcceleration.x,
                                        data.userAcceleration.y,
                                        data.userAcceleration.z
                                         )
                if let locationDataToWrite = airpotData.data(using: .utf8) {
                    self.fileHandlers[self.AIRPOT_TXT].write(locationDataToWrite)
                } else {
                    os_log("Failed to write data record", log: OSLog.default, type: .fault)
                }
            }
        }
    }
    
    // define startUpdatingLocation() function
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // optional binding for safety
        if let latestLocation = manager.location {
         //   let timestamp = latestLocation.timestamp.timeIntervalSince1970 * self.mulSecondToNanoSecond
            let timestamp = Date().timeIntervalSince1970
            let latitude = latestLocation.coordinate.latitude
            let longitude = latestLocation.coordinate.longitude
            let horizontalAccuracy = latestLocation.horizontalAccuracy
            let altitude = latestLocation.altitude
            let verticalAccuracy = latestLocation.verticalAccuracy
            var buildingFloor = -9
            if let temp = latestLocation.floor {
                buildingFloor = temp.level
            }
            
            // dispatch queue to display UI
            DispatchQueue.main.async {
                self.latitudeLabel.text = String(format:"%.3f", latitude)
                self.longitudeLabel.text = String(format:"%.3f", longitude)
                self.altitudeLabel.text = String(format:"%.2f", altitude)
            }
            
            // custom queue to save GPS location data
            self.customQueue.async {
                if ((self.fileHandlers.count == self.numSensor) && self.isRecording) {
                    let locationData = String(format: "%.0f %.6f %.6f %.6f %.6f %.6f %.6f \n",
                                              timestamp,
                                              latitude,
                                              longitude,
                                              horizontalAccuracy,
                                              altitude,
                                              verticalAccuracy,
                                              buildingFloor)
                    if let locationDataToWrite = locationData.data(using: .utf8) {
                        self.fileHandlers[self.GPS_TXT].write(locationDataToWrite)
                    } else {
                        os_log("Failed to write data record", log: OSLog.default, type: .fault)
                    }
                }
            }
        }
    }
    
    
    // define didFailWithError function
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("GPS Error => \(error.localizedDescription)")
    }
    
    
    // define startIMUUpdate() function
    private func startIMUUpdate() {
        
        
        // define IMU update interval up to 200 Hz (in real, iOS can only support up to 100 Hz)
        motionManager.deviceMotionUpdateInterval = 1.0 / sampleFrequency
        motionManager.showsDeviceMovementDisplay = true
        motionManager.accelerometerUpdateInterval = 1.0 / sampleFrequency
        motionManager.gyroUpdateInterval = 1.0 / sampleFrequency
        motionManager.magnetometerUpdateInterval = 1.0 / sampleFrequency
        
        
        // 1) update device motion
        if (!motionManager.isDeviceMotionActive)
        {
            motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: OperationQueue.main) { (motion: CMDeviceMotion?, error: Error?) in
                
                // optional binding for safety
                if let deviceMotion = motion {
                    //let timestamp = Date().timeIntervalSince1970 * self.mulSecondToNanoSecond
                    //let timestamp = deviceMotion.timestamp * self.mulSecondToNanoSecond
                    let timestamp = Date().timeIntervalSince1970 * self.mulSecondToNanoSecond
                    let deviceOrientationRx = deviceMotion.attitude.pitch
                    let deviceOrientationRy = deviceMotion.attitude.roll
                    let deviceOrientationRz = deviceMotion.attitude.yaw
                    
                    let deviceOrientationQx = deviceMotion.attitude.quaternion.x
                    let deviceOrientationQy = deviceMotion.attitude.quaternion.y
                    let deviceOrientationQz = deviceMotion.attitude.quaternion.z
                    let deviceOrientationQw = deviceMotion.attitude.quaternion.w
                    
                    let processedGyroDataX = deviceMotion.rotationRate.x
                    let processedGyroDataY = deviceMotion.rotationRate.y
                    let processedGyroDataZ = deviceMotion.rotationRate.z
                    
                    let gravityGx = deviceMotion.gravity.x * self.gravity
                    let gravityGy = deviceMotion.gravity.y * self.gravity
                    let gravityGz = deviceMotion.gravity.z * self.gravity
                    
                    let userAccelDataX = deviceMotion.userAcceleration.x * self.gravity
                    let userAccelDataY = deviceMotion.userAcceleration.y * self.gravity
                    let userAccelDataZ = deviceMotion.userAcceleration.z * self.gravity
                    
                    let magneticFieldX = deviceMotion.magneticField.field.x
                    let magneticFieldY = deviceMotion.magneticField.field.y
                    let magneticFieldZ = deviceMotion.magneticField.field.z
                    
                    let deviceHeadingAngle = deviceMotion.heading
                    
                    // dispatch queue to display UI
                    DispatchQueue.main.async {
                        self.rxLabel.text = String(format:"%.3f", deviceOrientationRx)
                        self.ryLabel.text = String(format:"%.3f", deviceOrientationRy)
                        self.rzLabel.text = String(format:"%.3f", deviceOrientationRz)
                        
                        self.mxLabel.text = String(format:"%.3f", magneticFieldX)
                        self.myLabel.text = String(format:"%.3f", magneticFieldY)
                        self.mzLabel.text = String(format:"%.3f", magneticFieldZ)
                
                    }
                    
                    // custom queue to save IMU text data
                    self.customQueue.async {
                        if ((self.fileHandlers.count == self.numSensor) && self.isRecording) {
                            
                            // the device orientation expressed in the quaternion format
                            let attitudeData = String(format: "%.0f %.6f %.6f %.6f %.6f \n",
                                                      timestamp,
                                                      deviceOrientationQx,
                                                      deviceOrientationQy,
                                                      deviceOrientationQz,
                                                      deviceOrientationQw)
                            if let attitudeDataToWrite = attitudeData.data(using: .utf8) {
                                self.fileHandlers[self.GAME_RV_TXT].write(attitudeDataToWrite)
                            } else {
                                os_log("Failed to write data record", log: OSLog.default, type: .fault)
                            }
                            
                            // the unbiased rotation rate
                            let processedGyroData = String(format: "%.0f %.6f %.6f %.6f \n",
                                                           timestamp,
                                                           processedGyroDataX,
                                                           processedGyroDataY,
                                                           processedGyroDataZ)
                            if let processedGyroDataToWrite = processedGyroData.data(using: .utf8) {
                                self.fileHandlers[self.GYRO_TXT].write(processedGyroDataToWrite)
                            } else {
                                os_log("Failed to write data record", log: OSLog.default, type: .fault)
                            }
                            
                            // the current gravity vector
                            let gravityData = String(format: "%.0f %.6f %.6f %.6f \n",
                                                     timestamp,
                                                     gravityGx,
                                                     gravityGy,
                                                     gravityGz)
                            if let gravityDataToWrite = gravityData.data(using: .utf8) {
                                self.fileHandlers[self.GRAVITY_TXT].write(gravityDataToWrite)
                            } else {
                                os_log("Failed to write data record", log: OSLog.default, type: .fault)
                            }
                            
                            // the user-generated acceleration vector (without gravity)
                            let userAccelData = String(format: "%.0f %.6f %.6f %.6f \n",
                                                       timestamp,
                                                       userAccelDataX,
                                                       userAccelDataY,
                                                       userAccelDataZ)
                            if let userAccelDataToWrite = userAccelData.data(using: .utf8) {
                                self.fileHandlers[self.LINACCE_TXT].write(userAccelDataToWrite)
                            } else {
                                os_log("Failed to write data record", log: OSLog.default, type: .fault)
                            }
                            
                            // the current magnetic field vector
                            let magneticData = String(format: "%.0f %.6f %.6f %.6f \n",
                                                      timestamp,
                                                      magneticFieldX,
                                                      magneticFieldY,
                                                      magneticFieldZ)
                            if let magneticDataToWrite = magneticData.data(using: .utf8) {
                                self.fileHandlers[self.MAGNET_TXT].write(magneticDataToWrite)
                            } else {
                                os_log("Failed to write data record", log: OSLog.default, type: .fault)
                            }
                            
                            // the heading angle (degrees) relative to the reference frame
                            let headingAngleData = String(format: "%.0f %.6f \n",
                                                          timestamp,
                                                          deviceHeadingAngle)
                            if let headingAngleDataToWrite = headingAngleData.data(using: .utf8) {
                                self.fileHandlers[self.HEADING_TXT].write(headingAngleDataToWrite)
                            } else {
                                os_log("Failed to write data record", log: OSLog.default, type: .fault)
                            }
                        }
                    }
                }
            }
        }
        
        
        // 2) update raw acceleration value
        if (!motionManager.isAccelerometerActive) {
            motionManager.startAccelerometerUpdates(to: OperationQueue.main) { (motion: CMAccelerometerData?, error: Error?) in
                
                // optional binding for safety
                if let accelerometerData = motion {
                    //let timestamp = Date().timeIntervalSince1970 * self.mulSecondToNanoSecond
                    //let timestamp = accelerometerData.timestamp * self.mulSecondToNanoSecond
                    let timestamp = Date().timeIntervalSince1970
                    let rawAccelDataX = accelerometerData.acceleration.x * self.gravity
                    let rawAccelDataY = accelerometerData.acceleration.y * self.gravity
                    let rawAccelDataZ = accelerometerData.acceleration.z * self.gravity
                    
                    // dispatch queue to display UI
                    DispatchQueue.main.async {
                        self.accxLabel.text = String(format:"%.3f", rawAccelDataX)
                        self.accyLabel.text = String(format:"%.3f", rawAccelDataY)
                        self.acczLabel.text = String(format:"%.3f", rawAccelDataZ)
                    }
                    
                    // custom queue to save IMU text data
                    self.customQueue.async {
                        if ((self.fileHandlers.count == self.numSensor) && self.isRecording) {
                            let rawAccelData = String(format: "%.0f %.6f %.6f %.6f \n",
                                                      timestamp,
                                                      rawAccelDataX,
                                                      rawAccelDataY,
                                                      rawAccelDataZ)
                            if let rawAccelDataToWrite = rawAccelData.data(using: .utf8) {
                                self.fileHandlers[self.ACCE_TXT].write(rawAccelDataToWrite)
                            } else {
                                os_log("Failed to write data record", log: OSLog.default, type: .fault)
                            }
                        }
                    }
                }
            }
        }
        
        
        // 3) update raw gyroscope value
        if (!motionManager.isGyroActive) {
            motionManager.startGyroUpdates(to: OperationQueue.main) { (motion: CMGyroData?, error: Error?) in
                
                // optional binding for safety
                if let gyroData = motion {
                    //let timestamp = Date().timeIntervalSince1970 * self.mulSecondToNanoSecond
                   // let timestamp = gyroData.timestamp * self.mulSecondToNanoSecond
                    let timestamp = Date().timeIntervalSince1970
                    let rawGyroDataX = gyroData.rotationRate.x
                    let rawGyroDataY = gyroData.rotationRate.y
                    let rawGyroDataZ = gyroData.rotationRate.z
                    
                    // dispatch queue to display UI
                    DispatchQueue.main.async {
                        self.gyroxLabel.text = String(format:"%.3f", rawGyroDataX)
                        self.gyroyLabel.text = String(format:"%.3f", rawGyroDataY)
                        self.gyrozLabel.text = String(format:"%.3f", rawGyroDataZ)
                    }
                    
                    // custom queue to save IMU text data
                    self.customQueue.async {
                        if ((self.fileHandlers.count == self.numSensor) && self.isRecording) {
                            let rawGyroData = String(format: "%.0f %.6f %.6f %.6f \n",
                                                     timestamp,
                                                     rawGyroDataX,
                                                     rawGyroDataY,
                                                     rawGyroDataZ)
                            if let rawGyroDataToWrite = rawGyroData.data(using: .utf8) {
                                self.fileHandlers[self.GYRO_UNCALIB_TXT].write(rawGyroDataToWrite)
                            } else {
                                os_log("Failed to write data record", log: OSLog.default, type: .fault)
                            }
                        }
                    }
                }
            }
        }
        
        
        // 4) update raw magnetometer data
        if (!motionManager.isMagnetometerActive) {
            motionManager.startMagnetometerUpdates(to: OperationQueue.main) { (motion: CMMagnetometerData?, error: Error?) in
                
                // optional binding for safety
                if let magnetometerData = motion {
                    //let timestamp = Date().timeIntervalSince1970 * self.mulSecondToNanoSecond
                   // let timestamp = magnetometerData.timestamp * self.mulSecondToNanoSecond
                    let timestamp = Date().timeIntervalSince1970
                    let rawMagnetDataX = magnetometerData.magneticField.x
                    let rawMagnetDataY = magnetometerData.magneticField.y
                    let rawMagnetDataZ = magnetometerData.magneticField.z
                    
                    // custom queue to save IMU text data
                    self.customQueue.async {
                        if ((self.fileHandlers.count == self.numSensor) && self.isRecording) {
                            let rawMagnetData = String(format: "%.0f %.6f %.6f %.6f \n",
                                                       timestamp,
                                                       rawMagnetDataX,
                                                       rawMagnetDataY,
                                                       rawMagnetDataZ)
                            if let rawMagnetDataToWrite = rawMagnetData.data(using: .utf8) {
                                self.fileHandlers[self.MAGNET_UNCALIB_TXT].write(rawMagnetDataToWrite)
                            } else {
                                os_log("Failed to write data record", log: OSLog.default, type: .fault)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    private func startAirPotUpdate()
    {
        
    }
    
    
    // define startPedometerUpdate() function
    private func startPedometerUpdate() {
        
        // check the step counter and distance are available
        if (CMPedometer.isStepCountingAvailable() && CMPedometer.isDistanceAvailable()) {
            pedoMeter.startUpdates(from: Date()) { (motion: CMPedometerData?, error: Error?) in
                
                // optional binding for safety
                if let pedometerData = motion {
                    let timestamp = Date().timeIntervalSince1970
                    let stepCounter = pedometerData.numberOfSteps.intValue
                    var distance: Double = -100
                    if let temp = pedometerData.distance {
                        distance = temp.doubleValue
                    }
                    
                    // dispatch queue to display UI
                    DispatchQueue.main.async {
                        self.stepCount.text = String(format:"%04d", stepCounter)
                        self.distance.text = String(format:"%.1f", distance)
                    }
                    
                    // custom queue to save pedometer data
                    self.customQueue.async {
                        if ((self.fileHandlers.count == self.numSensor) && self.isRecording) {
                            let pedoData = String(format: "%.0f %04d %.3f \n",
                                                  timestamp,
                                                  stepCounter,
                                                  distance)
                            if let pedoDataToWrite = pedoData.data(using: .utf8) {
                                self.fileHandlers[self.STEP_TXT].write(pedoDataToWrite)
                            } else {
                                os_log("Failed to write data record", log: OSLog.default, type: .fault)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    // define startAltimeterUpdate() function
    private func startAltimeterUpdate() {
        
        // check barometric sensor information are available
        if (CMAltimeter.isRelativeAltitudeAvailable()) {
            altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main) { (motion: CMAltitudeData?, error: Error?) in
                
                // optional binding for safety
                if let barometerData = motion {
                    //let timestamp = Date().timeIntervalSince1970 * self.mulSecondToNanoSecond
                    let timestamp = barometerData.timestamp * self.mulSecondToNanoSecond
                    let relativeAltitude = barometerData.relativeAltitude.doubleValue
                    let pressure = barometerData.pressure.doubleValue
                    
                    // custom queue to save barometric text data
                    self.customQueue.async {
                        if ((self.fileHandlers.count == self.numSensor) && self.isRecording) {
                            
                            // the change in altitude (in meters) since the first reported event
                            let relativeAltitudeData = String(format: "%.0f %.6f \n",
                                                              timestamp,
                                                              relativeAltitude)
                            if let relativeAltitudeDataToWrite = relativeAltitudeData.data(using: .utf8) {
                                self.fileHandlers[self.HEIGHT_TXT].write(relativeAltitudeDataToWrite)
                            } else {
                                os_log("Failed to write data record", log: OSLog.default, type: .fault)
                            }
                            
                            // the recorded pressure (in kilopascals)
                            let pressureData = String(format: "%.0f %.6f \n",
                                                      timestamp,
                                                      pressure)
                            if let pressureDataToWrite = pressureData.data(using: .utf8) {
                                self.fileHandlers[self.PRESSURE_TXT].write(pressureDataToWrite)
                            } else {
                                os_log("Failed to write data record", log: OSLog.default, type: .fault)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    // define startBatteryLevelUpdate() function
    private func startBatteryLevelUpdate() {
        DispatchQueue.main.async {
            self.batteryLevelTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (Timer) -> Void in
                
                let timestamp = Date().timeIntervalSince1970 * self.mulSecondToNanoSecond
                let batteryLevel = UIDevice.current.batteryLevel
                
                // custom queue to save battery level text data
                self.customQueue.async {
                    if ((self.fileHandlers.count == self.numSensor) && self.isRecording) {
                        
                        // the battery charge level for the device
                        let batteryLevelData = String(format: "%.0f %.6f \n",
                                                      timestamp,
                                                      batteryLevel)
                        if let batteryLevelDataToWrite = batteryLevelData.data(using: .utf8) {
                            self.fileHandlers[self.BATTERY_TXT].write(batteryLevelDataToWrite)
                        } else {
                            os_log("Failed to write data record", log: OSLog.default, type: .fault)
                        }
                    }
                }
            })
        }
    }
    
    
    private func stopIMUUpdate() {
        if (motionManager.isDeviceMotionActive) {
            motionManager.stopDeviceMotionUpdates()
        }
        if (motionManager.isAccelerometerActive) {
            motionManager.stopAccelerometerUpdates()
        }
        if (motionManager.isGyroActive) {
            motionManager.stopGyroUpdates()
        }
        if (motionManager.isMagnetometerActive) {
            motionManager.stopMagnetometerUpdates()
        }
    }
    
    
    // some useful functions
    private func errorMsg(msg: String) {
        DispatchQueue.main.async {
            let fileAlert = UIAlertController(title: "APPLE DATA LOGGER _ ALL", message: msg, preferredStyle: .alert)
            fileAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(fileAlert, animated: true, completion: nil)
        }
    }
    
    
    private func createFiles() -> Bool {
        
        // initialize file handlers
        self.fileHandlers.removeAll()
        self.fileURLs.removeAll()
        
        // create each GPS/IMU sensor text files
        let now = Date()

        let date = DateFormatter()
        date.locale = Locale(identifier: "ko_kr")
        date.timeZone = TimeZone(abbreviation: "KST") // "2018-03-21 18:07:27"
        //date.timeZone = TimeZone(abbreviation: "NZST") // "2018-03-21 22:06:39"
        date.dateFormat = "yyyyMMdd HHmmss"

        let krs = date.string(from: now)
        
        let startHeader = ""
        for i in 0...(self.numSensor - 1) {
            var url = URL(fileURLWithPath: NSTemporaryDirectory())
            url.appendPathComponent(krs+UIDevice.current.name+fileNames[i])
            self.fileURLs.append(url)
            
            // delete previous text files
            if (FileManager.default.fileExists(atPath: url.path)) {
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {
                    os_log("cannot remove previous file", log:.default, type:.error)
                    return false
                }
            }
            
            // create new text files
            if (!FileManager.default.createFile(atPath: url.path, contents: startHeader.data(using: String.Encoding.utf8), attributes: nil)) {
                self.errorMsg(msg: "cannot create file \(self.fileNames[i])")
                return false
            }
            
            // assign new file handlers
            let fileHandle: FileHandle? = FileHandle(forWritingAtPath: url.path)
            if let handle = fileHandle {
                self.fileHandlers.append(handle)
            } else {
                return false
            }
        }
        
        // write current recording time information
        let timeHeader = "# Created at \(timeToString()) in KINLAB \n"
        for i in 0...(self.numSensor - 1) {
            if let timeHeaderToWrite = timeHeader.data(using: .utf8) {
                self.fileHandlers[i].write(timeHeaderToWrite)
            } else {
                os_log("Failed to write data record", log: OSLog.default, type: .fault)
                return false
            }
        }
        
        // return true if everything is alright
        return true
    }
    
    
    
    //UTIL
    
    func interfaceIntTime(second: Int64) -> String {
        var input = second
        let hours: Int64 = input / 3600
        input = input % 3600
        let mins: Int64 = input / 60
        let secs: Int64 = input % 60
        
        guard second >= 0 else {
            fatalError("Second can not be negative: \(second)");
        }
        
        return String(format: "%02d:%02d:%02d", hours, mins, secs)
    }

    func timeToString() -> String {
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let sec = calendar.component(.second, from: date)
        return String(format:"%04d-%02d-%02d %02d:%02d:%02d in PDT", year, month, day, hour, minute, sec)
    }

}
