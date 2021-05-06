import Flutter
import UIKit
import GameKit
import os
import FirebaseAuth


public class SwiftGameServicesFirebaseAuthPlugin: NSObject, FlutterPlugin {
    
    
    var viewController: UIViewController {
        return UIApplication.shared.windows.first!.rootViewController!
    }
    
    
    private func authenticatePlayer(result: @escaping (Bool, FlutterError?) -> Void) {
        let player = GKLocalPlayer.local
        
        player.authenticateHandler = { vc, error in
            
            if let vc = vc {
                self.viewController.present(vc, animated: true, completion: nil)
            } else if player.isAuthenticated {
                
                GameCenterAuthProvider.getCredential { cred, error in
                    if let error = error {
                        result(false, FlutterError.init(code: "get_gamecenter_credentials_failed", message: "Failed to get GameCenter credentials", details:error.localizedDescription))
                        return
                    }
                    
                    if(cred == nil) {
                        result(false, FlutterError.init(code: "gamecenter_credentials_null", message: "Failed to get GameCenter credentials", details: "Credential are null"))
                        return
                    }
                    
                    
                    
                    Auth.auth().signIn(with:cred!) { (user, error) in
                        
                        if let error = error {
                            result(false, FlutterError.init(code: "firebase_signin_failed", message:"Failed to get sign in to Firebase", details:error.localizedDescription))
                            return
                        }
                        
                        result(true, nil);
                        return
                    }
                    
                    
                    
                }
            } else {
                result(false, FlutterError.init(code: "no_player_detected", message: "No player detected on this phone", details:nil))
                return
            }
        }
    }
    
    
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print(call.method)
        
        if(call.method == "signInWithGameService") {
            
            
            authenticatePlayer () { cred, error in
                
                if let error = error {
                    result(error)
                }
                
                result(true)
            }
            
        } else {
            self.log(message: "Unknown method called")
        }
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "game_services_firebase_auth", binaryMessenger: registrar.messenger())
        let instance = SwiftGameServicesFirebaseAuthPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    private func log(message: StaticString) {
        if #available(iOS 10.0, *) {
            os_log(message)
        }
    }
}
