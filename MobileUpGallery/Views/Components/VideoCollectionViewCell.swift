import Alamofire
import UIKit

class VideoCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView()
    let playButton = UIButton()
    let titleLabel = PaddingLabel()

    private let imageLoadingIndicator = LoadingIndicator()
    private let textLoadingIndicator = LoadingIndicator()

    private var currentImageURL: String?
    private var currentTextLoadTask: DispatchWorkItem?
    var onLogError: ((String) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        imageLoadingIndicator.initialize(on: imageView)
        textLoadingIndicator.initialize(on: titleLabel)
        setupImageView()
        setupTitleLabel()
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

    private func setupTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        titleLabel.textColor = .black
        if let font = UIFont(name: "SFProText-Medium", size: 13) {
            titleLabel.font = font
        } else {
            onLogError?("Ошибка загрузки шрифта SFProText-Medium")
            titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        }
        titleLabel.numberOfLines = 0
        titleLabel.layer.cornerRadius = 16
        titleLabel.layer.masksToBounds = true
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.textInsets = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
        titleLabel.isHidden = true
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 70),
            titleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: contentView.frame.width - 131 - 16),
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        imageLoadingIndicator.show()
        textLoadingIndicator.show()
        currentImageURL = nil
        titleLabel.text = nil
        titleLabel.isHidden = true
        currentTextLoadTask?.cancel()
    }

    func configure(with url: String, title: String?) {
        currentImageURL = url
        loadText(title)
        loadImage(from: url)
    }

    private func loadImage(from url: String) {
        imageLoadingIndicator.show()

        AF.request(url).responseData { [weak self] response in
            guard let self = self, self.currentImageURL == url else { return }

            if let data = response.data, let image = UIImage(data: data) {
                self.imageView.image = image
            }

            self.imageLoadingIndicator.hide()
        }
    }

    private func loadText(_ text: String?) {
        currentTextLoadTask?.cancel()

        textLoadingIndicator.show()
        titleLabel.isHidden = true

        let task = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.textLoadingIndicator.hide()
                self.titleLabel.text = text
                self.titleLabel.isHidden = false
            }
        }

        currentTextLoadTask = task
        DispatchQueue.global().async(execute: task)
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
