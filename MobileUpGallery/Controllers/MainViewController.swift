import UIKit

class MainViewController: UIViewController {
    
    private let mainView = MainView()
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Добавление действия для кнопки
        mainView.button.addTarget(self, action: #selector(openOAuthWebView), for: .touchUpInside)
    }
    
    @objc func openOAuthWebView() {
        let oAuthViewController = OAuthViewController()
        oAuthViewController.modalPresentationStyle = .formSheet
        present(oAuthViewController, animated: true, completion: nil)
    }
}
