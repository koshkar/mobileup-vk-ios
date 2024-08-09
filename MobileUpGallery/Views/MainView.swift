import UIKit

class MainView: UIView {
    
    let label: UILabel = {
        let label = UILabel()
        label.text = "Mobile Up \nGallery"
        label.textAlignment = .center
        label.textColor = .black
        // Обработка ошибок
        if let customFont = UIFont(name: "SFProText-Bold", size: 44) {
            label.font = customFont
        } else {
            label.font = UIFont.systemFont(ofSize: 44, weight: .bold)
        }
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Вход через VK", for: .normal)
        button.setTitleColor(.white, for: .normal)
        // Обработка ошибок
        if let customFont = UIFont(name: "SFProText-Medium", size: 15) {
            button.titleLabel?.font = customFont
        } else {
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        }
        button.backgroundColor = .black
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        backgroundColor = .white
        addSubview(label)
        addSubview(button)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 170),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            label.heightAnchor.constraint(equalToConstant: 106)
        ])
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 52),
            button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -42)
        ])
    }
}
