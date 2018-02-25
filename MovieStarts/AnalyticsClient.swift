import Foundation
import Firebase

// Client for a analytics package - now Firebase, maybe something else in the future

class AnalyticsClient
{
    static let userPropUseImdbApp                   = "Settings_UseImdbApp"
    static let userPropUseYouTubeApp                = "Settings_UseYouTubeApp"
    static let userPropUseNotifications             = "Settings_UseNotification"
    static let userPropNumberOfMoviesInWatchlist    = "NumMoviesInWatchlist"

    
    class func initialize()
    {
        #if RELEASE
            FirebaseConfiguration.shared.setLoggerLevel(.warning)
            FirebaseApp.configure()
        #endif
    }
    
    class func trackScreenName(_ name: String)
    {
        #if RELEASE
            Analytics.setScreenName(name, screenClass: nil)
        #endif
    }

    
    // MARK: - User Properties
    
    class func setPropertyUseImdbApp(to value: String?)
    {
        #if RELEASE
            Analytics.setUserProperty(value, forName: userPropUseImdbApp)
        #endif
    }

    class func setPropertyUseYouTubeApp(to value: String?)
    {
        #if RELEASE
            Analytics.setUserProperty(value, forName: userPropUseYouTubeApp)
        #endif
    }

    class func setPropertyUseNotifications(to value: String?)
    {
        #if RELEASE
            Analytics.setUserProperty(value, forName: userPropUseNotifications)
        #endif
    }
    
    class func setPropertyNumberOfMoviesInWatchlist(to value: Int)
    {
        #if RELEASE
            Analytics.setUserProperty(String(value), forName: userPropNumberOfMoviesInWatchlist)
        #endif
    }
    

    // MARK: - User Events

    class func logEventAddMovieToWatchlist(_ movieTitle: String?, withImdbId imdbId: String?)
    {
        #if RELEASE
            var imdbIdToLog = "?"
            var movieTitleToLog = "?"

            if let movieTitle = movieTitle  { movieTitleToLog = movieTitle }
            if let imdbId = imdbId  { imdbIdToLog = imdbId }

            Analytics.logEvent(AnalyticsEventAddToWishlist, parameters:
            [
                AnalyticsParameterItemID: imdbIdToLog as NSObject,
                AnalyticsParameterItemName: movieTitleToLog as NSObject,
            ])
        #endif
    }

}

