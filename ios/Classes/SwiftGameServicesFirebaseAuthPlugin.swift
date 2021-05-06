import Flutter
import UIKit
import GameKit
import os
import FirebaseAuth


public class SwiftGameServicesFirebaseAuthPlugin: NSObject, FlutterPlugin {
    
    
    var viewController: UIViewController {
        return UIApplication.shared.windows.first!.rootViewController!
    }
    
    
    private func signInWithGameCenter(result: @escaping (Bool, FlutterError?) -> Void) {
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
    
    private func linkGameCenterCredentialsToCurrentUser(result: @escaping (Bool, FlutterError?) -> Void) {
        let player = GKLocalPlayer.local
        
        var user: User? = Auth.auth().currentUser
        
        if(user == nil) {
            result(false, FlutterError.init(code: "no_user_sign_in", message: "No User sign in to Firebase, impossible to link any credentials", details:nil))
            return
        }
        
        
        for provider in user!.providerData {
            
            if(provider.providerID == "gc.apple.com") {
                result(false, FlutterError.init(code: "user_already_link_to_game_center", message: "User already link to Game Csenter", details:nil))
                return
            }
            
        }
        
        
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
                    
                    user!.link(with: cred!) { (authResult, error) in
                        if let error = error {
                            result(false, FlutterError.init(code: "firebase_link_credentials_failed", message:"Failed to link credentials to Firebase User", details:error.localizedDescription))
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
        
        signInWithGameCenter () { cred, error in
            if let error = error {
                result(error)
            }
            result(true)
        }
        
    } else if(call.method == "linkGameServicesCredentialsToCurrentUser"){
        linkGameCenterCredentialsToCurrentUser () { cred, error in
            if let error = error {
                result(error)
            }
            result(true)
        }
    }else {
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
