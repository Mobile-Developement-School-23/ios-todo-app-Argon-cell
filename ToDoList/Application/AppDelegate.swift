import UIKit
import CocoaLumberjackSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // MARK: - Networking setup
        
        let urlSession = URLSession(configuration: .default)
        
        let networkClient = NetworkClientImp(urlSession: urlSession)
        let networkService = NetworkServiceImp(networkClient: networkClient, token: nil)
        
        let fileCacheService = FileCacheImp(storageType: .json)
        
        let dataManagerService = DataManagerImp(storage: fileCacheService, network: networkService)
        
        // MARK: - Logger
        
        DDLog.add(DDOSLogger.sharedInstance)

        let fileLogger: DDFileLogger = DDFileLogger()
        fileLogger.rollingFrequency = 60 * 60 * 24
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7

        DDLog.add(fileLogger)
        
        // MARK: - Window setup
        
        window = UIWindow(frame: UIScreen.main.bounds)

        var vc: UIViewController?
        if let token = UserDefaults.standard.string(forKey: "auth_token") {
            dataManagerService.updateNetworkToken(token)
            let lastKnownRevision = UserDefaults.standard.integer(forKey: "last_known_revision")
            dataManagerService.updateRevision(lastKnownRevision)
            vc = TodoListViewController(dataManagerService: dataManagerService)
        } else {
            vc = AuthorizationViewController(dataManager: dataManagerService)
        }
        let navController = UINavigationController(rootViewController: vc!)
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        
        return true
    }
}
