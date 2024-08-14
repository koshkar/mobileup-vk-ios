import Foundation

struct VKTokenResponse: Decodable {
    let access_token: String
    let expires_in: Int
    let user_id: Int
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

struct VKPhotosResponse: Decodable {
    let response: VKPhotoItems
}

struct VKVideoResponse: Decodable {
    let response: VKVideoResponseData
}

struct VKVideoResponseData: Decodable {
    let items: [VKVideoItem]
}
