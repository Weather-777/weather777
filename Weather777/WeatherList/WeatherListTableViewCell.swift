//
//  WeatherListTableViewCell.swift
//  Weather777
//
//  Created by 석진 on 2/7/24.
//

import UIKit

class WeatherListTableViewCell: UITableViewCell
{

    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeOrCityLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var highTemperatureLabel: UILabel!
    @IBOutlet weak var lowTemperatureLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() 
    {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0))
    }
}


