import UIKit
import WebKit

class OAuthViewController: UIViewController, WKNavigationDelegate, AlertPresentable {
    private var webView: WKWebView!
    private let loadingIndicator = LoadingIndicator()
    var onAuthorizationSuccess: ((String) -> Void)?
    var onAuthorizationDismiss: (() -> Void)?

    private var isAuthorized: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        webView = WKWebView(frame: view.frame)
        webView.navigationDelegate = self
        view.addSubview(webView)

        loadingIndicator.initialize(on: view)

        let appId = "52123937"
        let redirectUri = "https://koshkar.github.io/mobileup-vk-ios/auth.html"

        let authURL = "https://oauth.vk.com/authorize?client_id=\(appId)&display=page&redirect_uri=\(redirectUri)&scope=photos,video,groups&response_type=code&v=5.131"

        if let url = URL(string: authURL) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

    func webView(_: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
        loadingIndicator.show()
    }

    func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
        loadingIndicator.hide()

        guard let url = webView.url,
                    let components = URLComponents(string: url.absoluteString),
                    let code = components.queryItems?.first(where: { $0.name == "code" })?.value
                else { return }

                isAuthorized = true
                onAuthorizationSuccess?(code)
                dismiss(animated: true, completion: nil)
    }

    func webView(_: WKWebView, didFail _: WKNavigation!, withError _: Error) {
        loadingIndicator.hide()
        showAlert(message: "Не удалось загрузить страницу")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if !isAuthorized, isBeingDismissed || isMovingFromParent {
            onAuthorizationDismiss?()
        }
    }
}
