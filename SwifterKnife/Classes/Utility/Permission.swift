//
//  Permission.swift
//  SwifterKnife
//
//  Created by liyang on 2021/10/19.
//

import UIKit
import Photos
import CoreLocation

public enum Permission {
    public enum AuthorizationStatus {
        case authorized
        case denied
        case restricted
        case notSupport
        
        public enum LocationWay {
            case always
            case whenInUse
        }
        case locaiton(LocationWay)
        
        fileprivate init?(locationStatus: CLAuthorizationStatus) {
            switch locationStatus {
            case .authorizedAlways:
                self = .locaiton(.always)
            case .authorizedWhenInUse:
                self = .locaiton(.whenInUse)
            case .restricted:
                self = .restricted
            case .denied:
                self = .denied
            default: return nil
            }
        }
    }
    public typealias CompletionHandler = (_ status: AuthorizationStatus, _ isFirst: Bool) -> Void
    
    // MARK: - Photo
    public static func requestPhoto(completion: @escaping CompletionHandler) {
        assert(for: .photoUsage)
        _requestPhoto { status, isFirst in
            DispatchQueue.main.async {
                completion(status, isFirst)
            }
        }
    }

    private static func _requestPhoto(completion: @escaping CompletionHandler) {
        assert(for: .photoUsage)
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            completion(.notSupport, false)
            return
        }
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .restricted:
            completion(.restricted, false)
        case .denied:
            completion(.denied, false)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                var tmpStatus: AuthorizationStatus = .authorized
                if newStatus == .restricted {
                    tmpStatus = .restricted
                } else if newStatus == .denied {
                    tmpStatus = .denied
                }
                completion(tmpStatus, true)
            }
        default:
            completion(.authorized, false)
        }
    }
    
    // MARK: - Camera
    public static func requestCamera(completion: @escaping CompletionHandler) {
        assert(for: .camera)
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            completion(.notSupport, false)
            return
        }
        
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .restricted:
            completion(.restricted, false)
        case .denied:
            completion(.denied, false)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                let tmpStatus: AuthorizationStatus = granted ? .authorized : .denied
                DispatchQueue.main.async {
                    completion(tmpStatus, true)
                }
            }
        default:
            completion(.authorized, false)
        }
    }
    
    // MARK: - Location
    private final class LocationManager: NSObject, CLLocationManagerDelegate {
        let manager: CLLocationManager
        var authorization: ((AuthorizationStatus) -> Void)?
        var location: ((Result<[String: String], Error>) -> Void)?
        
        override init() {
            manager = CLLocationManager()
            super.init()
            manager.delegate = self
        }
        func requestPermission(
            way: AuthorizationStatus.LocationWay,
            completion: @escaping (AuthorizationStatus) -> Void) {
            guard authorization == nil else { return }
            authorization = completion
            switch way {
            case .whenInUse:
                manager.requestWhenInUseAuthorization()
            case .always:
                manager.requestAlwaysAuthorization()
            }
        }
        func updateLocation(completion: @escaping (Result<[String: String], Error>) -> Void) {
            guard location == nil else { return }
            location = completion
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.startUpdatingLocation()
        }
        private func endUpdate(result: Result<[String: String], Error>) {
            location?(result)
            location = nil
        }
        // MARK: CLLocationManagerDelegate
        func locationManager(
            _ manager: CLLocationManager,
            didChangeAuthorization status: CLAuthorizationStatus) {
            if let newStatus = AuthorizationStatus(locationStatus: status) {
                authorization?(newStatus)
            }
        }
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            manager.stopUpdatingLocation()
            guard let location = locations.first else {
                endUpdate(result: .success([:]))
                return
            }
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            let geocoder = CLGeocoder()
            let geoLocation = CLLocation(latitude: latitude, longitude: longitude)
            
            let closure = { (placemarks: [CLPlacemark]?, error: Error?) in
                if let geoError = error {
                    self.endUpdate(result: .failure(geoError))
                    return
                }
                guard let addressInfo = placemarks?.first?.addressDictionary else {
                    self.endUpdate(result: .success([:]))
                    return
                }
                var res: [String: String] = ["coordinate": "\(latitude),\(longitude)"]
                if let cityName = addressInfo["City"] as? String {
                    res["cityName"] = cityName
                }
                self.endUpdate(result: .success(res))
            }
             
            if #available(iOS 11.0, *) {
                geocoder.reverseGeocodeLocation(geoLocation, preferredLocale: .current, completionHandler: closure)
            } else {
                geocoder.reverseGeocodeLocation(geoLocation, completionHandler: closure)
            }
        }
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            manager.stopUpdatingLocation()
            endUpdate(result: .failure(error))
        }
    }
    
    private static var locationManager: LocationManager = LocationManager()
    
    private static func _requestLocation(
        way: AuthorizationStatus.LocationWay,
        completion: @escaping CompletionHandler) {
        guard CLLocationManager.locationServicesEnabled() else {
            completion(.denied, false)
            return
        }
        let status = CLLocationManager.authorizationStatus()
        switch way {
        case .whenInUse:
            assert(for: .locationWhenInUse)
            if status == .notDetermined {
                locationManager.requestPermission(way: .whenInUse) { newStatus in
                    completion(newStatus, true)
                }
            } else if let newStatus = AuthorizationStatus(locationStatus: status) {
                completion(newStatus, false)
            }
        case .always:
            assert(for: .locationWhenInUse)
            assert(for: .locationAlways)
            if status == .notDetermined ||
                status == .authorizedWhenInUse {
                locationManager.requestPermission(way: .always) { newStatus in
                    completion(newStatus, true)
                }
            } else if let newStatus = AuthorizationStatus(locationStatus: status) {
                completion(newStatus, false)
            }
        }
    }
    public static func requestLocation(
        way: AuthorizationStatus.LocationWay,
        completion: @escaping CompletionHandler) {
        _requestLocation(way: way) { status, isFirst in
            DispatchQueue.main.async {
                completion(status, isFirst)
            }
        }
    }
    public static func updateLocation(
        way: AuthorizationStatus.LocationWay,
        completion: @escaping (Result<[String: String], Error>?, AuthorizationStatus, Bool) -> Void) {
        _requestLocation(way: way) { status, isFirst in
            if case .locaiton = status {
                locationManager.updateLocation { result in
                    DispatchQueue.main.async {
                        completion(result, status, isFirst)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil, status, isFirst)
                }
            }
        }
    }
    
    // MARK: - ......
    
    private static func assert(for kind: PermissionKind) {
        let key = kind.bundleKey
        precondition(Bundle.main.object(forInfoDictionaryKey: key) != nil, "\(key) not found in Info.plist")
    }
    private enum PermissionKind {
        case camera
        case photoUsage
        case addPhotoToLibrary
        case locationWhenInUse
        case locationAlways
        
        var bundleKey: String {
            switch self {
            case .camera:
                return "NSCameraUsageDescription"
            case .photoUsage:
                return "NSPhotoLibraryUsageDescription"
            case .addPhotoToLibrary:
                return "NSPhotoLibraryAddUsageDescription"
            case .locationAlways:
                return "NSLocationAlwaysAndWhenInUseUsageDescription"
            case .locationWhenInUse:
                return "NSLocationWhenInUseUsageDescription"
            }
        }
    }
}
