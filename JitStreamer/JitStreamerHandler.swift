//
//  JitStreamerHandler.swift
//  JitStreamer EB
//
//  Created by Stossy11 on 17/03/2025.
//

import Foundation
import UIKit

class JitStreamerHandler: ObservableObject {
    var jitstreamerURL =  URL(string: "http://[fd00::]:9172")!

    @Published var apps: [Apps] = []
    
    private init() {}
    
    static var shared = JitStreamerHandler()
    
    
    func detectIfCurrentVersion(_ escaping: @escaping (Bool, String?) -> Void) {
        var request = URLRequest(url: jitstreamerURL.appendingPathComponent("/version"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: AnyHashable] = [
            "version": "0.2.0"
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                escaping(false, error!.localizedDescription)
                return
            }
            
            do {
                let response = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                let jsonString = String(data: data, encoding: .utf8) ?? ""
                print(jsonString)
                escaping(true, nil)
            } catch {
                print(error)
                escaping(false, error.localizedDescription)
            }
        }
        task.resume()
    }
    
    func getApps(_ escaping: @escaping (Bool, String?) -> Void) {
        var request = URLRequest(url: jitstreamerURL.appendingPathComponent("get_apps"))
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                escaping(false, error!.localizedDescription)
                return
            }
            
            do {
                print(String(data: data, encoding: .utf8) ?? "")
                let result = try JSONDecoder().decode(GetAppsReturn.self, from: data)
                if result.ok {
                    DispatchQueue.main.async {
                        self.apps = []
                    }
                    
                    for (appName, bundleID) in result.bundle_ids {
                        if bundleID.contains(" ") { continue }
                        
                        let app = Apps(name: appName, bundleID: bundleID, version: "")
                        
                        DispatchQueue.main.async {
                            self.apps.append(app)
                        }
                    }
                    
                    escaping(true, nil)
                } else {
                    escaping(false, result.error ?? "Unknown Error")
                }
            } catch {
                print(error)
                escaping(false, error.localizedDescription)
            }
        }
        task.resume()
    }
    

    func enableJIT(_ app: Apps)  {
        let bundleID = app.bundleID
        
        
        let url = jitstreamerURL.appendingPathComponent("launch_app").appendingPathComponent(bundleID)
        
        print("hi \(url)")
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                return
            }
            
            DispatchQueue.main.async {
                self.showLaunchAppAlert(jsonData: data!, in: UIApplication.shared.windows.last!.rootViewController!)
            }
            
            return
        }
        
        task.resume()
    }
    
    

    func showLaunchAppAlert(jsonData: Data, in viewController: UIViewController) {
        do {
            let result = try JSONDecoder().decode(LaunchApp.self, from: jsonData)
            
            var message = ""
            
            if let error = result.error {
                message = "Error: \(error)"
            } else if result.mounting {
                message = "App is mounting..."
            } else if result.launching {
                message = "App is launching..."
            } else {
                message = "App launch status unknown."
            }
            
            if let position = result.position {
                message += "\nPosition: \(position)"
            }
            
            let alert = UIAlertController(title: "Launch Status", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            DispatchQueue.main.async {
                viewController.present(alert, animated: true)
            }
            
        } catch {
            let alert = UIAlertController(title: "Decoding Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            DispatchQueue.main.async {
                viewController.present(alert, animated: true)
            }
        }
    }
}
