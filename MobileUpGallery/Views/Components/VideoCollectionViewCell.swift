import UIKit
import Alamofire

class VideoCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView()
    let playButton = UIButton()
    let loadingIndicator = UIActivityIndicatorView(style: .medium)
    let titleLabel = PaddingLabel()
    private var currentURL: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupImageView()
        setupLoadingIndicator()
        setupTitleLabel()
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

    private func setupTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        titleLabel.textColor = .black
        titleLabel.font = UIFont(name: "SFProText-Medium", size: 13) ?? UIFont.systemFont(ofSize: 13, weight: .medium)
        titleLabel.numberOfLines = 0
        titleLabel.layer.cornerRadius = 16
        titleLabel.layer.masksToBounds = true
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.textInsets = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 70),
            titleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: contentView.frame.width - 131 - 16)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        loadingIndicator.stopAnimating()
        currentURL = nil
        titleLabel.text = nil
    }

    func configure(with url: String, title: String?) {
        currentURL = url
        titleLabel.text = title
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


extension VideoCollectionViewCell {
    class PaddingLabel: UILabel {
        var textInsets = UIEdgeInsets.zero {
            didSet { invalidateIntrinsicContentSize() }
        }

        override func drawText(in rect: CGRect) {
            super.drawText(in: rect.inset(by: textInsets))
        }

        override var intrinsicContentSize: CGSize {
            let size = super.intrinsicContentSize
            return CGSize(width: size.width + textInsets.left + textInsets.right,
                          height: size.height + textInsets.top + textInsets.bottom)
        }

        override var bounds: CGRect {
            didSet {
                preferredMaxLayoutWidth = bounds.width - (textInsets.left + textInsets.right)
            }
        }
    }

}
