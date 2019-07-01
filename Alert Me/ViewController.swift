//
//  ViewController.swift
//  Alert Me
//
//  Created by Mina Habib on 6/12/19.
//  Copyright © 2019 Mina Habib. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation
import UserNotifications
import CoreData

class ViewController: UIViewController, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {

    let fCenter = UNUserNotificationCenter.current()
    let locationManager = CLLocationManager()
    
    var zipCodesToIgnore: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in }
        fCenter.delegate = self
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        locatationSetup()
        
        
        // Do any additional setup after loading the view.
    }
    
    func locatationSetup(){
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if (authorizationStatus != .authorizedAlways) {
            print("Please choose Always allow use your location.")
            // User has not authorized access to location information.
            return
        }else if (!CLLocationManager.significantLocationChangeMonitoringAvailable()) {
            // The service is not available.
            return
        }else{
            locationManager.startMonitoringSignificantLocationChanges()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations: [CLLocation] ){
        guard let location: CLLocation = manager.location else { return }
        
        fetchCityAndCountry(from: location) { city, country, postalCode, error in
            guard let city = city, let country = country, let postalCode = postalCode, error == nil else { return }
            print(city + ", " + country + ", " + postalCode )
            
            let obatainLastZip = UserDefaults.standard.object(forKey: "lastZipObtained")!
            let zipCodesToBeIgnored = self.getZipArray()
            
            if(postalCode == obatainLastZip as? String){
                print("Still in the same zip code")
            }else if(zipCodesToBeIgnored.contains(postalCode)) {
                UserDefaults.standard.set(postalCode, forKey: "lastZipObtained")
                print("zip Code Ignored")
            }else{
                self.fetchCrimeIndex(zip: postalCode)
                UserDefaults.standard.set(postalCode, forKey: "lastZipObtained")
                print(obatainLastZip)
            }
        }
    }
    
    func fetchCityAndCountry(from location: CLLocation, completion: @escaping (_ city: String?, _ country:  String?, _ postalCode:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            completion(placemarks?.first?.locality,
                       placemarks?.first?.country,
                       placemarks?.first?.postalCode,
                       error)
        }
    }
    
    func fetchCrimeIndex(zip: String) {//CompletionHandler: @escaping ( user: String, Error?)-> Void
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.gateway.attomdata.com"
        components.path = "/communityapi/v2.0.0/Area/Full/"
        components.queryItems = [
            URLQueryItem(name: "AreaID", value:  "ZI" + zip)
        ]
        let url = (components.url)!
        
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "accept": "application/json",
            "apikey": "213878bd1b612af66ce4694a4f718d78",
        ]
        let Session = URLSession(configuration: config)
        
        let task = Session.dataTask(with: url , completionHandler: {
            (data, response, error) in
            
            guard let data = data, error == nil else { return }
            
            do {
                
                let extract = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject]
                
                if let value = extract["response"]?["result"] as? [String: Any]{
                    if let valuee = value["package"] as? [String: Any]{
                        let valueee = valuee["item"]! as! NSArray
                        for dic in valueee {
                            let packageNumbers = dic as! [String: AnyObject]
                            let indexNumber = packageNumbers["crmcytotc"] as! String
                            let indexValue = Int(indexNumber)!
                            print(indexValue)
                            self.notifyMe(x: indexValue)
                        }
                    }
                }
            } catch let error as NSError {
                print(error)
            }
        })
        
        task.resume()
    }
    
    func createNotification(x: String, y: String, z: String) {
        //get the notification center
        let center =  UNUserNotificationCenter.current()
        
        //create the content for the notification
        let content = UNMutableNotificationContent()
        content.title = x
        content.subtitle = y
        content.body = z
        content.sound = UNNotificationSound.default
        
        //notification trigger can be based on time, calendar or location
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval:2 , repeats: false)
        
        //create request to display
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        //add request to notification center
        center.removeAllPendingNotificationRequests()
        center.add(request)
        center.delegate = self

    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        //displaying the ios local notification when app is in foreground
        completionHandler([.alert, .badge, .sound])
    }
    
    func getZipArray() -> Array<String>{
        var zipArrayIgnore: [String] = []
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ZipCodesToIgnore")
        do {
            zipCodesToIgnore = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        
        for zipCode in zipCodesToIgnore {
            zipArrayIgnore.append(zipCode.value(forKey: "zipCode") as! String)
        }
        return zipArrayIgnore
    }
    
    func notifyMe(x:Int) {
        if x > 50 {
            let notifyVariable = String( x - 100 )
            let x = "Alert: Crime Risk Update"
            let y = "You've entered an area where Crime Rate is Higher than the National Average. Your current risk increased by " + notifyVariable + " %"
            let z = "Careful"
            print(notifyVariable)
            createNotification(x: z, y: x, z: y)
        }else if x >= 200{
            let notifyVariable = String( x - 100 )
            let x = "Alert: Crime Risk Update "
            let y = "You have entered an area where Crime rate is Double than the National Average. Your current risk increased by " + notifyVariable + " %"
            let z = "Dangerous Zone"
            print(notifyVariable)
            createNotification(x: z, y: x, z: y)
        }else if x >= 300{
            let notifyVariable = String( x - 100 )
            let x = "Alert: Crime Risk Update "
            let y = "You have entered a dangerous area where Crime rate is triple than the National Average. Your current risk increased by " + notifyVariable + " %"
            let z = "Proceed at Your Own Risk"
            print(notifyVariable)
            createNotification(x: z, y: x, z: y)
        }
    }
    
}
