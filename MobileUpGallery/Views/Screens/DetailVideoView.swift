import UIKit
import AVKit

class DetailVideoView: UIView {
    let navigationBar = UINavigationBar()
    let playerViewController = AVPlayerViewController()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupNavigationBar()
        setupPlayerView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupNavigationBar()
        setupPlayerView()
    }

    private func setupNavigationBar() {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.barTintColor = .white
        navigationBar.isTranslucent = false
        addSubview(navigationBar)

        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    private func setupPlayerView() {
        playerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(playerViewController.view)

        NSLayoutConstraint.activate([
            playerViewController.view.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            playerViewController.view.bottomAnchor.constraint(equalTo: bottomAnchor),
            playerViewController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            playerViewController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    func configureNavigationBar(title: String, target: Any?, backAction: Selector, shareAction: Selector) {
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "SFProText-SemiBold", size: 17) ?? UIFont.systemFont(ofSize: 17, weight: .semibold),
            .foregroundColor: UIColor.black,
        ]
        let attributedTitle = NSAttributedString(string: title, attributes: titleAttributes)

        let titleLabel = UILabel()
        titleLabel.attributedText = attributedTitle
        titleLabel.sizeToFit()

        let navigationItem = UINavigationItem()
        navigationItem.titleView = titleLabel

        let backButton = UIBarButtonItem(image: UIImage(named: "Chevron"), style: .plain, target: target, action: backAction)
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton

        let shareButton = UIBarButtonItem(image: UIImage(named: "SquareAndArrow"), style: .plain, target: target, action: shareAction)
        shareButton.tintColor = .black
        navigationItem.rightBarButtonItem = shareButton

        navigationBar.setItems([navigationItem], animated: false)
    }
}
