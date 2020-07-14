//
//  WeatherCollectionViewCell.swift
//  MyWeather
//
//  Created by SD-M004 on 9/7/2563 BE.
//

import UIKit

class WeatherCollectionViewCell: UICollectionViewCell {

    
    static let identifier = "WeatherCollectionViewCell"
    static func nib() -> UINib {
        return UINib(nibName: "WeatherCollectionViewCell", bundle: nil)
    }
    
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var tempLabel: UILabel!
    
    func configure(with _model: HourlyWeatherEntry) {
        self.tempLabel.text = "\(_model.temperature)"
        self.iconImageView.contentMode = .scaleAspectFit
        self.iconImageView.image = UIImage(named: "clear")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
