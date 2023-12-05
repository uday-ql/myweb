import UIKit
import flutter_sharing_intent
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      GeneratedPluginRegistrant.register(with: self)
      let userDefaults = UserDefaults(suiteName: "group.com.techind.flutterSharingIntentExample")
      print(userDefaults?.object(forKey: "SharingKey"))
//      UserDefaults.standard.set("Uday Died", forKey: "SharingKey")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
   
 override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

     let sharingIntent = SwiftFlutterSharingIntentPlugin.instance
     /// if the url is made from SwiftFlutterSharingIntentPlugin then handle it with plugin [SwiftFlutterSharingIntentPlugin]
     if sharingIntent.hasSameSchemePrefix(url: url) {
         return sharingIntent.application(app, open: url, options: options)
     }

     // Proceed url handling for other Flutter libraries like uni_links
     return super.application(app, open: url, options:options)
   }
}
