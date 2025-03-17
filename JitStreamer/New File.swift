import SwiftUI
import WebKit


struct WebView: UIViewRepresentable {
    
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    func updateUIView(_ webView: WKWebView, context: Context) {
        let url = URL(string: "https://jkcoxson.com/jitstreamer")
        if let url = url {
            
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}

