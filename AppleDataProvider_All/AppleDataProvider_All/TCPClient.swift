//
//  TCPClient.swift
//  AppleDataProvider_All
//
//  Created by SangBin Jeon on 2022/01/10.
//

import Foundation
import Network
import HealthKit
class TCPClient
{
    init(hostName:String, port:Int)
    {
        let host = NWEndpoint.Host(hostName)
        let port = NWEndpoint.Port("\(port)")!
        self.connection = NWConnection(host: host, port: port, using:.tcp)
        print("\(hostName)::port\(port)")
        NSLog("init")
    }
    let connection:NWConnection
    
    func start()
    {
        self.connection.stateUpdateHandler = self.didChange(state:)
        self.startReceive()
        self.connection.start(queue: .main)
        self.send(line: "%^&IOS")
        
        print(self.connection.state)
        NSLog("start")
    }
    func stop()
    {
        self.connection.cancel()
    }
    
    private func didChange(state: NWConnection.State)
    {
        switch state{
        case .setup:
            break;
        case .waiting(let error):
            NSLog("is waiting: %@", "\(error)")
        case .preparing:
            break
        case .ready:
            break
        case .failed(let error):
            NSLog("did fail, error : %@", "\(error)")
            self.stop()
        case .cancelled:
            self.stop()
            NSLog("was cancelled")
        @unknown default:
            break
        }
    }
    private func startReceive()
    {
        self.connection.receive(minimumIncompleteLength: 1, maximumLength: 65536)
        { data, _, isDone, error in
            if let data = data, !data.isEmpty
            {
                let datas=String(decoding:data, as: UTF8.self)
                NSLog("did receive, data: %@", datas)
                self.send(line: String(format: "\(datas),%.0f;", Date().timeIntervalSince1970*1000))
                NSLog(String(format: "\(datas),%.0f;", Date().timeIntervalSince1970*1000))
            }
            if let error = error
            {
                NSLog("did receive, error %@", "\(error)")
                self.stop()
                return
            }
            if isDone{
                NSLog("did receive, EOF")
                return
            }
        self.startReceive()
        }
    }
    func send(line: String)
    {
        print(line)
        let data = Data("\(line)".utf8)
        self.connection.send(content: data, completion: NWConnection.SendCompletion.contentProcessed{
            error in if let error = error{
                NSLog("did send, error: %@", "\(error)")
                self.stop()
            }
            else
            {
                NSLog("did send, data: %@", data as NSData)
            }
        })
    }
   
}
