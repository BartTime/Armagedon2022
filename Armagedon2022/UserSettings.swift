//
//  UserSettings.swift
//  Armagedon2022
//
//  Created by Alex on 17.04.2022.
//

import Foundation


class UserSettings {
    
    private enum SettingKey: String {
        case FilterMeasurement
        case FilterDanger
    }
    
    static var valueForFilterMeasurement: Bool! {
        get{
            return UserDefaults.standard.bool(forKey: SettingKey.FilterMeasurement.rawValue)
        } set {
            let defaults = UserDefaults.standard
            let key      = SettingKey.FilterMeasurement.rawValue
            if let value = newValue {
                defaults.set(value, forKey: key)
            }else{
                defaults.removeObject(forKey: key)
            }
            
        }
    }
    
    static var valueForFilterDanger: Bool! {
        get{
            return UserDefaults.standard.bool(forKey: SettingKey.FilterDanger.rawValue)
        } set {
            let defaults = UserDefaults.standard
            let key      = SettingKey.FilterDanger.rawValue
            if let value = newValue {
                defaults.set(value, forKey: key)
            }else{
                defaults.removeObject(forKey: key)
            }
        }
    }
    
}
