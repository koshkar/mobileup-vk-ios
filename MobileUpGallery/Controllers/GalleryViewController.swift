import Alamofire
import UIKit

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private let galleryView = GalleryView()
    private var photos: [MediaItem] = []
    private var videos: [MediaItem] = []

    override func loadView() {
        view = galleryView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        galleryView.collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: "PhotoCell")
        galleryView.collectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: "VideoCell")

        guard let accessToken = UserDefaults.standard.string(forKey: "vk_access_token") else {
            displayError(message: "Не удалось получить токен доступа.")
            return
        }

        fetchAllPhotos(accessToken: accessToken)
        fetchAllVideos(accessToken: accessToken)

        galleryView.segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        galleryView.logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)

        galleryView.collectionView.dataSource = self
        galleryView.collectionView.delegate = self
    }

    private func fetchAllVideos(accessToken: String) {
        let groupId = "128666765"
        let apiVersion = "5.131"
        let apiUrl = "https://api.vk.com/method/video.get"
        
        let parameters: [String: Any] = [
            "owner_id": "-\(groupId)",
            "access_token": accessToken,
            "v": apiVersion,
            "count": 200,
            "extended": 1
        ]
        AF.request(apiUrl, parameters: parameters).responseDecodable(of: VKVideoResponse.self) { response in
            switch response.result {
            case let .success(vkVideoResponse):
                let fetchedVideos = vkVideoResponse.response.items.compactMap { item -> MediaItem? in
                    if let playerUrl = item.player,
                       let date = item.date,
                       let bestImageUrl = item.image?.max(by: { ($0.width ?? 0) < ($1.width ?? 0) })?.url {
                        let mediaItem = MediaItem(url: bestImageUrl, playerUrl: playerUrl, date: date, title: item.title, type: .video)
                        
                        return mediaItem
                    }
                    return nil
                }
                self.videos.append(contentsOf: fetchedVideos)
                
                self.videos.sort(by: { $0.date > $1.date })
                if self.galleryView.segmentedControl.selectedSegmentIndex == 1 {
                    self.galleryView.collectionView.reloadData()
                }
                
            case let .failure(error):
                print("Error fetching videos: \(error)")
                self.displayError(message: "Не удалось загрузить видео.")
            }
        }
    }

    private func fetchAllPhotos(accessToken: String) {
        let groupId = "128666765"
        let apiVersion = "5.131"
        let apiUrl = "https://api.vk.com/method/"
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
                    let fetchedPhotos = vkPhotosResponse.response.items.compactMap { item -> MediaItem? in
                        if let url = item.sizes.last?.url {
                            return MediaItem(url: url, playerUrl: nil, date: item.date, title: nil, type: .photo)
                        }
                        return nil
                    }
                    self.photos.append(contentsOf: fetchedPhotos)

                    if vkPhotosResponse.response.items.count == 100 {
                        fetchPhotosFromAlbum(albumId: albumId, offset: offset + 100)
                    } else if albumIds.isEmpty {
                        self.photos.sort(by: { $0.date > $1.date })
                        if self.galleryView.segmentedControl.selectedSegmentIndex == 0 {
                            self.galleryView.collectionView.reloadData()
                        }
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

    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        galleryView.collectionView.reloadData()
    }

    @objc private func logoutTapped() {
        UserDefaults.standard.removeObject(forKey: "vk_access_token")
        navigationController?.popToRootViewController(animated: true)
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        switch galleryView.segmentedControl.selectedSegmentIndex {
        case 0:
            return photos.count
        case 1:
            return videos.count
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch galleryView.segmentedControl.selectedSegmentIndex {
        case 0:
            let mediaItem = photos[indexPath.item]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell
            cell.configure(with: mediaItem.url)
            return cell
        case 1:
            let mediaItem = videos[indexPath.item]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as! VideoCollectionViewCell
            cell.configure(with: mediaItem.url, title: mediaItem.title)
            return cell
        default:
            fatalError("Unexpected segment index")
        }
    }


    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 4
        let width: CGFloat
        let height: CGFloat

        switch galleryView.segmentedControl.selectedSegmentIndex {
        case 0:
            width = (view.frame.size.width - spacing) / 2
            height = width
        case 1:
            width = view.frame.size.width
            height = 210
        default:
            width = 0
            height = 0
        }

        return CGSize(width: width, height: height)
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch galleryView.segmentedControl.selectedSegmentIndex {
        case 0:
            let mediaItem = photos[indexPath.item]
            let photoViewController = DetailPhotoViewController()
            photoViewController.photoURL = mediaItem.url
            photoViewController.photoDate = Date(timeIntervalSince1970: TimeInterval(mediaItem.date))
            navigationController?.pushViewController(photoViewController, animated: true)
        case 1:
            let mediaItem = videos[indexPath.item]
            let videoViewController = DetailVideoViewController()
            videoViewController.videoURL = mediaItem.playerUrl
            videoViewController.videoTitle = mediaItem.title
            navigationController?.pushViewController(videoViewController, animated: true)
        default:
            break
        }
    }




    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }

    private func displayError(message: String) {
        let errorAlert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(errorAlert, animated: true, completion: nil)
    }
}

struct VKVideoResponse: Decodable {
    let response: VKVideoResponseData
}

struct VKVideoResponseData: Decodable {
    let items: [VKVideoItem]
}

struct VKVideoItem: Decodable {
    let player: String?
    let date: Int?
    let title: String?
    let image: [VKVideoImage]?
}


struct VKVideoImage: Decodable {
    let width: Int?
    let url: String?
}
