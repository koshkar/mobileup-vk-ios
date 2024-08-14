import Alamofire
import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView()
    private var currentURL: String?

    private let loadingIndicator = LoadingIndicator()

    var onLogError: ((String) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        loadingIndicator.initialize(on: imageView)
        setupImageView()
    }

    required init?(coder _: NSCoder) {
        onLogError?("Это не должно тут имплементиться")
        fatalError("init(coder:) has not been implemented")
    }

    private func setupImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        loadingIndicator.show()
        currentURL = nil
    }

    func configure(with url: String) {
        currentURL = url
        loadImage(from: url)
    }

    private func loadImage(from url: String) {
        loadingIndicator.show()

        AF.request(url).responseData { [weak self] response in
            guard let self = self else { return }

            if let data = response.data, let image = UIImage(data: data), self.currentURL == url {
                self.imageView.image = image
            } else {
                self.loadImage(from: url)
            }

            self.loadingIndicator.hide()
        }
    }
}
