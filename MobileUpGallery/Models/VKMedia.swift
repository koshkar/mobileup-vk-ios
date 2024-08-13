import Foundation

struct VKPhotosResponse: Decodable {
    let response: VKPhotoItems
}

struct VKPhotoItems: Decodable {
    let items: [VKPhotoItem]
}

struct VKPhotoItem: Decodable {
    let sizes: [VKPhotoSize]
    let date: Int
}

struct VKPhotoSize: Decodable {
    let url: String
}

struct VKAlbumsResponse: Decodable {
    let response: Response

    struct Response: Decodable {
        let count: Int
        let items: [Album]
    }

    struct Album: Decodable {
        let id: Int
        let title: String
        let size: Int?
    }
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
