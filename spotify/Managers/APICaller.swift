//
//  APICaller.swift
//  spotify
//
//  Created by Айдар Нуркин on 10.07.2023.
//

import Foundation

final class AuthManager {
    static let shared = AuthManager()
    
    private init() {}
    
    var isSignedIn:Bool {
        return false
    }
    private var accessToken: String? {
        return nil
    }
    private var refreshToken: String? {
        return nil
    }
    private var tokenExpirationDate: Date? {
        return nil
    }
    private var shouldBeFreshToken: Bool {
        return false
    }
}
