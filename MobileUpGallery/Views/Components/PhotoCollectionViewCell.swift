import UIKit
import Alamofire

class PhotoCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView()
    let loadingIndicator = UIActivityIndicatorView(style: .medium)
    private var currentURL: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupImageView()
        setupLoadingIndicator()
    }

    required init?(coder: NSCoder) {
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
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    private func setupLoadingIndicator() {
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        loadingIndicator.stopAnimating()
        currentURL = nil
    }

    func configure(with url: String) {
        currentURL = url
        loadingIndicator.startAnimating()
        loadImage(from: url)
    }

    private func loadImage(from url: String) {
        AF.request(url).responseData { [weak self] response in
            guard let self = self else { return }
            self.loadingIndicator.stopAnimating()

            if let data = response.data, let image = UIImage(data: data), self.currentURL == url {
                self.imageView.image = image
            } else {
                self.loadImage(from: url)
            }
        }
    }
}
