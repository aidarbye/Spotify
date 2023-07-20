import Foundation

final class APICaller {
    
    static let shared = APICaller()
    
    private init() {}
    
    struct Constants {
        static let baseAPIURL = "https://api.spotify.com/v1"
    }
    
    enum APIError: Error {
        case failedToGetData
    }
    
    enum HTTPMethod:String {
        case GET
        case POST
        case DELETE
        case PUT
    }
    //MARK: Albums
    public func getAlbumDetails(for album: Album,completion: @escaping (Result<AlbumDetailsResponse,Error>)->Void) {
        createRequest(with: URL(string: Constants.baseAPIURL+"/albums/\(album.id)"),
                      type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(AlbumDetailsResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(APIError.failedToGetData))
                }
            }
            task.resume()
        }
    }
    //MARK: Playlists
    public func getPlaylistDetails(for playlist: Playlist,completion: @escaping (Result<PlaylistDetailsResponse,Error>)->Void) {
        createRequest(with: URL(string: Constants.baseAPIURL+"/playlists/\(playlist.id!)"),
                      type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(PlaylistDetailsResponse.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(APIError.failedToGetData))
                }
            }
            task.resume()
        }
    }
    
    public func getCurrentUserPlaylist(completion: @escaping (Result<[Playlist],Error>)->Void) {
        createRequest(with: URL(string: Constants.baseAPIURL+"/me/playlists"),
                      type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(LibraryPlaylistResponse.self, from: data)
                    completion(.success(result.items))
                } catch {
                    completion(.failure(APIError.failedToGetData))
                }
            }
            task.resume()
        }
    }
    
    public func createPlaylist(with name: String,completion: @escaping (Bool)->Void) {
        getCurrentUserProfile { [weak self] result in
            switch result {
            case .success(let user):
                self?.createRequest(
                    with: URL(string: Constants.baseAPIURL+"/users/\(user.id)/playlists"),
                    type: .POST)
                { baseRequest in
                    var request = baseRequest
                    let json = [
                        "name": name
                    ]
                    request.httpBody = try? JSONSerialization.data(withJSONObject: json,options: .fragmentsAllowed)
                    let task = URLSession.shared.dataTask(with: request) { data, _, error in
                        guard let data = data, error == nil else {
                            completion(false)
                            return
                        }
                        do {
                            let result = try JSONDecoder().decode(Playlist.self, from: data)
                            if result.id != nil {
                                completion(true)
                            } else {
                                completion(false)
                            }
                        } catch {
                            completion(false)
                        }
                    }
                    task.resume()
                }
            case .failure(let error):
                print(error.localizedDescription)
                completion(false)
            }
        }
    }
    
    public func addTrackToPlaylist(track: Track,playlist: Playlist, completion: @escaping (Bool)->Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/playlists/\(playlist.id!)/tracks"), type: .POST) { baserequest in
            var request = baserequest
            let json = [
                "uris": ["spotify:track:\(track.id)"]
            ]
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: json,options: .fragmentsAllowed)
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(false)
                    return
                }
                do {
                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    if let response = result as? [String: Any], response["snapshot_id"] as? String != nil {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
                catch {
                    completion(false)
                    print(error.localizedDescription)
                }
            }
            task.resume()
        }
    }
    
    public func getCurrentUserAlbums(completion: @escaping (Result<[album],Error>)->Void) {
        createRequest(with: URL(string: Constants.baseAPIURL+"/me/albums"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(SavedAlbumsResponse.self, from: data)
                    completion(.success(result.items))
                }
                catch {
                    completion(.failure(APIError.failedToGetData))
                }
            }
            task.resume()
        }
    }
    
    public func saveAlbum(album: Album, completion: @escaping (Bool)->Void) {
        createRequest(with: URL(string: Constants.baseAPIURL+"/me/albums"), type: .PUT) { baserequest in
            var request = baserequest
            let json = [
                "ids": [
                    album.id
                ]
            ]
            request.httpBody = try? JSONSerialization.data(withJSONObject: json,options: .fragmentsAllowed)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let _ = data, error == nil,
                      let code = (response as? HTTPURLResponse)?.statusCode
                else {
                    completion(false)
                    return
                }
                completion(code == 200)
            }
            task.resume()
        }
    }
    
    public func removeTrackFromPlaylist(track: Track,playlist: Playlist, completion: @escaping (Bool)->Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/playlists/\(playlist.id!)/tracks"), type: .DELETE) { baserequest in
            var request = baserequest
            let json = [
                "tracks": [
                    [
                        "uri" : "spotify:track:\(track.id)"
                    ]
                ]
            ]
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: json,options: .fragmentsAllowed)
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(false)
                    return
                }
                do {
                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    if let response = result as? [String: Any], response["snapshot_id"] as? String != nil {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
                catch {
                    completion(false)
                    print(error.localizedDescription)
                }
            }
            task.resume()
        }

    }
    //MARK: Profile
    public func getCurrentUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/me"), type: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(UserProfile.self, from: data)
                    completion(.success(result))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    //MARK: Browse
    public func getNewReleases(completion: @escaping (Result<NewReleasesResponse,Error>)->Void) {
        createRequest(
            with: URL(string:Constants.baseAPIURL + "/browse/new-releases"),
            type: .GET
        ) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(NewReleasesResponse.self, from: data)
                    completion(.success(result))
                    
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getFeaturedPlaylists(completion: @escaping (Result<FeaturedPlaylistResponse,Error>) -> Void ) {
        createRequest(
            with: URL(string:Constants.baseAPIURL + "/browse/featured-playlists?limit=20"),
            type: .GET
        ) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(FeaturedPlaylistResponse.self, from: data)
                    completion(.success(result))
                    
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getRecommendationsTracks(seed_genres: Set<String>, completion: @escaping (Result<RecommendationsTracksResponse,Error>)->Void) {
        let seeds = seed_genres.joined(separator: ",")
        createRequest(
            with: URL(string:Constants.baseAPIURL + "/recommendations?limit=40&seed_genres=\(seeds)"),
            type: .GET
        ) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(RecommendationsTracksResponse.self, from: data)
                    completion(.success(result))

                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getRecommendationGenres(completion: @escaping (Result<RecommendedGenresResponse,Error>) -> Void ) {
        createRequest(
            with: URL(string:Constants.baseAPIURL + "/recommendations/available-genre-seeds"),
            type: .GET
        ) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(RecommendedGenresResponse.self, from: data)
                    completion(.success(result))
                    
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getCategories(completion: @escaping (Result<[Category],Error>) -> Void ) {
        createRequest(
            with: URL(string:Constants.baseAPIURL + "/browse/categories?limit=50"),
            type: .GET
        ) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(AllCategoriesResponse.self, from: data)
                    completion(.success(result.categories.items))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getCategoriePlaylists(with category: Category, completion: @escaping (Result<[Playlist],Error>) -> Void ) {
        createRequest(
            with: URL(string:Constants.baseAPIURL + "/browse/categories/\(category.id)/playlists?limit=50"),
            type: .GET
        ) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(CategoryPlaylistResponse.self, from: data)
                    let playlists = result.playlists.items
                    completion(.success(playlists))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func search(with query: String,completion: @escaping (Result<[SearchResult],Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL+"/search?limit=5&type=album,artist,playlist,track&q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do {
                    let result = try JSONDecoder().decode(SearchResultResponse.self, from: data)
                    var searchResults = [SearchResult]()
                    searchResults.append(contentsOf: result.tracks.items.compactMap { SearchResult.track(model: $0) })
                    searchResults.append(contentsOf: result.albums.items.compactMap { SearchResult.album(model: $0) })
                    searchResults.append(contentsOf: result.artists.items.compactMap { SearchResult.artist(model: $0) })
                    searchResults.append(contentsOf: result.playlists.items.compactMap { SearchResult.playlist(model: $0) })
                    completion(.success(searchResults))
                } catch {
                    completion(.failure(APIError.failedToGetData))
                }
            }
            task.resume()
        }
    }
    
    private func createRequest(
        with url: URL?,
        type: HTTPMethod,
        completion: @escaping(URLRequest)->Void)
    {
        AuthManager.shared.withValidToken { token in
            guard let url = url else {
                return
            }
            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30
            completion(request)
        }
    }
}
