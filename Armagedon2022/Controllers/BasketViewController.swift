//
//  BasketViewController.swift
//  Armagedon2022
//
//  Created by Alex on 16.04.2022.
//

import UIKit
import CoreData

var dataStorageManger    = DataStorageManger()
var fetchResultController: NSFetchedResultsController<BasketForDestruction>!

let fetchRequest: NSFetchRequest<BasketForDestruction> = BasketForDestruction.fetchRequest()
let sortDescriptor = NSSortDescriptor(key: "linkToAsteroid", ascending: true)

var count = 0

class BasketViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var asteroid             = NearEearthObjectsInfo(links: LinkInfo(self: ""), name: "", estimated_diameter: EstimatedDiameterInfo(meters: MetersInfo()), is_potentially_hazardous_asteroid: false, close_approach_data: [])
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataStorageManger.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        count = 0
        try! fetchResultController.performFetch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataStorageManger.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        try! fetchResultController.performFetch()
        count = 0
        collectionView.reloadData()
    }
  
 
}

extension BasketViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = fetchResultController.sections?[section]
        count = sectionInfo?.numberOfObjects ?? 0
        return (sectionInfo?.numberOfObjects ?? 0) + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if count > indexPath.row{
            return CGSize(width: view.frame.width - 30, height: view.frame.height/2.8)
        }else{
            return CGSize(width: view.frame.width - 20, height: view.frame.height/10)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 20,left: 15,bottom: 40,right: 15)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if count > indexPath.row{
            guard var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BasketToDestroyCell", for: indexPath) as? BasketToDestroyCell else { return UICollectionViewCell() }
            cell = configureCell(cell: cell)
            let linkasteroids = fetchResultController.object(at: indexPath)
            cell = setValueInCell(cell: cell, indexPath: indexPath, link: linkasteroids)
            
            cell.notDestroyButton.tag = indexPath.row
            cell.notDestroyButton.addTarget(self, action: #selector(didTapCellButton(sender:)), for: .touchUpInside)
            return cell
        }else{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ButtonToDestroyCell", for: indexPath) as? ButtonToDestroyCell else { return UICollectionViewCell() }
            return cell
        }
    }
    
    @objc func didTapCellButton(sender: UIButton) {
        let index        = sender.tag
        let myIndexPath  = IndexPath(row: index, section: 0)
        let link = fetchResultController.object(at: myIndexPath)
        
        dataStorageManger.viewContext.delete(link)
        dataStorageManger.saveContext()
        collectionView.deleteItems(at: [myIndexPath])
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataStorageManger.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        try! fetchResultController.performFetch()
        count = 0
        self.collectionView.reloadData()
    }
    
    func configureCell(cell: BasketToDestroyCell) -> BasketToDestroyCell{
        cell.contentView.backgroundColor = UIColor.clear
        
        let whiteRoundedView : UIView = UIView(frame: CGRect(x: 10, y: 8, width: self.view.frame.size.width - 50, height: self.view.frame.height/2.8 - 10))
        
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
    
    func setValueInCell(cell: BasketToDestroyCell, indexPath: IndexPath, link: BasketForDestruction) -> BasketToDestroyCell {
 
        let dateFormatter         = DateFormatter()
        dateFormatter.dateFormat  = "MM-dd-yyyy"
        let infoAboutAsteroid     = getInfoAboutAsteroid(link: link)
        let index                 = link.index
        
        cell.nameAsteroid.text    = infoAboutAsteroid.name
        let section = infoAboutAsteroid.close_approach_data

        let someDate             = dateСonversion(date: section[Int(index)].close_approach_date)
        cell.dateLabel.text      = someDate
        
        let diameter = infoAboutAsteroid.estimated_diameter.meters.estimated_diameter_max
        if let diameter  = diameter {
             let finalValue         = String(format: "%.0f", diameter)
            cell.diameterLabel.text = "Размер: \(finalValue) м"
        }else{ cell.diameterLabel.text  = "Размер: не указан" }
       
        
        let values = UserSettings.valueForFilterMeasurement ?? false
        if values == false{
            let kilometrs                     = section[Int(index)].miss_distance.kilometers
            let kilometrsDouble               = Double(kilometrs)
            if let distance = kilometrsDouble{
                let value                         = String(format: "%.0f", distance)
                cell.distanceLabel.text           = "на расстояние \(value) км"
            }else{
                cell.distanceLabel.text           = "на расстояние не найдено"
            }
        }else{
            let kilometrs                     = section[Int(index)].miss_distance.lunar
            let kilometrsDouble               = Double(kilometrs)
            if let distance = kilometrsDouble{
                let value                         = String(format: "%.0f", distance)
                cell.distanceLabel.text           = "на расстояние \(value) л.орб."
            }else{
                cell.distanceLabel.text           = "на расстояние не найдено"
            }
        }
        
        let danger = infoAboutAsteroid.is_potentially_hazardous_asteroid
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
    
    func getInfoAboutAsteroid(link: BasketForDestruction) -> NearEearthObjectsInfo {
        var asteroids = NearEearthObjectsInfo(links: LinkInfo(self: ""), name: "", estimated_diameter: EstimatedDiameterInfo(meters: MetersInfo()), is_potentially_hazardous_asteroid: false, close_approach_data: [])
        
        guard let someUrl = link.linkToAsteroid else { return asteroids }
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
    
    
}
