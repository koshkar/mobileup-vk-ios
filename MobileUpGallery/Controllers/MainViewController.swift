import Alamofire
import UIKit

class MainViewController: UIViewController {
    private let mainView = MainView()

    override func loadView() {
        view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mainView.onError = { [weak self] message in
            self?.displayError(message: message)
        }

        mainView.setupView()

        mainView.button.addTarget(self, action: #selector(openOAuthWebView), for: .touchUpInside)
    }

    private func displayError(message: String) {
        let errorAlert = ErrorAlertView(message: message)
        errorAlert.show(in: view)
    }

    @objc func openOAuthWebView() {
        let oAuthViewController = OAuthViewController()
        oAuthViewController.modalPresentationStyle = .formSheet

        oAuthViewController.onAuthorizationSuccess = { [weak self] code in
            self?.exchangeCodeForToken(code: code)
        }

        present(oAuthViewController, animated: true, completion: nil)
    }

    private func exchangeCodeForToken(code: String) {
        let appId = "52123937"
        let clientSecret = "DDabodopfkODj4KXksrd"
        let redirectUri = "https://koshkar.github.io/mobileup-vk-ios/auth.html"

        let tokenUrl = "https://oauth.vk.com/access_token"
        let parameters: [String: Any] = [
            "client_id": appId,
            "client_secret": clientSecret,
            "redirect_uri": redirectUri,
            "code": code,
        ]

        AF.request(tokenUrl, parameters: parameters).responseDecodable(of: VKTokenResponse.self) { response in
            switch response.result {
            case let .success(tokenResponse):
                UserDefaults.standard.set(tokenResponse.access_token, forKey: "vk_access_token")

                let galleryVC = GalleryViewController()
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.navigationController?.pushViewController(galleryVC, animated: true)

            case let .failure(error):
                print("Error getting token: \(error)")
                self.displayError(message: "Не удалось получить access token.")
            }
        }
    }
}
