import UIKit
import WebKit

class DetailVideoViewController: UIViewController {
    var videoURL: String?
    var videoTitle: String?

    private let webView = WKWebView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        setupWebView()
        loadVideo()
    }

    private func setupNavigationBar() {
        let navigationBar = UINavigationBar(frame: .zero)
        let navigationItem = UINavigationItem(title: videoTitle ?? "Видео")
        let backItem = UIBarButtonItem(title: "Назад", style: .plain, target: self, action: #selector(backTapped))
        let shareItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        navigationItem.leftBarButtonItem = backItem
        navigationItem.rightBarButtonItem = shareItem
        navigationBar.setItems([navigationItem], animated: false)
        view.addSubview(navigationBar)

       
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupWebView() {
        view.addSubview(webView)


        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadVideo() {
        guard let videoURLString = videoURL, let url = URL(string: videoURLString) else {
            displayError(message: "Некорректный URL видео.")
            return
        }

        let request = URLRequest(url: url)
        webView.load(request)
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func shareTapped() {
        guard let videoURL = videoURL, let url = URL(string: videoURL) else { return }
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }

    private func displayError(message: String) {
        let errorAlert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(errorAlert, animated: true, completion: nil)
    }
}
