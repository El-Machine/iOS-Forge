//
//
//
//  Created by Alexander Kozin on 21.02.16.
//  Copyright © 2016 El-Machine. All rights reserved.
//

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

extension ELLocationManager {

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if let locationAuthCompletion = self.locationAuthCompletion {
            locationAuthCompletion(status: status)

            logVerbose("ELLocationManager didChangeAuthorizationStatus %i", status.rawValue)
        }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            logVerbose("ELLocationManager didUpdateLocations %@", lastLocation)

            for (receiver , handler) in locationReceivers {
                handler(locotaion: lastLocation)

                logVerbose("ELLocationManager notify %@", receiver)
            }

            sendLocationToAnalyticsService()
        }
    }

    /**
     Override point for customization location sending
     */
    func sendLocationToAnalyticsService() {
        // Override point for customization location sending
        //    CLLocationCoordinate2D coordinate = self.locationManager.location.coordinate;
        //    [Flurry setLatitude:coordinate.latitude
        //              longitude:coordinate.longitude
        //     horizontalAccuracy:location.horizontalAccuracy
        //       verticalAccuracy:location.verticalAccuracy];
    }
}
