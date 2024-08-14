import UIKit

protocol AlertPresentable {
    func showAlert(title: String, message: String, completion: (() -> Void)?)
}

extension AlertPresentable where Self: UIViewController {
    func showAlert(title: String = "Ошибка", message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
