//
//  AsteroidInfoViewController.swift
//  Armagedon2022
//
//  Created by Alex on 16.04.2022.
//

import UIKit

class AsteroidInfoViewController: UIViewController {

    @IBOutlet weak var colectionView: UICollectionView!
    var asteroid = NearEearthObjectsInfo(links: LinkInfo(self: ""), name: "", estimated_diameter: EstimatedDiameterInfo(meters: MetersInfo()), is_potentially_hazardous_asteroid: false, close_approach_data: [])
    
    var inf: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        asteroid = getInfoAboutAsteroids()
        title = "\(asteroid.name)"
    }
    
    func getInfoAboutAsteroids() -> NearEearthObjectsInfo {
        var asteroids = NearEearthObjectsInfo(links: LinkInfo(self: ""), name: "", estimated_diameter: EstimatedDiameterInfo(meters: MetersInfo()), is_potentially_hazardous_asteroid: false, close_approach_data: [])
        guard let someUrl = inf else { return asteroids }
        guard let url = URL(string: someUrl) else { return asteroids }
        
        var request         = URLRequest(url: url)
        request.httpMethod  = "GET"
        let semaphore       = DispatchSemaphore(value: 0)
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else { return }
            guard let data = data else {  return }
            do{
                asteroids = try JSONDecoder().decode(NearEearthObjectsInfo.self, from: data)
                semaphore.signal()
            }catch{
                print("Unexpected error: \(error).")
            }
        }.resume()
        _ = semaphore.wait(timeout: .distantFuture)
        return asteroids
    }
    
}

extension AsteroidInfoViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return asteroid.close_approach_data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AsteroidInfoCell", for: indexPath) as? AsteroidInfoCell else { return UICollectionViewCell() }
        cell = configureCell(cell: cell)
        cell = setValuesInCell(cell: cell, indexPath: indexPath)
        
        cell.buttonAdd.tag = indexPath.row
        cell.buttonAdd.addTarget(self, action: #selector(didTapCellButton(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func didTapCellButton(sender: UIButton) {
        let Someindex   = sender.tag

        
        let link        = BasketForDestruction(context: dataStorageManger.viewContext)
        let index       = Someindex
        
        link.linkToAsteroid = asteroid.links.`self`
        link.index          = Int16(index)
        
        let alertController = UIAlertController(title: "Успешно", message: "астероид внесен в список на уничтожение", preferredStyle: .alert)
        let ok              = UIAlertAction(title: "OK!", style: .default, handler: nil)
        alertController.addAction(ok)
        present(alertController, animated: true, completion: nil)
        dataStorageManger.saveContext()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 30, height: view.frame.height/2.9)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20,left: 15,bottom: 40,right: 15)
    }
    
    func configureCell(cell: AsteroidInfoCell) -> AsteroidInfoCell{
        cell.contentView.backgroundColor = UIColor.clear
        
        let whiteRoundedView : UIView = UIView(frame: CGRect(x: 10, y: 8, width: self.view.frame.size.width - 50, height: self.view.frame.height/2.9 - 10))
        
        whiteRoundedView.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 0.9])
        
        whiteRoundedView.layer.masksToBounds  = false
        whiteRoundedView.layer.cornerRadius   = 20.0
        whiteRoundedView.layer.shadowOffset   = CGSize(width: -1, height: 1)
        whiteRoundedView.layer.shadowOpacity  = 0.2
        
        cell.contentView.addSubview(whiteRoundedView)
        cell.contentView.sendSubviewToBack(whiteRoundedView)
        
        return cell
    }
    
    func setValuesInCell(cell: AsteroidInfoCell, indexPath: IndexPath) -> AsteroidInfoCell{
        
        let diameter = asteroid.estimated_diameter.meters.estimated_diameter_max
        if let diameter = diameter {
             let finalValue             = String(format: "%.0f", diameter)
            cell.diameterLabel.text     = "Размер: \(finalValue) м"
        }else{ cell.diameterLabel.text  = "Размер: не указан" }
        
        let someDate                  = asteroid.close_approach_data[indexPath.row].close_approach_date
        cell.approximationLabel.text  = dateСonversion(date: someDate)
        cell.orbitLabel.text          = "на орбите: \(asteroid.close_approach_data[indexPath.row].orbiting_body)"
        
        let speed                     = asteroid.close_approach_data[indexPath.row].relative_velocity.kilometers_per_hour
        let speedDouble               = Double(speed)
        if let someSpeed = speedDouble{
            let value                 = String(format: "%.0f", someSpeed)
            cell.speedLabel.text      = "на скорости \(value) км/с"
        }else{
            cell.speedLabel.text      = "на скорости не указана"
        }
        
        let detailDate                = asteroid.close_approach_data[indexPath.row].close_approach_date_full
        let arrDateFirst              = detailDate.components(separatedBy: " ")
        let finalDate                 = DetailedDateСonversion(date: arrDateFirst[0], secondDate: arrDateFirst[1])
        cell.timeLabel.text           = "точное время \(finalDate)"
        
        
        let values = UserSettings.valueForFilterMeasurement ?? false
        if values == false{
            let kilometrs                   = asteroid.close_approach_data[indexPath.row].miss_distance.kilometers
            let kilometrsDouble             = Double(kilometrs)
            if let distance = kilometrsDouble{
                let value                   = String(format: "%.0f", distance)
                cell.distanceLabel.text     = "на расстояние \(value) км"
            }else{
                cell.distanceLabel.text     = "на расстояние не найдено"
            }
        }else{
            let kilometrs                   = asteroid.close_approach_data[indexPath.row].miss_distance.lunar
            let kilometrsDouble             = Double(kilometrs)
            if let distance = kilometrsDouble{
                let value                   = String(format: "%.0f", distance)
                cell.distanceLabel.text     = "на расстояние \(value) л.орб."
            }else{
                cell.distanceLabel.text     = "на расстояние не найдено"
            }
        }
        
        return cell
    }
    
    func dateСonversion(date: String) -> String{
        let arrDateFirst  = date.components(separatedBy: "-")
        var dateArr       = [Int]()
        
        for i in arrDateFirst{
            dateArr.append(Int(i)!)
        }
        if dateArr[1] == 1{
            return "Подлетает \(dateArr[2]) января \(dateArr[0])"
        }else if dateArr[1] == 2{
            return  "Подлетает \(dateArr[2]) февраля \(dateArr[0])"
        }else if dateArr[1] == 3{
            return  "Подлетает \(dateArr[2]) марта \(dateArr[0])"
        }else if dateArr[1] == 4{
            return  "Подлетает \(dateArr[2]) апреля \(dateArr[0])"
        }else if dateArr[1] == 5{
            return  "Подлетает \(dateArr[2]) мая \(dateArr[0])"
        }else if dateArr[1] == 6{
            return  "Подлетает \(dateArr[2]) июня \(dateArr[0])"
        }else if dateArr[1] == 7{
            return  "Подлетает \(dateArr[2]) июля \(dateArr[0])"
        }else if dateArr[1] == 8{
            return  "Подлетает \(dateArr[2]) августа \(dateArr[0])"
        }else if dateArr[1] == 9{
            return  "Подлетает \(dateArr[2]) сентября \(dateArr[0])"
        }else if dateArr[1] == 10{
            return  "Подлетает \(dateArr[2]) октября \(dateArr[0])"
        }else if dateArr[1] == 11{
            return  "Подлетает \(dateArr[2]) ноября \(dateArr[0])"
        }else{
            return  "Подлетает \(dateArr[2]) декабря \(dateArr[0])"
        }
        
    }
    
    func DetailedDateСonversion(date: String, secondDate: String) -> String{
        let arrDateFirst  = date.components(separatedBy: "-")
        
        if arrDateFirst[1] == "Jan"{
            return "\(arrDateFirst[2]) января \(arrDateFirst[0]) \(secondDate)"
        }else if arrDateFirst[1] == "Feb"{
            return  "\(arrDateFirst[2]) февраля \(arrDateFirst[0]) \(secondDate)"
        }else if arrDateFirst[1] == "Mar"{
            return  "\(arrDateFirst[2]) марта \(arrDateFirst[0]) \(secondDate)"
        }else if arrDateFirst[1] == "Apr"{
            return  "\(arrDateFirst[2]) апреля \(arrDateFirst[0]) \(secondDate)"
        }else if arrDateFirst[1] == "May"{
            return  "\(arrDateFirst[2]) мая \(arrDateFirst[0]) \(secondDate)"
        }else if arrDateFirst[1] == "Jun"{
            return  "\(arrDateFirst[2]) июня \(arrDateFirst[0]) \(secondDate)"
        }else if arrDateFirst[1] == "Jul"{
            return  "\(arrDateFirst[2]) июля \(arrDateFirst[0]) \(secondDate)"
        }else if arrDateFirst[1] == "Aug"{
            return  "\(arrDateFirst[2]) августа \(arrDateFirst[0]) \(secondDate)"
        }else if arrDateFirst[1] == "Sep"{
            return "\(arrDateFirst[2]) сентября \(arrDateFirst[0]) \(secondDate)"
        }else if arrDateFirst[1] == "Okt"{
            return "\(arrDateFirst[2]) октября \(arrDateFirst[0]) \(secondDate)"
        }else if arrDateFirst[1] == "Nov"{
            return "\(arrDateFirst[2]) ноября \(arrDateFirst[0]) \(secondDate)"
        }else{
            return "\(arrDateFirst[2]) декабря \(arrDateFirst[0]) \(secondDate)"
        }
        
    }

    
    
}
