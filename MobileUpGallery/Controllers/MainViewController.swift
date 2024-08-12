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

        if let accessToken = UserDefaults.standard.string(forKey: "vk_access_token") {
            validateToken(accessToken: accessToken)
        } else {
            mainView.button.addTarget(self, action: #selector(openOAuthWebView), for: .touchUpInside)
        }
    }

    private func validateToken(accessToken: String) {
        let tokenUrl = "https://api.vk.com/method/users.get"
        let parameters: [String: Any] = [
            "access_token": accessToken,
            "v": "5.131"
        ]

        AF.request(tokenUrl, parameters: parameters).responseDecodable(of: VKUserResponse.self) { response in
            switch response.result {
            case .success:
                self.openGalleryViewController()
            case .failure:
                self.displayError(message: "Не удалось войти. Пожалуйста, войдите снова.")
                self.openOAuthWebView()
            }
        }
    }

    private func openGalleryViewController() {
        let galleryVC = GalleryViewController()
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.pushViewController(galleryVC, animated: true)
    }

    private func displayError(message: String) {
        let errorAlert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(errorAlert, animated: true, completion: nil)
    }

    @objc private func openOAuthWebView() {
        let oAuthViewController = OAuthViewController()
        oAuthViewController.modalPresentationStyle = .formSheet
        oAuthViewController.onAuthorizationSuccess = { [weak self] code in
            self?.exchangeCodeForToken(code: code)
        }
        oAuthViewController.onAuthorizationDismiss = { [weak self] in
            self?.displayError(message: "Авторизация отменена.")
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
                self.openGalleryViewController()

            case let .failure(error):
                print("Error getting token: \(error)")
                self.displayError(message: "Не удалось получить access token.")
            }
        }
    }
}

struct VKUserResponse: Decodable {
    let response: [VKUser]

    struct VKUser: Decodable {
        let id: Int
        let first_name: String
        let last_name: String
    }
}
