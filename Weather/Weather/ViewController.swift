//
//  ViewController.swift
//  Weather
//
//  Created by User197526 on 7/14/21.
import UIKit

class ViewController: UIViewController {
    
    //Outlets for all the elements on storyboard
    @IBOutlet weak var cityLabelOutlet: UILabel!
    @IBOutlet weak var weatherLabelOutlet: UILabel!
    @IBOutlet weak var weatherTypeIconOutlet: UIImageView!
    @IBOutlet weak var tempratureLabelOutlet: UILabel!
    @IBOutlet weak var humidityLabelOutlet: UILabel!
    @IBOutlet weak var windLabelOutlet: UILabel!
    
    let apiKeyId = "appid=3d622adbc06e88239c09d2f9437946e0"
    let apiUrl = "https://api.openweathermap.org/data/2.5/weather?"
    let iconType = "png"
    let iconSize = "@2x"
    let iconPath = "https://openweathermap.org/img/wn/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getResponse()
    }

    func getResponse(){
           let session = URLSession.shared
           let query = "q=Punjab,ca&units=metric"
           let queryUrl = URL(string:apiUrl+query+"&"+apiKeyId)!

           let task = session.dataTask(with: queryUrl){
               data, response, error in
               
               if error != nil || data == nil {
                   print("Client error has occured!")
                   return
               }
               
               //Handling HTTP error code
               let r = response as? HTTPURLResponse
               guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                   print("Server error \(String(describing: r?.statusCode))")
                   return
               }
               
               guard let mime = response.mimeType, mime == "application/json" else {
                   print("Incorrect MIME type: \(String(describing: r?.mimeType))")
                   return
               }
               
               do{
                   let response = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]
                   //here you can process the data that your received
                   print(response ?? "Error - No response received")
                   
                   
                   let cityResponse = response?["name"] as! String
                   let weatherResponse = response?["weather"] as? [Any]
                   
                   let weatherTypeResponse = (weatherResponse?[0] as? [String:Any])?["description"] as? String
                   let iconResponse = (weatherResponse?[0] as? [String:Any])?["icon"] as? String
                   
                   let tempDetailsResponse = response?["main"] as? [String:Any]
                   let tempratureDetail = tempDetailsResponse?["temp"] as? Double
                   let humidityResponse = tempDetailsResponse?["humidity"] as? Double
                   
                   let windResponse = response?["wind"] as? [String:Any]
                   let windSpeedResponse = windResponse?["speed"] as? Double
                   
                   DispatchQueue.main.async {
                        self.cityLabelOutlet.text = cityResponse
                        self.weatherLabelOutlet.text = weatherTypeResponse
                        self.tempratureLabelOutlet.text = "\(tempratureDetail!) ℃"
                        self.humidityLabelOutlet.text = "Humidity: \(humidityResponse!) %"
                        self.windLabelOutlet.text = "Wind: \(windSpeedResponse!) km/h"
                
                        let icon_url = URL(string: self.iconPath+iconResponse!+self.iconSize+"."+self.iconType)!
                        self.weatherTypeIconOutlet.imageFrom(apiUrl: icon_url)
                   }
               }
               
               catch {
                   print("Error in JSON")
               }
           }
           task.resume()
       }
}

extension UIImageView{
  func imageFrom(apiUrl:URL){
    DispatchQueue.global().async { [weak self] in
      if let data = try? Data(contentsOf: apiUrl){
        if let image = UIImage(data:data){
          DispatchQueue.main.async{
            self?.image = image
          }
        }
      }
    }
  }
}
