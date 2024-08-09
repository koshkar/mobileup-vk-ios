import UIKit

class MainViewController: UIViewController {
    
    private let mainView = MainView()
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.onError = { [weak self] message in
            self?.displayError(message: message)
        }
        
        mainView.setupView()
        
        // Добавление действия для кнопки
        mainView.button.addTarget(self, action: #selector(openOAuthWebView), for: .touchUpInside)
    }
    
    private func displayError(message: String) {
        let errorAlert = ErrorAlertView(message: message)
        errorAlert.show(in: view)
    }
    
    @objc func openOAuthWebView() {
        let oAuthViewController = OAuthViewController()
        oAuthViewController.modalPresentationStyle = .formSheet
        present(oAuthViewController, animated: true, completion: nil)
    }
}
