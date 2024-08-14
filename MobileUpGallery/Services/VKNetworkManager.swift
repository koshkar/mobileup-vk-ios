import Alamofire
import Foundation
import UIKit

class VKNetworkManager {
    static let shared = VKNetworkManager()

    private init() {}

    func fetchImage(from url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let data = data, let image = UIImage(data: data) {
                completion(.success(image))
            } else {
                let error = NSError(domain: "VKNetworkManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to load image"])
                completion(.failure(error))
            }
        }
        task.resume()
    }

    func fetchVideos(accessToken: String, completion: @escaping (Result<[MediaItem], Error>) -> Void) {
        let parameters: [String: Any] = [
            "owner_id": "-\(Constants.groupId)",
            "access_token": accessToken,
            "v": Constants.apiVersion,
            "count": 200,
            "extended": 1,
        ]
        let url = Constants.fetchApiUrl + "video.get"

        AF.request(url, parameters: parameters).responseDecodable(of: VKVideoResponse.self) { response in
            switch response.result {
            case let .success(vkVideoResponse):
                let fetchedVideos = vkVideoResponse.response.items.compactMap { item -> MediaItem? in
                    if let playerUrl = item.player,
                       let date = item.date,
                       let bestImageUrl = item.image?.max(by: { ($0.width ?? 0) < ($1.width ?? 0) })?.url
                    {
                        return MediaItem(url: bestImageUrl, playerUrl: playerUrl, date: date, title: item.title, type: .video)
                    }
                    return nil
                }
                completion(.success(fetchedVideos))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func validateToken(accessToken: String, completion: @escaping (Result<VKUserResponse, Error>) -> Void) {
        let parameters: [String: Any] = [
            "access_token": accessToken,
            "v": "5.131",
        ]

        AF.request(Constants.validationTokenUrl, parameters: parameters).responseDecodable(of: VKUserResponse.self) { response in
            switch response.result {
            case let .success(vkUserResponse):
                completion(.success(vkUserResponse))
            case let .failure(afError):
                completion(.failure(afError))
            }
        }
    }

    func exchangeCodeForToken(code: String, completion: @escaping (Result<VKTokenResponse, Error>) -> Void) {
        let parameters: [String: Any] = [
            "client_id": Constants.appId,
            "client_secret": Constants.clientSecret,
            "redirect_uri": Constants.redirectUri,
            "code": code,
        ]

        AF.request(Constants.exchangeTokenUrl, parameters: parameters).responseDecodable(of: VKTokenResponse.self) { response in
            switch response.result {
            case let .success(vkUserResponse):
                completion(.success(vkUserResponse))
            case let .failure(afError):
                completion(.failure(afError))
            }
        }
    }
}

private extension VKNetworkManager {
    enum Constants {
        static let appId = "52123937"
        static let clientSecret = "DDabodopfkODj4KXksrd"
        static let redirectUri = "https://koshkar.github.io/mobileup-vk-ios/auth.html"
        static let exchangeTokenUrl = "https://oauth.vk.com/access_token"

        static let validationTokenUrl = "https://api.vk.com/method/users.get"

        static let groupId = "128666765"
        static let apiVersion = "5.131"
        static let fetchApiUrl = "https://api.vk.com/method/"
    }
}

struct VKUserResponse: Decodable {
    let response: [User]

    struct User: Decodable {
        let id: Int
        let firstName: String
        let lastName: String

        enum CodingKeys: String, CodingKey {
            case id
            case firstName = "first_name"
            case lastName = "last_name"
        }
    }
}
