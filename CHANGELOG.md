## 2.0.0
* Overall cleanup of the plugin by @orkun1675
* BREAKING: Upgrade to Google Play Game Services v2. If you are using the `games_services` plugin please upgrade to `4.0.0` or higher.
* BREAKING: Introduce singleton pattern. Replace `GameServicesFirebaseAuth.` with `GameServicesFirebaseAuth.instance.` to migrate.
* BREAKING: `linkGameServicesCredentialsToCurrentUser()` param `forceSignInIfCredentialAlreadyUsed` renamed as `switchFirebaseUsersIfNeeded`.
* All methods upon error throw `GameServiceFirebaseAuthException` which has comes with a discrete ENUM error code.
* Adds timeout to platform calls as a counter measure against iOS hangs (e.g. https://stackoverflow.com/questions/18927723).

## 1.0.0
* Update Flutter package firebase_core to 2.5.0
* Update Flutter package firebase_auth to 4.7.2
* Update Flutter SDK in pubspec to `">=3.1.0 <4.0.0"`
* Update the doc
* Fix example build
* Transfert the package from jgrandchavin to Revolt Games

## 0.3.0
* Update Flutter package firebase_core to 1.20.0
* Update Flutter package firebase_auth to 3.6.2

## 0.2.0
* Update Flutter package firebase_core to 1.18.0
* Update Flutter package firebase_auth to 3.3.20
* Update  firebase_core_platform_interface: 4.4.1 
* Fix `finishPendingOperationWithSuccess`  `Fatal Exception: java.lang.NullPointerException` crash on Android
## 0.1.1
* Update Firebase iOS SDK to 8.3.0
* Update Flutter package firebase_core to 1.4.0
* Update Flutter package firebase_auth to 3.0.1


## 0.1.0
* Improve exception thrown by the packages

## 0.0.9
* Fix user_already_link_to_game_center iOS error

## 0.0.8
* Add silent sign in on iOS

## 0.0.7
* Catch ApiException on Android

## 0.0.6
* Add forceSignInIfCredentialAlreadyUsed options to linkGameServicesCredentialsToCurrentUser()

## 0.0.5
* Get ERROR_CREDENTIAL_ALREADY_IN_USE for linkGameServicesCredentialsToCurrentUser()

## 0.0.4
* Upgrade firebase_core to 1.1.1 and firebase_auth to 1.1.4

## 0.0.3
* Add clientId option on Android

## 0.0.2
* Update licence

## 0.0.1
* Base Firebase Auth functionality for iOS et Android
