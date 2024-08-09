import Alamofire
import UIKit

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private let galleryView = GalleryView()
    private var photos: [String] = []

    override func loadView() {
        view = galleryView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let accessToken = UserDefaults.standard.string(forKey: "vk_access_token") else {
            displayError(message: "Не удалось получить токен доступа.")
            return
        }

        fetchPhotos(accessToken: accessToken)

        galleryView.segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        galleryView.logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)

        galleryView.collectionView.dataSource = self
        galleryView.collectionView.delegate = self
    }

    private func fetchPhotos(accessToken: String) {
        let groupId = "128666765"
        let apiUrl = "https://api.vk.com/method/photos.get"

        let parameters: [String: Any] = [
            "owner_id": "-\(groupId)",
            "album_id": "wall",
            "access_token": accessToken,
            "v": "5.131",
        ]

        AF.request(apiUrl, parameters: parameters).responseDecodable(of: VKPhotosResponse.self) { response in
            switch response.result {
            case let .success(vkPhotosResponse):
                self.photos = vkPhotosResponse.response.items.sorted(by: { $0.date > $1.date }).compactMap { item in
                    if let size = item.sizes.last {
                        return size.url
                    }
                    return nil
                }
                self.galleryView.collectionView.reloadData()
            case let .failure(error):
                print("Error fetching photos: \(error)")
                self.displayError(message: "Не удалось загрузить фотографии.")
            }
        }
    }

    @objc private func segmentChanged(_: UISegmentedControl) {
        galleryView.collectionView.reloadData()
    }

    @objc private func logoutTapped() {
        dismiss(animated: true, completion: nil)
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)

        if let imageView = cell.contentView.viewWithTag(1) as? UIImageView {
            imageView.removeFromSuperview()
        }

        let imageView = UIImageView(frame: cell.contentView.bounds)
        imageView.tag = 1
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        cell.contentView.addSubview(imageView)

        let photoURL = photos[indexPath.item]
        AF.request(photoURL).responseData { response in
            if let data = response.data, let image = UIImage(data: data) {
                imageView.image = image
            }
        }

        return cell
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let width = (view.frame.size.width / 2) - 2
        return CGSize(width: width, height: width)
    }

    private func displayError(message: String) {
        let errorAlert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(errorAlert, animated: true, completion: nil)
    }
}
