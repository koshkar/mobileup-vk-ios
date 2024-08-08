import UIKit
import WebKit

class OAuthViewController: UIViewController, WKNavigationDelegate {
    
    private let oAuthView = OAuthView()
    
    override func loadView() {
        self.view = oAuthView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        oAuthView.webView.navigationDelegate = self
        
        // URL для авторизации в ВКонтакте
        let clientId = "YOUR_CLIENT_ID"
        let redirectUri = "YOUR_REDIRECT_URI"
        let scope = "friends" // Права доступа, которые вы запрашиваете
        let authURLString = "https://oauth.vk.com/authorize?client_id=\(clientId)&redirect_uri=\(redirectUri)&scope=\(scope)&response_type=token&v=5.131"
        
        if let authURL = URL(string: authURLString) {
            let request = URLRequest(url: authURL)
            oAuthView.webView.load(request)
        }
    }
    
    // Закрытие WebView по завершению авторизации
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Здесь вы можете обработать ответ и закрыть WebView, если авторизация прошла успешно
        // Например, если ваш redirect_uri содержит access_token, вы можете извлечь его и закрыть WebView
        if let url = webView.url, url.absoluteString.contains("access_token") {
            dismiss(animated: true, completion: nil)
        }
    }
    
    // Обработка ошибок загрузки
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Failed to load page: \(error.localizedDescription)")
    }
}
