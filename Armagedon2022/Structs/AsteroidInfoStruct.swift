//
//  AsteroidInfoStruct.swift
//  Armagedon2022
//
//  Created by Alex on 15.04.2022.
//

import Foundation


struct NearEearthObjectsInfo: Codable {
    var links: LinkInfo
    var name: String
    var estimated_diameter: EstimatedDiameterInfo
    var is_potentially_hazardous_asteroid: Bool
    var close_approach_data: [CloseApproachDataInfo]
}

struct LinkInfo: Codable{
    var `self`: String
}

struct EstimatedDiameterInfo: Codable {
    var meters: MetersInfo
}

struct MetersInfo: Codable {
    var estimated_diameter_max: Double?
}

struct CloseApproachDataInfo: Codable {
    var close_approach_date: String
    var close_approach_date_full: String
    var miss_distance: MissDistanceInfo
    var relative_velocity: RelativeVelocityInfo
    var orbiting_body: String
}

struct MissDistanceInfo: Codable {
    var lunar: String
    var kilometers: String
}

struct RelativeVelocityInfo: Codable {
    var kilometers_per_hour: String
}
