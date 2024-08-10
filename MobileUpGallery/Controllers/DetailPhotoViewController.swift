import UIKit

class DetailPhotoViewController: UIViewController {
    var photoURL: String?
    var photoDate: Date?
    private let detailPhotoView = DetailPhotoView()

    override func loadView() {
        view = detailPhotoView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        if let urlString = photoURL, let url = URL(string: urlString) {
            loadImage(from: url)
        }

        setupNavigationBar()
    }

    private func setupNavigationBar() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        dateFormatter.locale = Locale(identifier: "ru_RU")

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
                self.displayError(message: "Не удалось сохранить фотографию: \(error.localizedDescription)")
            }
        }
        present(activityController, animated: true, completion: nil)
    }

    private func showSuccessAlert() {
        let alert = UIAlertController(title: "Успешно", message: "Фотография успешно сохранена!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func displayError(message: String) {
        let errorAlert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(errorAlert, animated: true, completion: nil)
    }

    private func loadImage(from url: URL) {
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("Failed to load image: \(String(describing: error))")
                return
            }
            DispatchQueue.main.async {
                self.detailPhotoView.imageView.image = UIImage(data: data)
            }
        }
        task.resume()
    }
}
