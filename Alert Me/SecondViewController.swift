//
//  SecondViewController.swift
//  Alert Me
//
//  Created by Mina Habib on 6/16/19.
//  Copyright © 2019 Mina Habib. All rights reserved.
//

import UIKit
import CoreLocation


class SecondViewController: ViewController, UITextFieldDelegate {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var fetchingIndicator: UIActivityIndicatorView!
    @IBAction func dissmissKeyboard(_ sender: Any) {
        getAreaCrimeRateZipText.resignFirstResponder()
    }
    @IBOutlet weak var or: UILabel!
    @IBOutlet weak var displayCrimeRate: UITextView!
    @IBOutlet weak var getAreaCrimeRateZipText: UITextField!
    @IBAction func getAreaCrimeRateZip(_ sender: Any, forEvent event: UIEvent) {
        let getText = self.getAreaCrimeRateZipText.text
        fetchCrimeIndex(zip: getText!)
        fetchingIndicator.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.getAreaCrimeRateZipText.resignFirstResponder()
        }
    }
    @IBAction func getAreaCrimeRate(_ sender: Any) {
        locationCallButton()
        fetchingIndicator.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.getAreaCrimeRateZipText.resignFirstResponder()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAreaCrimeRateZipText.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    override func locatationSetup(){
        return
    }
    
    override func locationManager(_ manager: CLLocationManager, didUpdateLocations: [CLLocation] ){
        guard let location: CLLocation = manager.location else { return }
        fetchCityAndCountry(from: location) { city, country, postalCode, error in
            guard let city = city, let country = country, let postalCode = postalCode, error == nil else { return }
            print(city + ", " + country + ", " + postalCode )
            self.fetchCrimeIndex(zip: postalCode)
            print(postalCode)
        }
    }
    
    override func fetchCrimeIndex(zip: String){
        
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
                
                let extract = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments ) as! [String: AnyObject]
                
                if let value = extract["response"]?["result"] as? [String: Any]{
                    if let valuee = value["package"] as? [String: Any]{
                        let valueee = valuee["item"]! as! NSArray
                        for dic in valueee {
                            let packageNumbers = dic as! [String: AnyObject]
                            let indexNumber = packageNumbers["crmcytotc"] as! String
                            let indexValue = Int(indexNumber)!
                            self.informMe(x: indexValue)
                        }
                    }
                }
            } catch let error as NSError {
                print(error)
            }
        })
        
        task.resume()
    }
    
    func locationCallButton(){
        let authorizationStatus = CLLocationManager.authorizationStatus()
        locationManager.delegate = self
        if (authorizationStatus != .authorizedAlways) {
            print("Please choose Always allow use your location.")
            // User has not authorized access to location information.
            return
        }else if (!CLLocationManager.significantLocationChangeMonitoringAvailable()) {
            // The service is not available.
            return
        }else{
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func informMe(x:Int){
        let informVariable = String(x)
        let y = "Area's Crime risk is " + informVariable +  " with national average of 100 points. On average an individual is at risk of a crime of anytype is 100 points."
        print (y)
        DispatchQueue.main.async {
            self.displayCrimeRate.text = y
            self.fetchingIndicator.stopAnimating()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        return updatedText.count <= 5
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
