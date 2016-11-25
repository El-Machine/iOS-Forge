//
// ELLocationManager.swift
//
// Created by Alexander Kozin https://github.com/alkozin
// Copyright (c) 2016 http://el-machine.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import CoreLocation

enum ELLocationManagerLoggingLevel: Int32 {
    case Off
    case Status
    case Verbose
}

typealias ELLocationAuthCompletion = (status: CLAuthorizationStatus) -> ()
typealias ELLocationHandler = (locotaion: CLLocation) -> ()

class ELLocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = ELLocationManager()

    let locationManager = CLLocationManager()

    var locationReceivers = [NSObject: ELLocationHandler]()

    var locationAuthCompletion: ELLocationAuthCompletion?
    private var requestedAuthStatus: CLAuthorizationStatus?

    var loggingLevel = ELLocationManagerLoggingLevel.Verbose

    override init() {
        super.init()
        configureLocationManager()
    }
    
    /**
     Requsts permissions for using location when app is active

     - parameter completion: Authorization completion
     */
    func requestWhenInUseAuthorization(completion: ELLocationAuthCompletion) {
        if (locationAuthCompletion == nil) {
            requestedAuthStatus = .AuthorizedWhenInUse
            if (isStatusCorrectForRequested()) {
                completion(status: requestedAuthStatus!)
            } else {

                //FIXME: nulify block after request
                locationAuthCompletion = completion
                locationManager.requestWhenInUseAuthorization()
            }
        }
    }

    /**
     Requsts permissions for using location every time

     - parameter completion: Authorization completion
     */
    func requestAlwaysAuthorization(completion: ELLocationAuthCompletion) {
        if (locationAuthCompletion == nil) {
            requestedAuthStatus = .AuthorizedAlways
            if (isStatusCorrectForRequested()) {
                completion(status: requestedAuthStatus!)
            } else {

                //FIXME: nulify block after request
                locationAuthCompletion = completion
                locationManager.requestAlwaysAuthorization()
            }
        }
    }

    /**
     Adds object to list of location receivers

     - parameter receiver: Location receiver
     - parameter handler:  Location handler
     */
    func addLocationReceiver(receiver: NSObject, handler: ELLocationHandler?) {
        // Start location updating if it's first receiver
        if locationReceivers.isEmpty {
            locationManager.startUpdatingLocation()

            logStatus("ELLocationManager startUpdatingLocation")
        }

        locationReceivers[receiver] = handler
    }

    /**
     Removes object from list of location receivers

     - parameter receiver: Location receiver
     */
    func removeLocationReceiver(receiver: NSObject) {
        locationReceivers[receiver] = nil

        // Stop location updating if it wat last receiver
        if locationReceivers.isEmpty {
            locationManager.stopUpdatingLocation()

            logStatus("ELLocationManager stopUpdatingLocation")
        }
    }

    private func isStatusCorrectForRequested() -> Bool {
        let correct: Bool
        let status = CLLocationManager.authorizationStatus()

        switch (requestedAuthStatus!) {
        case .AuthorizedWhenInUse:
            correct = status == .AuthorizedWhenInUse;
        case .AuthorizedAlways:
            correct = status == .AuthorizedWhenInUse ||
                status == .AuthorizedAlways;

        default:
            correct = false;
        }

        return correct
    }

    func configureLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 100
        locationManager.pausesLocationUpdatesAutomatically = true
    }

    func logStatus(items: Any...) {
        log(.Status, items: items)
    }

    func logVerbose(items: Any...) {
        log(.Verbose, items: items)
    }

    func log(level: ELLocationManagerLoggingLevel, items: Any...) {
        if (loggingLevel.rawValue >= level.rawValue) {
            print(items)
        }
    }

}
