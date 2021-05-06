#import "GameServicesFirebaseAuthPlugin.h"
#if __has_include(<game_services_firebase_auth/game_services_firebase_auth-Swift.h>)
#import <game_services_firebase_auth/game_services_firebase_auth-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "game_services_firebase_auth-Swift.h"
#endif

@implementation GameServicesFirebaseAuthPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftGameServicesFirebaseAuthPlugin registerWithRegistrar:registrar];
}
@end
