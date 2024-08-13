import Foundation

struct VKTokenResponse: Decodable {
    let access_token: String
    let expires_in: Int
    let user_id: Int
}
