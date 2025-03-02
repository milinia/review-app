/// Модель отзыва.
struct Review: Decodable {
    
    /// Имя автора  отзыва.
    let firstName: String
    /// Фамилия автора отзыва.
    let lastName: String
    /// Аватар автора отзыва.
    let avatarUrl: String
    /// Текст отзыва.
    let text: String
    /// Время создания отзыва.
    let created: String
    /// Рейтинг отзыва.
    let rating: Int
    /// Фотографии  отзыва.
    let photoUrls: [String]

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case avatarUrl = "avatar_url"
        case photoUrls = "photo_urls"
        case text, created, rating
    }
}
