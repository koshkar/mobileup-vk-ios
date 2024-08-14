import UIKit

enum DesignSystem {
    enum Fonts {
        static let sfProTextBold44: UIFont = UIFont(name: "SFProText-Bold", size: 44) ?? UIFont.systemFont(ofSize: 44, weight: .bold)
        static let sfProTextMedium15: UIFont = UIFont(name: "SFProText-Medium", size: 15) ?? UIFont.systemFont(ofSize: 15, weight: .medium)
        static let sfProTextSemiBold17: UIFont = UIFont(name: "SFProText-SemiBold", size: 17) ?? UIFont.systemFont(ofSize: 17, weight: .semibold)
        static let sfProTextRegular17: UIFont = UIFont(name: "SFProText-Regular", size: 17) ?? UIFont.systemFont(ofSize: 17, weight: .regular)
        static let sfProTextMedium13: UIFont = UIFont(name: "SFProText-Medium", size: 13) ?? UIFont.systemFont(ofSize: 13, weight: .medium)
        static let sfProTextSemiBold13: UIFont = UIFont(name: "SFProText-SemiBold", size: 13) ?? UIFont.systemFont(ofSize: 13, weight: .semibold)
    }

    enum Icons {
        static let chevron: UIImage? = UIImage(named: "Chevron")
        static let squareAndArrow: UIImage? = UIImage(named: "SquareAndArrow")
    }
}
