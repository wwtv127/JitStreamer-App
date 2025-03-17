//
//  GetAppsReturn.swift
//  JitStreamer EB
//
//  Created by Stossy11 on 17/03/2025.
//

import Foundation

struct GetAppsReturn: Codable {
    let ok: Bool
    let apps: [String]
    let bundle_ids: [String: String]
    let error: String?
}
