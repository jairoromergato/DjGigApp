import SwiftUI

enum SocialPlatform: String, CaseIterable, Identifiable {
    case instagram
    case tiktok
    case soundcloud
    case youtube
    case beatport
    case appleMusic
    case spotify
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .instagram: return "Instagram"
        case .tiktok: return "TikTok"
        case .soundcloud: return "SoundCloud"
        case .youtube: return "Youtube"
        case .beatport: return "Beatport"
        case .appleMusic: return "Apple Music"
        case .spotify: return "Spotify"
        }
    }
    
    var buttonColor: Color {
        switch self {
        case .instagram:
            return Color(red: 193/255, green: 53/255, blue: 132/255)
        case .tiktok:
            return Color(red: 0, green: 0, blue: 0)
        case .soundcloud:
            return Color.orange
        case .youtube:
            return Color(red: 255/255, green: 0/255, blue: 0/255)
        case .beatport:
            return Color(red: 0/255, green: 255/255, blue: 175/255)
        case .appleMusic:
            return Color(red: 255/255, green: 45/255, blue: 85/255)
        case .spotify:
            return Color(red: 30/255, green: 215/255, blue: 96/255)
            
        }
    }
    
    var iconName: String {
        switch self {
        case .instagram: return "instagramLogo"
        case .tiktok:    return "tiktokLogo"
        case .soundcloud:return "soundcloudLogo"
        case .youtube: return "youtubeLogo"
        case .beatport: return "beatportLogo"
        case .appleMusic: return "appleMusicLogo"
        case .spotify: return "spotifyLogo"
        }
    }
    
    var appScheme: String? {
        switch self {
        case .instagram: return "instagram://app"
        case .tiktok:    return "tiktok://discover"
        case .soundcloud:return "soundcloud://"
        case .youtube: return "youtube://"
        case .beatport: return "beatport://"
        case .appleMusic: return "com.apple.music://"
        case .spotify: return "spotify://"
        }
    }
    
    var webURL: String {
        switch self {
        case .instagram: return "https://instagram.com"
        case .tiktok:    return "https://tiktok.com"
        case .soundcloud:return "https://soundcloud.com"
        case .youtube: return "https://youtube.com"
        case .beatport: return "https://www.beatport.com"
        case .appleMusic: return "https://music.apple.com/"
        case .spotify: return "https://open.spotify.com/"
        }
    }
    func open() {
        if let scheme = appScheme,
           let schemeURL = URL(string: scheme),
           UIApplication.shared.canOpenURL(schemeURL) {
            UIApplication.shared.open(schemeURL)
            return
        }
        
        if let url = URL(string: webURL) {
            UIApplication.shared.open(url)
        }
    }
        var textColor: Color {
        switch self {
        case .beatport: .black
        default: .white
        }
    }
}
