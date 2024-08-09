import UIKit

class GalleryView: UIView {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "MobileUp Gallery"
        if let customFont = UIFont(name: "SFProText-SemiBold", size: 17) {
            label.font = customFont
        } else {
            label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        }
        label.textAlignment = .center
        label.textColor = UIColor.black
        return label
    }()

    let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Выход", for: .normal)
        if let customFont = UIFont(name: "SFProText-Regular", size: 17) {
            button.titleLabel?.font = customFont
        } else {
            button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        }
        button.setTitleColor(UIColor.black, for: .normal)
        return button
    }()

    let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Фото", "Видео"])
        control.selectedSegmentIndex = 0

        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "SFProText-Medium", size: 13) ?? UIFont.systemFont(ofSize: 13, weight: .medium),
            .foregroundColor: UIColor.black,
        ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "SFProText-SemiBold", size: 13) ?? UIFont.systemFont(ofSize: 13, weight: .semibold),
            .foregroundColor: UIColor.black,
        ]

        control.setTitleTextAttributes(normalAttributes, for: .normal)
        control.setTitleTextAttributes(selectedAttributes, for: .selected)

        return control
    }()

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        return collectionView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = UIColor.white
        addSubview(titleLabel)
        addSubview(logoutButton)
        addSubview(segmentedControl)
        addSubview(collectionView)
        setupLayout()
    }

    private func setupLayout() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            logoutButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            logoutButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),

            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 26),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: logoutButton.leadingAnchor, constant: -16),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            segmentedControl.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            collectionView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
