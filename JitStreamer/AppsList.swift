//
//  AppsList.swift
//  JitStreamer EB
//
//  Created by Stossy11 on 17/03/2025.
//

import SwiftUI

struct AppsListView: View {
    @StateObject var jitstreamer = JitStreamerHandler.shared
    @State var errorMessage = ""
    @State var errorAlert = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Group {
            LazyVStack(spacing: 10) {
                if jitstreamer.apps.isEmpty {
                    HStack {
                        Text("Loading Apps...")
                        
                        ProgressView()
                    }
                } else {
                    ForEach(jitstreamer.apps, id: \.id) { app in
                        Button(action: {
                            dismiss()
                            jitstreamer.enableJIT(app)
                            
                            showJITAlert(message: "JIT is enabling for \(app.name), Please Wait...")
                        }) {
                            VStack {
                                Divider()
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(app.name)
                                            .font(.system(size: 16))
                                            .foregroundColor(.white)
                                        Text(app.bundleID)
                                            .font(.system(size: 11))
                                            .foregroundColor(.white)
                                    }
                                    Spacer()
                                }
                                .padding(.leading, 10)
                                .padding(.horizontal)
                                
                                if let lastapp = jitstreamer.apps.last, lastapp.bundleID == app.bundleID {
                                    Divider()
                                }
                            }
                        }
                    }
                }
            }
            .alert("Error", isPresented: $errorAlert) {
                Button("OK", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text(errorMessage)
            }
            .alert("Error", isPresented: $errorAlert) {
                Button("OK", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                jitstreamer.getApps() { result, error in
                    errorAlert = !result
                    
                    errorMessage = error ?? ""
                }
                
                jitstreamer.objectWillChange.send()
            }
        }
    }
    
    func showJITAlert(message: String) {
        let alert = UIAlertController(title: "JIT Enabling", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        DispatchQueue.main.async {
            UIApplication.shared.windows.last!.rootViewController?.present(alert, animated: true)
        }
    }
}
