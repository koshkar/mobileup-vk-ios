import Foundation

struct VKTokenResponse: Decodable {
    let access_token: String
    let expires_in: Int
    let user_id: Int
}

struct VKErrorResponse: Decodable {
    let error: VKError
}

struct VKError: Decodable {
    let error_code: Int
    let error_msg: String
}
