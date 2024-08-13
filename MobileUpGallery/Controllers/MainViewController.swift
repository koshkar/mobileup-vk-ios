import UIKit

class MainViewController: UIViewController {
    private let mainView = MainView()
    private let vkNetworkManager = VKNetworkManager.shared

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
        vkNetworkManager.validateToken(accessToken: accessToken) { [weak self] result in
            switch result {
            case .success:
                self?.openGalleryViewController()
            case .failure:
                self?.displayErrorWithCompletion(message: "Не удалось войти. Пожалуйста, войдите снова.") {
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
            self?.displayError(message: "Авторизация отменена.")
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
                self?.displayError(message: "Не удалось получить access token.")
            }
        }
    }

    private func displayErrorWithCompletion(message: String, completion: @escaping () -> Void) {
        let errorAlert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion()
        })
        present(errorAlert, animated: true, completion: nil)
    }

    private func displayError(message: String) {
        let errorAlert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(errorAlert, animated: true, completion: nil)
    }
    
    // MARK: - View life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        mainView.button.addTarget(self, action: #selector(openOAuthWebView), for: .touchUpInside)
    }
}
