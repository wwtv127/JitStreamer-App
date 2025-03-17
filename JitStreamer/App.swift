//
//  App.swift
//  JitStreamer EB
//
//  Created by Stossy11 on 17/03/2025.
//

import Foundation

struct Apps: Codable, Identifiable {
    var id: String { bundleID }
    var name: String
    var bundleID: String
    var version: String
    var icon: Data?
}
