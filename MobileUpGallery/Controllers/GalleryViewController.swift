import Alamofire
import UIKit

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private let galleryView = GalleryView()
    private var photos: [(url: String, date: Int)] = [] // Массив теперь хранит пары (url, date)

    override func loadView() {
        view = galleryView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let accessToken = UserDefaults.standard.string(forKey: "vk_access_token") else {
            displayError(message: "Не удалось получить токен доступа.")
            return
        }

        fetchAllPhotos(accessToken: accessToken)

        galleryView.segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        galleryView.logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)

        galleryView.collectionView.dataSource = self
        galleryView.collectionView.delegate = self
    }

    private func fetchAllPhotos(accessToken: String) {
        let groupId = "128666765"
        let apiVersion = "5.131"
        let apiUrl = "https://api.vk.com/method/"
        var allPhotos: [(url: String, date: Int)] = []
        var albumIds: [String] = []

        func fetchPhotosFromAlbum(albumId: String, offset: Int = 0) {
            let parameters: [String: Any] = [
                "owner_id": "-\(groupId)",
                "album_id": albumId,
                "access_token": accessToken,
                "v": apiVersion,
                "count": 100,
                "offset": offset,
            ]

            AF.request(apiUrl + "photos.get", parameters: parameters).responseDecodable(of: VKPhotosResponse.self) { response in
                switch response.result {
                case let .success(vkPhotosResponse):
                    let fetchedPhotos = vkPhotosResponse.response.items.compactMap { item -> (String, Int)? in
                        if let url = item.sizes.last?.url {
                            return (url: url, date: item.date)
                        }
                        return nil
                    }
                    allPhotos.append(contentsOf: fetchedPhotos)

                    if vkPhotosResponse.response.items.count == 100 {
                        fetchPhotosFromAlbum(albumId: albumId, offset: offset + 100)
                    } else if albumIds.isEmpty {
                        self.photos = allPhotos.sorted(by: { $0.date > $1.date })
                        self.galleryView.collectionView.reloadData()
                    } else {
                        fetchPhotosFromNextAlbum()
                    }
                case let .failure(error):
                    print("Error fetching photos from album \(albumId): \(error)")
                    self.displayError(message: "Не удалось загрузить фотографии.")
                }
            }
        }

        func fetchPhotosFromNextAlbum() {
            if !albumIds.isEmpty {
                let nextAlbumId = albumIds.removeFirst()
                fetchPhotosFromAlbum(albumId: nextAlbumId)
            }
        }

        func fetchAlbumIds() {
            let parameters: [String: Any] = [
                "owner_id": "-\(groupId)",
                "access_token": accessToken,
                "v": apiVersion,
            ]

            AF.request(apiUrl + "photos.getAlbums", parameters: parameters).responseDecodable(of: VKAlbumsResponse.self) { response in
                switch response.result {
                case let .success(vkAlbumsResponse):
                    let allowedAlbumIds = ["266310117", "266310086", "269543385", "270745774", "269548231", "266276915"]

                    albumIds = vkAlbumsResponse.response.items.map { "\($0.id)" }.filter { allowedAlbumIds.contains($0) }

                    fetchPhotosFromNextAlbum()

                case let .failure(error):
                    print("Error fetching albums: \(error)")
                    self.displayError(message: "Не удалось загрузить альбомы.")
                }
            }
        }

        fetchAlbumIds()
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

        let photoURL = photos[indexPath.item].url
        AF.request(photoURL).responseData { response in
            if let data = response.data, let image = UIImage(data: data) {
                imageView.image = image
            }
        }

        return cell
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoURL = photos[indexPath.item].url
        let photoDate = Date(timeIntervalSince1970: TimeInterval(photos[indexPath.item].date)) // Преобразование даты из UNIX timestamp

        let photoViewController = DetailPhotoViewController()
        photoViewController.photoURL = photoURL
        photoViewController.photoDate = photoDate
        navigationController?.pushViewController(photoViewController, animated: true)
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
