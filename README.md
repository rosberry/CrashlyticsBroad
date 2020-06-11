# Firebase broad

[Butterbroad](https://github.com/rosberry/butterbroad/) aggreator for [FirebaseAnalytics](https://firebase.google.com/docs/analytics)

## Features

- Compatible with Butterbroad
- Easy getting started

## Requirements

- iOS 9.0+
- Xcode 8.0+

## Installation

In the project navigator select a target, navigate to `Build Settings` and set `Enable Bitcode` to `No`

Add  build phase with name `Crashlytics` with following content
`"$PROJECT_DIR/Carthage/Build/iOS/FirebaseBroad.framework/run"`
and pass DSYM and info.plist as input files of the scrypt
```
${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${TARGET_NAME}
$(SRCROOT)/$(BUILT_PRODUCTS_DIR)/$(INFOPLIST_PATH)
```

#### Carthage
Create a `Cartfile` that lists the framework and run `carthage update`. Follow the [instructions](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) to add the framework to your project.

```
github "rosberry/ButterBroad"
github "rosberry/CrashlyticsBroad"
```
Add following frameworks from Carhage/Build/iOS folder:
- AnyCodable.framework
- Butterbroad.framework
- FirebaseBroad.framework
- FirebaseAnalytics.framework

### Manually

Drag `Sources` folder from [last release](https://github.com/rosberry/FirebaseBroad/releases) into your project.

## Usage

In the AppDelegate

```swift
import Firebase


func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: LaunchOptions?) -> Bool {
    ...
    FirebaseApp.configure()
    Butter.activationHandler?()
    ...
}
```

#### Creating a broad

```swift
import ButterBroad
import FirebaseBroad

extension Butter {
static let firebase: FirebaseBroad = .init(Firebase.Analytics.self)
    static let common: Butter = .init(broads: firebase)
}
```

#### logging

```swift
 Butter.common.logEvent(with: <SOME EVENT HERE>, params: <ADDITIONAL PARAMETERS HERE>)
```

## Authors

* Nikolay Tyunin, nikolay.tyunin@rosberry.com

## About

<img src="https://github.com/rosberry/Foundation/blob/master/Assets/full_logo.png?raw=true" height="100" />

This project is owned and maintained by [Rosberry](http://rosberry.com). We build mobile apps for users worldwide 🌏.

Check out our [open source projects](https://github.com/rosberry), read [our blog](https://medium.com/@Rosberry) or give us a high-five on 🐦 [@rosberryapps](http://twitter.com/RosberryApps).

## License

Product Name is available under the MIT license. See the LICENSE file for more info.
