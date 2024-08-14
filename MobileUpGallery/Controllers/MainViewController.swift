import UIKit

class MainViewController: UIViewController, AlertPresentable {
    private let mainView = MainView()
    private let vkNetworkManager = VKNetworkManager.shared

    override func loadView() {
        view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mainView.onError = { [weak self] message in
            self?.showAlert(message: message)
        }

        mainView.setupView()

        if let accessToken = UserDefaults.standard.string(forKey: "vk_access_token") {
            validateToken(accessToken: accessToken)
        } else {
            mainView.button.addTarget(self, action: #selector(openOAuthWebView), for: .touchUpInside)
        }
    }

    private func validateToken(accessToken: String) {
        vkNetworkManager.validateToken(accessToken: accessToken) { [weak self] result in
            switch result {
            case .success:
                self?.openGalleryViewController()
            case .failure:
                self?.showAlert(message: "Не удалось войти. Пожалуйста, войдите снова.") {
                    self?.openOAuthWebView()
                }
            }
        }
    }

    private func openGalleryViewController() {
        let galleryVC = GalleryViewController()
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.pushViewController(galleryVC, animated: true)
    }

    @objc private func openOAuthWebView() {
        let oAuthViewController = OAuthViewController()
        oAuthViewController.modalPresentationStyle = .formSheet
        oAuthViewController.onAuthorizationSuccess = { [weak self] code in
            self?.exchangeCodeForToken(code: code)
        }
        oAuthViewController.onAuthorizationDismiss = { [weak self] in
            self?.showAlert(message: "Авторизация отменена.")
        }
        present(oAuthViewController, animated: true, completion: nil)
    }

    private func exchangeCodeForToken(code: String) {
        vkNetworkManager.exchangeCodeForToken(code: code) { [weak self] result in
            switch result {
            case let .success(tokenResponse):
                UserDefaults.standard.set(tokenResponse.access_token, forKey: "vk_access_token")
                self?.openGalleryViewController()

            case let .failure(error):
                print("Error getting token: \(error)")
                self?.showAlert(message: "Не удалось получить access token.")
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainView.button.addTarget(self, action: #selector(openOAuthWebView), for: .touchUpInside)
    }
}
