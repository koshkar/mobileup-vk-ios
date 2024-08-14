import Foundation

struct VKPhotoItems: Decodable {
    let items: [VKPhotoItem]
}

struct VKPhotoItem: Decodable {
    let sizes: [VKPhotoSize]
    let date: Int
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

struct VKPhotoSize: Decodable {
    let url: String
}

struct MediaItem {
    let url: String
    let playerUrl: String?
    let date: Int
    let title: String?
    let type: MediaType
}

enum MediaType {
    case photo
    case video
}
