//
// SecureImage
//
// Copyright © 2018 Province of British Columbia
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// Created by Jason Leach on 2018-01-11.
//

import Foundation
import Alamofire
import RealmSwift

class NetworkManager {
    
    enum NetworkError: Error {
        case OK
        case NetworkError
        case RequestTimedOut
        case Error(String)
    }

    // singelton
    static let shared = NetworkManager()
    
    private static let host = "www.google.com"
    private let reachabilityManager: NetworkReachabilityManager? = Alamofire.NetworkReachabilityManager(host: NetworkManager.host)
    private(set) internal var isReachableOnEthernetOrWiFi: Bool = false
    private(set) internal var isReachable: Bool = false
    private(set) internal var isReachableOnWWAN: Bool = false
    internal var onReacabilityChanged: ((_ isReachableOnEthernetOrWiFi: Bool) -> Void)?
    
    internal func start() {
        
        reachabilityManager?.listener = { status in
            
            self.updateState()
            
            switch status {
                
            case .notReachable:
                self.updateState()
                self.handleWiFiUnavailable()
                
            case .unknown :
                self.updateState()
                self.handleWiFiUnavailable()
                
            case .reachable(.ethernetOrWiFi):
                self.updateState()
                self.handleWiFiAvailable()
                
            case .reachable(.wwan):
                self.updateState()
                self.handleWiFiUnavailable()
            }
        }
        
        reachabilityManager?.startListening()
    }
    
    private func updateState() {

        if let manager = self.reachabilityManager {
            self.isReachableOnEthernetOrWiFi = manager.isReachableOnEthernetOrWiFi
            self.isReachable = manager.isReachable
            self.isReachableOnWWAN = manager.isReachableOnWWAN
        }
    }
    
    private func handleWiFiUnavailable() {
        
        onReacabilityChanged?(isReachableOnEthernetOrWiFi)
        NotificationCenter.default.post(name: Notification.Name.wifiAvailabilityChanged, object: nil)
    }
    
    private func handleWiFiAvailable() {
        
        onReacabilityChanged?(isReachableOnEthernetOrWiFi)
        NotificationCenter.default.post(name: Notification.Name.wifiAvailabilityChanged, object: nil)
    }
    
    class func processResponse<T>(_ response: Alamofire.DataResponse<T>) -> (T?, Error?) {
        
        if let error = process(statusCode: response.response?.statusCode) {
            return (nil, error)
        }
        
        switch response.result {
        case .success(let value):
            return (value, nil)
            
        case .failure(let error):
            
            switch (response.response?.statusCode) {
            case 200?:
                if response.data?.count == 0 {
                    return (nil, nil)
                }
                return (nil, error)
            default:
                if (error as NSError).code == 2 {
                    return (nil, NetworkError.NetworkError)
                }
                
                return (nil, error)
            }
        }
    }
    
    class func process(statusCode: Int? = nil) -> Error? {
        
        switch (statusCode) {
        case NSURLErrorTimedOut?:
            return NetworkError.RequestTimedOut
            
        case 401?:
            return NetworkError.NetworkError
            
        case 404?:
            return NetworkError.NetworkError
            
        case 405?:
            return NetworkError.NetworkError
            
        default:
            return nil
        }
    }
}
