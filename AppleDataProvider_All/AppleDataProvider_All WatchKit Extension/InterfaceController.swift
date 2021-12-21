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

class InterfaceController: WKInterfaceController,WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    func session(_ session:WCSession,didReceiveUserInfo userInfo:[String:Any]=[:])
    {
        
    }
    
    @IBOutlet weak var stringlabel: WKInterfaceLabel!
    let session = WCSession.default
    var n = 0
    var bupdate = false
    var accdatas = String()
    let motionManager = CMMotionManager()
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        session.delegate=self
        session.activate()
    }
    
    override func willActivate() {
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
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }
    @IBAction func UpdateButtonPress() {
        bupdate=(!bupdate)
        //motionManager.accelerometerUpdateInterval=1
        UpdateDatas()
    }
    func send(heartRate: Int) {
        guard WCSession.default.isReachable else {
            print("Phone is not reachable")
            return
        }
        WCSession.default.sendMessage(["Heart Rate" : heartRate], replyHandler: nil) { error in
            print("Error sending message to phone: \(error.localizedDescription)")
        }
     }
    
    func UpdateDatas()
    {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.066)
        {
            var datas = ""
            self.motionManager.startGyroUpdates(to: OperationQueue.current!, withHandler: {(data,error)in
            if let data=data
                {
                let currentdatetime=Date()
                let x=String(format: "%0.3f",data.rotationRate.x)
                let y=String(format: "%0.3f",data.rotationRate.y)
                let z=String(format: "%0.3f",data.rotationRate.z)
                
                let formatter = DateFormatter()
                formatter.dateFormat="yMMddHmss.SSSS"
                self.accdatas += "\(formatter.string(from: currentdatetime)),\(x),\(y),\(z);"
                          
            }
            
            })
            self.motionManager.startAccelerometerUpdates(to: OperationQueue.current!,withHandler:{(data,error)in
                if let data=data
                {

                    let x=String(format: "%0.3f", data.acceleration.x )
                    let y=String(format: "%0.3f", data.acceleration.y )
                    let z=String(format: "%0.3f", data.acceleration.z )
                    
                    self.stringlabel.setText("X:\(x) Y:\(y) Z:\(z)")
                    self.accdatas += ",\(x),\(y),\(z);\n"
                    // If the message failed to send, queue it up for future transfer
                    self.n+=1
                    //if self.n>9
                    //{
                      //  self.n=0
                        let sendmessage=self.accdatas
                        self.accdatas=""
                        print(sendmessage)
//                        self.session.sendMessage(["watch":sendmessage as String], replyHandler: nil,errorHandler: nil)
                    self.session.sendMessage(["watchGyro":sendmessage as String], replyHandler: nil,errorHandler: nil)
                    //}
                }
            })
        
        }
    }
}
