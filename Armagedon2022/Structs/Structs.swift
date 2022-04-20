//
//  Structs.swift
//  Armagedon2022
//
//  Created by Alex on 13.04.2022.
//

import Foundation

struct Filter {
    var name: String
    var value: Bool
    var tag: Int
}


struct Asteroids: Codable{
    var links: Links
    var near_earth_objects: [NearEearthObjects]
    var page: Pages
}

struct Pages: Codable {
    var total_pages: Int
}

struct Links: Codable{
    var next: String
}
struct NearEearthObjects: Codable {
    var links: Link
    var name: String
    var estimated_diameter: EstimatedDiameter
    var is_potentially_hazardous_asteroid: Bool
    var close_approach_data: [CloseApproachData]
}

struct Link: Codable{
    var `self`: String
}

struct EstimatedDiameter: Codable {
    var meters: Meters
}

struct Meters: Codable {
    var estimated_diameter_max: Double?
}

struct CloseApproachData: Codable {
    var close_approach_date: String
    var miss_distance: MissDistance
}

struct MissDistance: Codable {
    var lunar: String
    var kilometers: String
}






