//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
//allows us to tap into location of iPhone
import CoreLocation
import Alamofire
import SwiftyJSON


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    
    
    //Constants
    //website where we obtain the data
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    //my api key for open weather map api
    let APP_ID = "dce06908b3c48a8c542fc1b5eb39a314"
    

    //TODO: Declare instance variables here
    //create a new location manager object here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    
    
    

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        
        
        //Our weather view controller class has to become a delegate of the location manager
        //this means that we assign our class as the one to handle all of the location data
        
        locationManager.delegate = self
        
        //sets the accuracy of the location data
        /*For this weather app, the accuracy does not need to be extremely accurate so we will only
        use accuracy up to 100 meters*/
        
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        //asks the user for permission to use their location only while they are using the app
        //This is the method that will trigger the pop up for the user to allow us to use their location
        /*The method wont actually pop up until we add a description which is modified within the info.plist under supporting files
        These descriptions are under the Privacy - Location when in use usage description and Privacy - Location Usage Description*/
        locationManager.requestWhenInUseAuthorization()
        
        //This starts the process of the location manager looking for the gpu coordinates of the current iPhone
        //This method is asynchronous, operating in the background
        //Once this finds the location, it will send a message to this view controller because we said that this class is the location manager's delegate
        
        locationManager.startUpdatingLocation()
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url:String,parameters:[String:String]){
        //use alamofire to make http requests
        Alamofire.request(url, method: .get, parameters:parameters).responseJSON {
            response in
            if response.result.isSuccess {
                
                //format the data
                /*the response result value comes back in the form of an optional so we
                 have to force unwrap it with the '!' and the response type is of type 'Any?'
                 so we cast it to be of type JSON*/
                let weatherJSON : JSON = JSON(response.result.value!)
//                When we are in a closure we have to use self when calling methods. This tells the compiler to look within the current class for any declared
//                methods of the same name
                self.updateWeatherData(json: weatherJSON)
                
            }else {
                //failure
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
        }
    
    }
    

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json : JSON){
        //deal with the weather data
        
        if let tempResult = json["main"]["temp"].double{
        weatherDataModel.temperature = Int(tempResult - 273.15)
        weatherDataModel.city = json["name"].stringValue
        weatherDataModel.condition = json["weather"][0]["id"].intValue
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            
        //update the UI
            updateUIWithWeatherData()
        }else{
            cityLabel.text = "Weather Unavailable"
        }
        
        
        
        
    }
    
    

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData(){
        cityLabel.text = weatherDataModel.city
        print(weatherDataModel.city)
        temperatureLabel.text = String(weatherDataModel.temperature)
        print(weatherDataModel.temperature)
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    //Tells the delegate that new location data is available
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //last value in array is the most accurate location
        let location = locations[locations.count - 1]
        //check if location is valid
        //if the location value is negative, it represents an invalid result
        if location.horizontalAccuracy > 0 {
            /*stop updating the locatio because grabbing gps data is very energy intensive and will drain the user's battery*/
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
            
        }else {
            
        }
    }
    
    
    
    //Write the didFailWithError method here:
    //Tells the delegate that the location manager was unable to retrieve a location value
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        //sets the label if we dont get the location back
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
        print(city)
    }
    

    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName"{
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    
    
    
}


