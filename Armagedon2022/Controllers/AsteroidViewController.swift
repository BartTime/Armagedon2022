//
//  AsteroidViewController.swift
//  Armagedon2022
//
//  Created by Alex on 14.04.2022.
//

import UIKit
import CoreData

var dangerAsteroids = 0
var currentPage     = 0


class AsteroidViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var asteroids            = Asteroids(links: Links.init(next: ""), near_earth_objects: [], page: Pages.init(total_pages: 0))

    var dataStorageManger    = DataStorageManger()
    var fetchResultController: NSFetchedResultsController<BasketForDestruction>!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate   = self
        collectionView.dataSource = self
                
        let fetchRequest: NSFetchRequest<BasketForDestruction> = BasketForDestruction.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "linkToAsteroid", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataStorageManger.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        try! fetchResultController.performFetch()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let valueFirst = UserSettings.valueForFilterDanger ?? false

        asteroids = getAsteroids(link: "https://api.nasa.gov/neo/rest/v1/neo/browse?api_key=EV5NxLQHxB4Dpw2yYmGV30v29mui7CSIni35oSgs")

        if valueFirst == true {
            asteroids = getDangerAsteroids(arrAsteroid: self.asteroids)
        }
        
        collectionView.reloadData()

    }
    
    func getDangerAsteroids(arrAsteroid: Asteroids) -> Asteroids {
        var asteroid: Asteroids = Asteroids(links: Links.init(next: ""), near_earth_objects: [], page: Pages.init(total_pages: 0))
        asteroid.page.total_pages = arrAsteroid.page.total_pages
        asteroid.links.next       = arrAsteroid.links.next
        for i in arrAsteroid.near_earth_objects{
            if i.is_potentially_hazardous_asteroid == true{
                asteroid.near_earth_objects.append(i)
            }
        }
        
        return asteroid
    }
    
    func getAsteroids(link: String) -> Asteroids
    {
        
        var asteroid: Asteroids = Asteroids(links: Links.init(next: ""), near_earth_objects: [], page: Pages.init(total_pages: 0))
        guard let url = URL(string: link) else { return asteroid }
        var request         = URLRequest(url: url)
        request.httpMethod  = "GET"
        let semaphore       = DispatchSemaphore(value: 0)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else { return }
            guard let data = data else { return }
            do {
                asteroid = try JSONDecoder().decode(Asteroids.self, from: data)
                semaphore.signal()
            } catch {
                print("Unexpected error: \(error).")
            }
        }.resume()
        _ = semaphore.wait(timeout: .distantFuture)
        return asteroid
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToInfo"{
            let vc = segue.destination as! AsteroidInfoViewController
            let index = self.collectionView.indexPathsForSelectedItems!.first
            vc.inf = asteroids.near_earth_objects[index!.row].links.`self`
        }
    }
    
    func getCountOfDangerAsteroids() -> Int {
        for i in self.asteroids.near_earth_objects{
            if i.is_potentially_hazardous_asteroid == true{
                dangerAsteroids += 1
            }
        }
        return dangerAsteroids
    }

}

extension AsteroidViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return asteroids.near_earth_objects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 30, height: view.frame.height/2.6)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 20,left: 15,bottom: 40,right: 15)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AsteroidCollectionCell", for: indexPath) as? AsteroidCollectionCell else { return UICollectionViewCell() }
        cell = configureCell(cell: cell)
        cell = setValuesInCell(cell: cell, indexPath: indexPath)
        
        
        cell.destroyButton.tag = indexPath.row
        cell.destroyButton.addTarget(self, action: #selector(didTapCellButton(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    
    @objc func didTapCellButton(sender: UIButton) {
        let date                  = NSDate()
        let dateFormatter         = DateFormatter()
        dateFormatter.dateFormat  = "MM-dd-yyyy"
        let dateNow               = dateFormatter.string(from: date as Date)
        
        let Someindex   = sender.tag
        let link        = BasketForDestruction(context: dataStorageManger.viewContext)
        let myIndexPath = IndexPath(row: Someindex, section: 0)
        let section     = asteroids.near_earth_objects[myIndexPath.row].close_approach_data
        var index       = 0
        for i in 0...(section.count - 1){
            let dateForAsteroid  = section[i].close_approach_date
            let value            = comparisonDate(firstDate: dateNow, secondDate: dateForAsteroid)
            
            if value == true { break }
            index += 1
        }
        
        link.linkToAsteroid = asteroids.near_earth_objects[Someindex].links.`self`
        link.index          = Int16(index)
        
        let alertController = UIAlertController(title: "Успешно", message: "астероид внесен в список на уничтожение", preferredStyle: .alert)
        let ok              = UIAlertAction(title: "OK!", style: .default, handler: nil)
        alertController.addAction(ok)
        present(alertController, animated: true, completion: nil)
        dataStorageManger.saveContext()
    }
    
    
    
    func configureCell(cell: AsteroidCollectionCell) -> AsteroidCollectionCell{
        cell.contentView.backgroundColor = UIColor.clear
        
        let whiteRoundedView : UIView = UIView(frame: CGRect(x: 10, y: 8, width: self.view.frame.size.width - 50, height: self.view.frame.height/2.6 - 10))
        
        
        whiteRoundedView.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 0.9])
        
        whiteRoundedView.layer.masksToBounds  = false
        whiteRoundedView.layer.cornerRadius   = 20.0
        whiteRoundedView.layer.shadowOffset   = CGSize(width: -1, height: 1)
        whiteRoundedView.layer.shadowOpacity  = 0.2
        
        cell.contentView.addSubview(whiteRoundedView)
        cell.contentView.sendSubviewToBack(whiteRoundedView)
        
        cell.imageLabel.clipsToBounds        = true
        cell.imageLabel.layer.cornerRadius   = 20
        cell.imageLabel.layer.maskedCorners  = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        return cell
    }

    
    func setValuesInCell(cell: AsteroidCollectionCell, indexPath: IndexPath) -> AsteroidCollectionCell{
        let date                  = NSDate()
        let dateFormatter         = DateFormatter()
        dateFormatter.dateFormat  = "MM-dd-yyyy"
        let dateNow               = dateFormatter.string(from: date as Date)
        
        cell.nameAsteroid.text    = asteroids.near_earth_objects[indexPath.row].name
        
        let diameter = asteroids.near_earth_objects[indexPath.row].estimated_diameter.meters.estimated_diameter_max
        if let diameter  = diameter {
             let finalValue         = String(format: "%.0f", diameter)
            cell.sizeLabel.text     = "Размер: \(finalValue) м"
        }else{ cell.sizeLabel.text  = "Размер: не указан" }

        let section = asteroids.near_earth_objects[indexPath.row].close_approach_data
        var index = 0
        for i in 0...(section.count - 1){

            let dateForAsteroid  = section[i].close_approach_date
            let value            = comparisonDate(firstDate: dateNow, secondDate: dateForAsteroid)

            if value == true { break }
            index += 1
        }
        
        let indexForPictire = comparisonDateForPicture(firstDate: dateNow, secondDate: section[index].close_approach_date)
        if indexForPictire == 1{
            cell.imageLabel.image = UIImage(named: "zelen")
        }else if indexForPictire == 2{
            cell.imageLabel.image = UIImage(named: "zelen2")
        }else{
            cell.imageLabel.image = UIImage(named: "red")
        }
        
        cell.dateApproximationLabel.text  = dateСonversion(date: section[index].close_approach_date)
        let values = UserSettings.valueForFilterMeasurement ?? false
        if values == false{
            let kilometrs                     = section[index].miss_distance.kilometers
            let kilometrsDouble               = Double(kilometrs)
            if let distance = kilometrsDouble{
                let value                         = String(format: "%.0f", distance)
                cell.distanceLabel.text           = "на расстояние \(value) км"
            }else{
                cell.distanceLabel.text           = "на расстояние не найдено"
            }
        }else{
            let kilometrs                     = section[index].miss_distance.lunar
            let kilometrsDouble               = Double(kilometrs)
            if let distance = kilometrsDouble{
                let value                         = String(format: "%.0f", distance)
                cell.distanceLabel.text           = "на расстояние \(value) л.орб."
            }else{
                cell.distanceLabel.text           = "на расстояние не найдено"
            }
        }

        let danger = asteroids.near_earth_objects[indexPath.row].is_potentially_hazardous_asteroid
        if danger == true {
            cell.dangerLabel.text       = "опасен"
            cell.dangerLabel.textColor  = .red
            cell.dangerLabel.font       = UIFont(name:"HelveticaNeue-Bold", size: 17.0)
        }else{
            cell.dangerLabel.text       = "не опасен"
            cell.dangerLabel.textColor  = .black
            cell.dangerLabel.font       = UIFont(name:"System", size: 17.0)
        }
        
        return cell
    }
    
    
    
    func comparisonDateForPicture(firstDate: String, secondDate: String) -> Int {
        let arrDateFirst     = firstDate.components(separatedBy: "-")
        let arrDateSecond    = secondDate.components(separatedBy: "-")
        var dateArrIntFirst  = [Int]()
        var dateArrIntSecond = [Int]()

        for i in arrDateFirst{
            dateArrIntFirst.append(Int(i)!)
        }
        
        for i in arrDateSecond {
            dateArrIntSecond.append(Int(i)!)
        }
        dateArrIntFirst.reverse()
        let monthDifference = dateArrIntSecond[1] - dateArrIntFirst[1]
        if dateArrIntSecond[0] - dateArrIntFirst[0] == 1 && abs(monthDifference) > 3{
            return 2
        }else if dateArrIntSecond[0] - dateArrIntFirst[0] > 1{
            return 1
        }else{
            return 3
        }
    }
    
    func comparisonDate(firstDate: String, secondDate: String) -> Bool {
        let arrDateFirst     = firstDate.components(separatedBy: "-")
        let arrDateSecond    = secondDate.components(separatedBy: "-")
        var dateArrIntFirst  = [Int]()
        var dateArrIntSecond = [Int]()

        for i in arrDateFirst{
            dateArrIntFirst.append(Int(i)!)
        }
        
        for i in arrDateSecond {
            dateArrIntSecond.append(Int(i)!)
        }
        
        dateArrIntFirst.reverse()
        if dateArrIntFirst[0] > dateArrIntSecond[0]{
            return false
        }else if dateArrIntFirst[0] > dateArrIntSecond[0] && dateArrIntFirst[2] > dateArrIntSecond[2]{
            return false
        }else if dateArrIntFirst[0] > dateArrIntSecond[0] && dateArrIntFirst[2] > dateArrIntSecond[2] && dateArrIntFirst[1] > dateArrIntSecond[1]{
            return false
        }else{
            return true
        }

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
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY        = scrollView.contentOffset.y
        let contentHeight  = scrollView.contentSize.height
        let height         = scrollView.frame.size.height
        
        if offsetY > contentHeight - height{
            DispatchQueue.main.asyncAfter(deadline: .now() + 1 ) {
                if currentPage < self.asteroids.page.total_pages - 1{
                    currentPage = currentPage + 1
                    var asteroid = Asteroids(links: Links.init(next: ""), near_earth_objects: [], page: Pages.init(total_pages: 0))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        asteroid = self.getAsteroids(link: self.asteroids.links.next)
                        self.asteroids.links.next = asteroid.links.next
                        for i in asteroid.near_earth_objects{
                            self.asteroids.near_earth_objects.append(i)
                        }
                        let valueFirst = UserSettings.valueForFilterDanger ?? false
                        if valueFirst == true {
                            self.asteroids = self.getDangerAsteroids(arrAsteroid: self.asteroids)
                        }
                        
                    }
                }
            }
            self.collectionView.reloadData()
        }
    }
}




