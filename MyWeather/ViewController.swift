//
//  ViewController.swift
//  MyWeather
//
//  Created by SD-M004 on 8/7/2563 BE.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    
    
    @IBOutlet var table: UITableView!
    
    var models = [DailyWeatherEntry]()
    var hourlyModels = [HourlyWeatherEntry]()
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var current: CurrentWeather?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Register 2 cells
        self.table.register(HourlyTableViewCell.nib(), forCellReuseIdentifier: HourlyTableViewCell.identifire)
        self.table.register(WeatherTableViewCell.nib(), forCellReuseIdentifier: WeatherTableViewCell.identifier)
        
        self.table.dataSource = self
        self.table.delegate = self
        
        self.table.backgroundColor = UIColor(red: 103/255, green: 182/255, blue: 238/255, alpha: 1.0)
        self.view.backgroundColor = UIColor(red: 103/255, green: 182/255, blue: 238/255, alpha: 1.0)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupLocation()
    }
    
    // Location
    func setupLocation() {
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, currentLocation == nil {
            currentLocation = locations.first
            locationManager.stopUpdatingLocation()
            requestWeatherForLocation()
        }
    }

    func requestWeatherForLocation() {
        guard let currentLocation = currentLocation else { return }
        let long = currentLocation.coordinate.longitude
        let lat = currentLocation.coordinate.latitude
        
//        let apiUrl = "https://api.darksky.net/forecast/ddcc4ebb2a7c9930b90d9e59bda0ba7a/\(lat),\(long)?exclude=[flags,minutely]"
        let apiUrl = "https://api.darksky.net/forecast/ddcc4ebb2a7c9930b90d9e59bda0ba7a/\(lat),\(long)?exclude=[flags,minutely]"
        URLSession.shared.dataTask(with: URL(string: apiUrl)!, completionHandler: { data, response, error in
            
            // Validation
            guard let data = data, error == nil else {
                print("something went wrong")
                return
            }
            
            print(data)
            
            // Convert data to models/some object
            var json: WeatherResponse?
            do {
                json = try JSONDecoder().decode(WeatherResponse.self, from: data)
            } catch {
                print("error : \(error)")
            }
            
            guard let result = json else { return }
            
            print(result.currently.summary)
            let entries = result.daily.data
            self.models.append(contentsOf: entries)
            
            let current = result.currently
            self.current = current
            
            self.hourlyModels = result.hourly.data
            
            // Update user interface
            DispatchQueue.main.async {
                self.table.reloadData()
                self.table.tableHeaderView = self.createTableHeader()
            }
            
        }).resume()
        
    }
    
    func createTableHeader() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width - 100))
        
        headerView.backgroundColor = UIColor(red: 103/255, green: 182/255, blue: 238/255, alpha: 1.0)
        
        let locationLabel = UILabel(frame: CGRect(x: 10, y: 10, width: view.frame.size.width - 20, height: headerView.frame.size.height / 5))
        let summaryLabel = UILabel(frame: CGRect(x: 10, y: 20 + locationLabel.frame.size.height, width: view.frame.size.width - 20, height: headerView.frame.size.height / 5))
        let tempLabel = UILabel(frame: CGRect(x: 10, y: 20 + locationLabel.frame.size.height + summaryLabel.frame.size.height, width: view.frame.size.width - 20, height: headerView.frame.size.height / 3))
        
        headerView.addSubview(locationLabel)
        headerView.addSubview(summaryLabel)
        headerView.addSubview(tempLabel)
        
        locationLabel.textAlignment = .center
        summaryLabel.textAlignment = .center
        tempLabel.textAlignment = .center
        
        locationLabel.text = "Current Location"
        
        guard let currentWeather = self.current else {
            return UIView()
        }
        
        summaryLabel.text = self.current?.summary
        tempLabel.font = UIFont(name: "Helvetica Bold", size: 50)
        tempLabel.text = "\(currentWeather.temperature)°"
        
        return headerView
    }
    

    // Table
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return self.models.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:

            let cell = tableView.dequeueReusableCell(withIdentifier: HourlyTableViewCell.identifire, for: indexPath) as! HourlyTableViewCell
            
            cell.configure(with: self.hourlyModels)
            cell.backgroundColor = UIColor(red: 103/255, green: 182/255, blue: 238/255, alpha: 1.0)
            
            return cell
            
        case 1:

            let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.identifier, for: indexPath) as! WeatherTableViewCell
            
            cell.configure(with: self.models[indexPath.row])
            cell.backgroundColor = UIColor(red: 103/255, green: 182/255, blue: 238/255, alpha: 1.0)
            
            return cell
            
        default:
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 90
        case 1:
            return 40
        default:
            return 0
        }
        
    }
    
    
}

