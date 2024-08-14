import UIKit

class DetailPhotoViewController: UIViewController, AlertPresentable {
    var photoURL: String?
    var photoDate: Date?
    private let detailPhotoView = DetailPhotoView()

    private let vkNetworkManager = VKNetworkManager.shared
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()

    override func loadView() {
        view = detailPhotoView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        if let urlString = photoURL, let url = URL(string: urlString) {
            loadImage(from: url)
        } else {
            showAlert(message: "Неверный урл")
        }

        setupNavigationBar()
    }

    private func setupNavigationBar() {
        let title = photoDate != nil ? dateFormatter.string(from: photoDate!) : "Photo Detail"

        detailPhotoView.configureNavigationBar(title: title, target: self, backAction: #selector(backButtonTapped), shareAction: #selector(shareButtonTapped))
    }

    @objc private func backButtonTapped() {
        if navigationController != nil {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    @objc private func shareButtonTapped() {
        guard let image = detailPhotoView.imageView.image else { return }
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityController.completionWithItemsHandler = { _, success, _, error in
            if success {
                self.showSuccessAlert()
            } else if let error = error {
                self.showAlert(message: "Не удалось сохранить фотографию: \(error.localizedDescription)")
            }
        }
        present(activityController, animated: true, completion: nil)
    }

    private func showSuccessAlert() {
        let alert = UIAlertController(title: "Успешно", message: "Фотография успешно сохранена!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func loadImage(from url: URL) {
        vkNetworkManager.fetchImage(from: url) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(image):
                    self?.detailPhotoView.imageView.image = image
                case let .failure(error):
                    self?.showAlert(message: "Не удалось загрузить изображение. Ошибка: \(error.localizedDescription)")
                }
            }
        }
    }
}
