import UIKit
import WebKit

class DetailVideoViewController: UIViewController {
    var videoURL: String?
    var videoTitle: String?

    private let webView = WKWebView()
    private let detailVideoView = DetailVideoView()
    
    override func loadView() {
        view = detailVideoView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        setupWebView()
        loadVideo()
    }

    private func setupNavigationBar() {
        let title = videoTitle ?? "Видео"
        detailVideoView.configureNavigationBar(title: title, target: self, backAction: #selector(backTapped), shareAction: #selector(shareTapped))
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
