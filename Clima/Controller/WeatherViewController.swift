import UIKit
import CoreLocation

final class WeatherViewController: UIViewController {
    
    private var weatherManager = WeatherManager()
    private var locationManager = CLLocationManager()

    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .lightBackground)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var searchTextField: UITextField = {
        let searchBar = UITextField()
        searchBar.placeholder = "Search"
        searchBar.textAlignment = .right
        searchBar.autocapitalizationType = .words
        searchBar.returnKeyType = .go
        searchBar.backgroundColor = UIColor(white: 1, alpha: 0.2)
        searchBar.layer.cornerRadius = 5
        searchBar.clipsToBounds = true
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    private lazy var locationButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "location.fill")
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.backgroundColor = .clear
        button.layer.cornerRadius = 20
        button.addTarget(
            self,
            action: #selector(locationButtonAction),
            for: .touchUpInside
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var searchButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "magnifyingglass")
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.backgroundColor = .clear
        button.addTarget(
            self,
            action: #selector(searchButtonAction),
            for: .touchUpInside
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var sunImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "sun.max")
        imageView.tintColor = UIColor(resource: .weather)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.text = "21°C"
        label.font = UIFont.systemFont(ofSize: 100, weight: .bold)
        label.textColor = UIColor(resource: .weather)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var cityLabel: UILabel = {
        let label = UILabel()
        label.text = "London"
        label.font = UIFont.systemFont(ofSize: 35, weight: .regular)
        label.textColor = UIColor(resource: .weather)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate()
        setupLocationManager()

        addSubviews()
        setupConstraints()
    }

    private func setupLocationManager() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }

    private func delegate() {
        searchTextField.delegate = self
        weatherManager.delegate = self
        locationManager.delegate = self
    }
    
    @objc
    private func searchButtonAction() {
        searchTextField.endEditing(true)
    }

    @objc
    func locationButtonAction(){
        locationManager.requestLocation()
    }
}

// MARK: - UITextFieldDelegate

 extension WeatherViewController: UITextFieldDelegate {

     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
         searchTextField.endEditing(true)
         return true
     }

     func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
         if searchTextField.text != "" {
             return true
         } else {
             textField.placeholder = "Enter city name"
             return false
         }
     }
     
     func textFieldDidEndEditing(_ textField: UITextField) {
         if let city = searchTextField.text {
             weatherManager.fetchWeather(cityName: city)
         }

         searchTextField.text = ""
     }
}

// MARK: - WeatherManagerDelegate

extension WeatherViewController: WeatherManagerDelegate {

    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.temparatureString
            self.sunImageView.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}
   
// MARK: - CLLocationManagerDelegate

extension WeatherViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if  let location = locations.last {
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print(error)
    }
}

// MARK: - Setup Constraints

private extension WeatherViewController {

    func addSubviews() {
        view.addSubview(backgroundImageView)
        view.addSubview(searchTextField)
        view.addSubview(locationButton)
        view.addSubview(searchButton)
        view.addSubview(sunImageView)
        view.addSubview(temperatureLabel)
        view.addSubview(cityLabel)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),

                locationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                locationButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
                locationButton.widthAnchor.constraint(equalToConstant: 40),
                locationButton.heightAnchor.constraint(equalToConstant: 40),

                searchTextField.leadingAnchor.constraint(equalTo: locationButton.trailingAnchor, constant: 15),
                searchTextField.trailingAnchor.constraint(equalTo: searchButton.leadingAnchor, constant: -15),
                searchTextField.centerYAnchor.constraint(equalTo: locationButton.centerYAnchor),
                searchTextField.heightAnchor.constraint(equalToConstant: 40),

                searchButton.leadingAnchor.constraint(equalTo: searchTextField.trailingAnchor, constant: 15),
                searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                searchButton.centerYAnchor.constraint(equalTo: locationButton.centerYAnchor),
                searchButton.heightAnchor.constraint(equalToConstant: 40),
                searchButton.widthAnchor.constraint(equalToConstant: 40),

                sunImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                sunImageView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 40),
                sunImageView.widthAnchor.constraint(equalToConstant: 120),
                sunImageView.heightAnchor.constraint(equalToConstant: 120),

                temperatureLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                temperatureLabel.topAnchor.constraint(equalTo: sunImageView.bottomAnchor, constant: 30),

                cityLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                cityLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 10),
            ]
        )
    }
}
