import UIKit

class LoadingIndicator {
    private var activityIndicator: UIActivityIndicatorView?

    func initialize(on view: UIView, style: UIActivityIndicatorView.Style = .large, color: UIColor = .black) {
        let indicator = UIActivityIndicatorView(style: style)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = color
        view.addSubview(indicator)

        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        activityIndicator = indicator
    }

    func show() {
        DispatchQueue.main.async {
            self.activityIndicator?.startAnimating()
        }
    }

    func hide() {
        DispatchQueue.main.async {
            self.activityIndicator?.stopAnimating()
        }
    }
}
