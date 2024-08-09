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
