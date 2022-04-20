//
//  FilterController.swift
//  Armagedon2022
//
//  Created by Alex on 14.04.2022.
//

import UIKit

class FilterController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var items: [Filter] = {
        var someItems = [Filter]()
        someItems.append(Filter(name: "FilterMeasurement", value: false, tag: 0))
        someItems.append(Filter(name: "FilterDanger", value: false, tag: 1))
        return someItems
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate    = self
        tableView.dataSource  = self
        
    }
    @IBAction func changeButtonPressed(_ sender: Any) {
        let firstIndexPath = IndexPath(row: 0, section: 0)
        let seconIndexPath = IndexPath(row: 1, section: 0)
        let Firstcell      = tableView.cellForRow(at: firstIndexPath) as! FilterMeasurementCell
        let Secondcell     = tableView.cellForRow(at: seconIndexPath) as! FilterDangerCell
        
        if Firstcell.segmentalController.selectedSegmentIndex == 0{
            UserSettings.valueForFilterMeasurement = false
        }else{
            UserSettings.valueForFilterMeasurement = true
        }
        
        UserSettings.valueForFilterDanger = Secondcell.switcher.isOn
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension FilterController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return items.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if items[indexPath.row].tag == 0{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterMeasurementCell", for: indexPath) as? FilterMeasurementCell else { return UITableViewCell() }
            
            cell.clipsToBounds = true
            cell.layer.cornerRadius = 10
            cell.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            let values = UserSettings.valueForFilterMeasurement ?? false
            
            if values == true {
                cell.segmentalController.selectedSegmentIndex = 1
            }else{
                cell.segmentalController.selectedSegmentIndex = 0
            }
            
            return cell
            
        }else if items[indexPath.row].tag == 1{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterDangerCell", for: indexPath) as? FilterDangerCell else { return UITableViewCell() }
            cell.clipsToBounds = true
            cell.layer.cornerRadius = 10
            let values = UserSettings.valueForFilterDanger ?? false
            if values == true{
                cell.switcher.setOn(true, animated: true)
            }else{
                cell.switcher.setOn(false, animated: true)
            }
            
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            return cell
        }
        
        return UITableViewCell()
    }
    
}
