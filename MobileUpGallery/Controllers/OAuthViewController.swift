import UIKit
import WebKit

class OAuthViewController: UIViewController, WKNavigationDelegate {
    private var webView: WKWebView!
    private var activityIndicator: UIActivityIndicatorView!
    var onAuthorizationSuccess: ((String) -> Void)?
    var onAuthorizationDismiss: (() -> Void)?
    
    private var isAuthorized: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        webView = WKWebView(frame: view.frame)
        webView.navigationDelegate = self
        view.addSubview(webView)

        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)

        let appId = "52123937"
        let redirectUri = "https://koshkar.github.io/mobileup-vk-ios/auth.html"

        let authURL = "https://oauth.vk.com/authorize?client_id=\(appId)&display=page&redirect_uri=\(redirectUri)&scope=photos,video,groups&response_type=code&v=5.131"


        if let url = URL(string: authURL) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

    func webView(_: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
        activityIndicator.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
        activityIndicator.stopAnimating()

        if let url = webView.url, url.absoluteString.contains("code=") {
            if let code = URLComponents(string: url.absoluteString)?
                .queryItems?.first(where: { $0.name == "code" })?.value
            {
                isAuthorized = true
                onAuthorizationSuccess?(code)
                dismiss(animated: true, completion: nil)
            }
        }
    }

    func webView(_: WKWebView, didFail _: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        print("Failed to load page: \(error.localizedDescription)")
    }
    
    // MARK: - View life cycle
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !isAuthorized && (self.isBeingDismissed || self.isMovingFromParent) {
            onAuthorizationDismiss?()
        }
    }
}
