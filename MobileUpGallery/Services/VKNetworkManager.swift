import Foundation
import Alamofire

class VKNetworkManager {
    static let shared = VKNetworkManager()

    private init() {}

    func validateToken(accessToken: String, completion: @escaping (Result<VKUserResponse, Error>) -> Void) {
        let parameters: [String: Any] = [
            "access_token": accessToken,
            "v": "5.131"
        ]

        AF.request(Constants.validationTokenUrl, parameters: parameters).responseDecodable(of: VKUserResponse.self) { response in
            switch response.result {
            case .success(let vkUserResponse):
                completion(.success(vkUserResponse))
            case .failure(let afError):
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
            case .success(let vkUserResponse):
                completion(.success(vkUserResponse))
            case .failure(let afError):
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
