import UIKit
import WebKit

class DetailVideoViewController: UIViewController, WKNavigationDelegate, AlertPresentable {
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
        if let title = videoTitle {
            detailVideoView.configureNavigationBar(title: title, target: self, backAction: #selector(backTapped), shareAction: #selector(shareTapped))
        } else {
            showAlert(message: "Отсутствует заголовок")
        }
    }

    private func setupWebView() {
        webView.navigationDelegate = self
        view.addSubview(webView)

        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func loadVideo() {
        guard let videoURLString = videoURL, let url = URL(string: videoURLString) else {
            showAlert(message: "Некорректный URL видео.")
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

    func webView(_: WKWebView, didFail _: WKNavigation!, withError _: Error) {
        showAlert(message: "Не удалось загрузить видео.")
    }
}
