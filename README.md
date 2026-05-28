# Flavourist

Flavourist is a custom Dart utility that generates native app flavours for our mobile apps. Based off of [Angelo Cassano's](https://angelocassano.it/) [flutter_flavorizr](https://github.com/AngeloAvv/flutter_flavorizr). 

## Why fork?

Upstream didn't have an easy way to configure/customise the output directory of the generated ``main_flavor.dart`` files. For our purposes, we wanted to have ``main.dart`` in the root directory of our app, and all other flavour runpoints under ``lib/config/[flavour_name]/``. 

Upstream also hard-rewrites the ``main.dart`` file, a behaviour which wasn't ideal for us, as we had custom logic there.

## Changes from Original

Flavourist is a streamlined fork of [flutter_flavorizr](https://github.com/AngeloAvv/flutter_flavorizr)

- Flavours are now defined in a more neutral, root-level ``flavors.yaml`` file.
- VS Code / Cursor launch profiles and build tasks in ``.vscode/`` and ``.cursor/`` (release, debug, beta, profile per flavor).
- Default platforms are now defined in a root-level ``platforms`` key in ``flavors.yaml``.
- ``flavors.yaml`` is now streamlined, with each platform implied from the platform array above.
- **Icon overlays** and per-build-variant icons (**debug**, **beta**, **profile**) with separate Android source sets and Darwin asset catalogs.
- **Display names** — build-type suffix at the end for non-release builds (e.g. ``UESPWiki (Debug)``); release keeps the base ``name:`` only.
- **``Target.beta``** — ``Beta-{flavor}`` Xcode build configurations and ``{flavor}Beta.xcconfig`` (separate from Profile; not repurposed for beta builds).
- Patched ``add_build_configuration.rb`` after assets extract so Beta configurations clone from Release.

## Icon configuration (`flavors.yaml`)

Per-flavor ``icon:`` block (consumer apps such as wiki_app):

```yaml
myflavor:
    name: My App
    applicationID: com.example.myflavor

    icon:
        foreground: assets/flavors/myflavor/icons/foreground.png   # Android adaptive layer
        background: assets/flavors/myflavor/icons/background.png
        monochrome: assets/flavors/myflavor/icons/monochrome.png   # optional, Android 13+
        overlay: assets/flavors/common/overlays/badge.png            # optional PNG, 1024×1024

    debug:
        icon:
            overlay: assets/flavors/common/overlays/debug.png

    beta:
        icon:
            overlay: assets/flavors/common/overlays/beta.png

    profile:
        icon:
            overlay: assets/flavors/common/overlays/profile.png
            # or full replacement: foreground / background / monochrome
```

### Base icon fields

| Field | Role |
|-------|------|
| ``foreground`` | Android adaptive foreground; composed with ``background`` for flat launcher PNGs |
| ``background`` | Android adaptive background |
| ``monochrome`` | Optional Android 13+ monochrome layer |
| ``overlay`` | Optional PNG composited on top of composed flat icons and adaptive foreground (authored at launcher size, transparency OK) |

Legacy ``icon: path/to.png`` (string) is still supported (treated as ``foreground`` only).

Optional ``ios.icon`` / ``macos.icon`` flat PNG paths override the composed Darwin launcher master.

### Build variant blocks

Optional ``debug:``, ``beta:``, and ``profile:`` blocks each contain a nested ``icon:`` map. Fields merge **onto the base** ``icon:`` (non-null override fields replace the same field on the base icon).

If a variant block is omitted, that variant’s dedicated assets are **not** generated; the platform uses release icons for that mode where applicable.

| Variant | Android source set | Darwin asset catalog | Xcode configuration | Flutter CLI |
|---------|-------------------|----------------------|---------------------|-------------|
| release (base) | ``src/{flavor}/`` | ``{flavor}AppIcon`` | ``Release-{flavor}`` | ``flutter … --release`` |
| debug | ``src/{flavor}Debug/`` | ``{flavor}DebugAppIcon`` | ``Debug-{flavor}`` | ``flutter … --debug`` |
| profile | ``src/{flavor}Profile/`` | ``{flavor}ProfileAppIcon`` | ``Profile-{flavor}`` | ``flutter … --profile`` |
| beta | ``src/{flavor}Beta/`` | ``{flavor}BetaAppIcon`` | ``Beta-{flavor}`` | See [Beta builds](#beta-builds) |

When a variant ``icon:`` block is present, ``ASSET_PREFIX`` in the matching xcconfig is set to ``{flavor}Debug``, ``{flavor}Profile``, or ``{flavor}Beta`` as appropriate. Release keeps ``{flavor}``.

**Profile is not beta.** Store / production builds must use ``--release`` → ``Release-{flavor}`` only.

### Platform behaviour

- **Android:** raw ``foreground`` / ``background`` in ``drawable-*`` per source set; legacy ``mipmap`` icons use a **composed** flat PNG when both layers exist; ``overlay`` is applied during composition.
- **iOS / macOS:** ``AppIcon.appiconset`` per variant prefix from composed fg+bg (+ overlay when set). Background fills the canvas; foreground is centered at source size (not scaled).
- **IDs:** flavor ``applicationID`` mirrors to Android and default Darwin bundle IDs; use ``ios.applicationID`` / ``macos.applicationID`` (not ``bundleId``) to override per platform.
- **Platforms:** icons generate only for platforms listed on the flavor (``platforms: [ android, ios, macos ]``).

### Display names (home screen & IDE)

The flavor **`name:`** field is the **base** display name (e.g. ``UESPWiki``). Flavourist appends the **build type at the end** for every non-release configuration:

| Build type | Example display name |
|------------|----------------------|
| release | ``UESPWiki`` |
| debug | ``UESPWiki (Debug)`` |
| profile | ``UESPWiki (Profile)`` |
| beta | ``UESPWiki (Beta)`` |

Use **``(Debug)``**, not ``(Dev)``. Do not hand-edit per-variant ``name:`` under ``debug:`` / ``beta:`` / ``profile:`` for labels — those blocks are for **`icon:`** only; labels are generated in ``lib/src/utils/flavor_display_name.dart``.

| Platform | Where it is written |
|----------|---------------------|
| **Android** | ``android:buildGradle`` → ``flavorDisplayNames`` block: ``applicationVariants.configureEach`` sets ``app_name`` ``resValue`` from build type |
| **iOS** | ``ios:xcconfig`` → ``BUNDLE_NAME`` / ``BUNDLE_DISPLAY_NAME`` per ``{flavor}{Debug|Profile|Beta|Release}.xcconfig`` |
| **macOS** | ``macos:configs`` → same bundle keys in ``macos/Runner/Configs/`` |
| **VS Code / Cursor** | ``ide:config`` → ``.vscode/launch.json`` (and ``.cursor/launch.json`` when generated) launch ``name`` |

### VS Code launch configurations

``ide:config`` generates four launch entries per flavor, in this order: **release → debug → beta → profile**. The same order is used for the **Build (Interactive)** task ``buildMode`` picker (``scripts/build.sh`` flags).

| Launch name suffix | ``flutterMode`` | ``BUILD_TYPE`` |
|--------------------|-----------------|----------------|
| (none — base ``name:`` only) | ``release`` | ``release`` |
| `` (Beta)`` | ``release`` | ``beta`` |
| `` (Debug)`` | ``debug`` | ``debug`` |
| `` (Profile)`` | ``profile`` | ``profile`` |

Beta launches use ``flutterMode: release`` for Dart; the **home-screen icon** on iOS still requires a ``Beta-{flavor}`` native build (see below).

### Beta builds

Flutter has no ``--beta`` CLI mode. Beta launcher assets use ``Beta-{flavor}`` in Xcode and ``src/{flavor}Beta/`` on Android.

Consumer apps (e.g. wiki_app) typically wire beta through ``scripts/build.sh --beta``:

- **Android:** ``flutter build apk --config-only`` then ``./gradlew assemble{Flavor}Beta`` (requires a ``beta`` buildType in ``build.gradle``).
- **iOS / macOS:** ``flutter build … --config-only`` then ``xcodebuild -configuration Beta-{flavor}``.

``pod install`` may be needed after flavourist updates the Podfile with ``Beta-*`` mappings.

### Running icon generation

```bash
dart run flavourist
```

Icons are included in the default instruction set. Icons only:

```bash
dart run flavourist -p android:icons,ios:icons,macos:icons
```

See also [``.cursor/rules/flavourist-icons.mdc``](.cursor/rules/flavourist-icons.mdc) for agent-oriented reference.

# Original ReadMe
A flutter utility to easily create flavors in your flutter application

[![Pub](https://img.shields.io/pub/v/flutter_flavorizr.svg)](https://pub.dev/packages/flutter_flavorizr)
![Dart CI](https://github.com/AngeloAvv/flutter_flavorizr/workflows/Dart%20CI/badge.svg)
[![Star on GitHub](https://img.shields.io/github/stars/AngeloAvv/flutter_flavorizr.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/AngeloAvv/flutter_flavorizr)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)
[![](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/AngeloAvv)

If you want to support this project, please leave a star, share this project, or consider donating through [Github Sponsor](https://github.com/sponsors/AngeloAvv).

## Getting Started

Let's start by setting up our environment in order to run Flutter
Flavorizr

### Prerequisites

Side note: this tool works better on a new and clean Flutter project.
Since some processors reference some existing files and a specific base
structure, it could be possible that running Flutter Flavorizr over an
existing project could throw errors.

Before running Flutter Flavorizr, you must install the following
software:

* [Ruby](https://www.ruby-lang.org/en/documentation/installation/)
* [Gem](https://rubygems.org/pages/download)
* [Xcodeproj](https://github.com/CocoaPods/Xcodeproj) (through RubyGems)

These prerequisites are needed to manipulate the iOS and macOS projects and
schemes. If you are interested in flavorizing Android only, you can skip
this step.

If your app uses a Flutter plugin and you plan to create flavors for iOS and macOS, you need to make
sure there's an existing Podfile file under the ios/macos folder. This might lead to problems like
["Unable to load contents of file list"](doc%2Ftroubleshooting%2Funable-to-load-contents-of-file-list%2FREADME.md).

### Installation

This package is intended to support development of Flutter projects. In
general, put it under
[dev_dependencies](https://dart.dev/tools/pub/dependencies#dev-dependencies),
in your [pubspec.yaml](https://dart.dev/tools/pub/pubspec):

```yaml
dev_dependencies:
  flutter_flavorizr: ^2.2.3
```

You can install packages from the command line:

```terminal
pub get
```

## Create your flavors

Once all of the prerequisites have been installed and you have added
flutter_flavorizr as a dev dependency, you have to edit your
[pubspec.yaml](https://dart.dev/tools/pub/pubspec) and define the
flavors.

### Example

Create a new file named flavours.yaml and define the name of the
flavors, in our example *apple* and *banana*. For each flavor you have
to specify the *app name*, the *applicationId* and the *bundleId*.

```yaml
flavors:
  apple:
    app:
      name: "Apple App"

    android:
      applicationId: "com.example.apple"  
    ios:
      bundleId: "com.example.apple"
    macos:
      bundleId: "com.example.apple"  
  banana:
    app:
      name: "Banana App"
  
    android:
      applicationId: "com.example.banana"
    ios:
      bundleId: "com.example.banana"
    macos:
      bundleId: "com.example.banana"
```

Alternatively, add a new key named flavorizr and define a sub item named *flavors*. 
Under the flavors array you can define the name of the
flavors, in our example *apple* and *banana*. For each flavor you have
to specify the *app name*, the *applicationId* and the *bundleId*.
This way of defining flavors will be deprecated in versions 3.x

```yaml
flavorizr:
  flavors:
    apple:
      app:
        name: "Apple App"

      android:
        applicationId: "com.example.apple"
      ios:
        bundleId: "com.example.apple"
      macos:
        bundleId: "com.example.apple"        
    banana:
      app:
        name: "Banana App"

      android:
        applicationId: "com.example.banana"
      ios:
        bundleId: "com.example.banana"
      macos:
        bundleId: "com.example.banana"
```

### Available fields

#### flavorizr

| key                                     | type   | default                                                                             | required | description                                                                                   |
|:----------------------------------------|:-------|:------------------------------------------------------------------------------------|:---------|:----------------------------------------------------------------------------------------------|
| app                                     | Object |                                                                                     | false    | An object describing the general capabilities of an app                                       |
| flavors                                 | Array  |                                                                                     | true     | An array of items. Each of them describes a flavor configuration                              |
| [instructions](#available-instructions) | Array  |                                                                                     | false    | An array of instructions to customize the flavorizr process                                   |
| assetsUrl                               | String | [link](https://github.com/AngeloAvv/flutter_flavorizr/releases/download/v2.2.3/assets.zip) | false    | A string containing the URL of the zip assets file. The default points to the current release |
| ide                                     | String |                                                                                     | false    | The IDE in which the app is being developed. Currently only `vscode` or `idea`                |

##### <a href="#available-instructions">Available instructions</a>

| value                   | category      | description                                                             |
|:------------------------|:--------------|:------------------------------------------------------------------------|
| assets:download         | Miscellaneous | Downloads the assets zip from the network                               |
| assets:extract          | Miscellaneous | Extracts the downloaded zip in the project .tmp directory               |
| assets:clean            | Miscellaneous | Removes the assets from the project directory                           |
| android:buildGradle     | Android       | Adds the flavors to the Android build.gradle file                       |
| android:androidManifest | Android       | Changes the reference of the app name in the AndroidManifest.xml        |
| android:dummyAssets     | Android       | Generates some default icons for your custom flavors                    |
| android:icons           | Android       | Creates a set of icons for each flavor according to the icon
| flutter:targets         | Flutter       | Creates a set of targets for each flavor instance                       |
| google:firebase         | Google        | Adds Google Firebase configurations for Android and iOS for each flavor |
| huawei:agconnect        | Huawei        | Adds Huawei AGConnect configurations for Android for each flavor        |
| ide:config              | IDE           | Generates debugging configurations for each flavor of your IDE          |
| ios:podfile             | iOS           | Updates the Pods-Runner path for each flavor                            |
| ios:xcconfig            | iOS           | Creates a set of xcconfig files for each flavor and build configuration |
| ios:buildTargets        | iOS           | Creates a set of build targets for each flavor and build configuration  |
| ios:schema              | iOS           | Creates a set of schemas for each flavor                                |
| ios:dummyAssets         | iOS           | Generates some default icons for your custom flavors                    |
| ios:icons               | iOS           | Creates a set of icons for each flavor according to the icon directive  |
| ios:plist               | iOS           | Updates the info.plist file                                             |
| ios:launchScreen        | iOS           | Creates a set of launchscreens for each flavor                          |
| macos:podfile           | macOS         | Updates the Pods-Runner path for each flavor                            |
| macos:xcconfig          | macOS         | Creates a set of xcconfig files for each flavor and build configuration |
| macos:configs           | macOS         | Creates a set of xcconfig files for each flavor and build configuration |
| macos:buildTargets      | macOS         | Creates a set of build targets for each flavor and build configuration  |
| macos:schema            | macOS         | Creates a set of schemas for each flavor                                |
| macos:dummyAssets       | macOS         | Generates some default icons for your custom flavors                    |
| macos:icons             | macOS         | Creates a set of icons for each flavor according to the icon directive  |
| macos:plist             | macOS         | Updates the info.plist file                                             |

#### android (under app)

| key              | type   | default       | required | description                                                        |
|:-----------------|:-------|:--------------|:---------|:-------------------------------------------------------------------|
| flavorDimensions | String | "flavor-type" | false    | The value of the flavorDimensions in the android build.gradle file |
| resValues        | Array  | {}            | false    | An array which contains a set of resValues configurations          |
| buildConfigFields| Array  | {}            | false    | An array which contains a set of buildConfigFields configurations          |

#### ios (under app)

| key           | type       | default | required | description                                                                                    |
|:--------------|:-----------|:--------|:---------|:-----------------------------------------------------------------------------------------------|
| buildSettings | Dictionary | {}      | false    | An XCode build configuration dictionary [XCode Build Settings](https://xcodebuildsettings.com) |

#### macos (under app)

| key           | type       | default | required | description                                                                                    |
|:--------------|:-----------|:--------|:---------|:-----------------------------------------------------------------------------------------------|
| buildSettings | Dictionary | {}      | false    | An XCode build configuration dictionary [XCode Build Settings](https://xcodebuildsettings.com) |

#### app (under *flavorname*)

| key  | type   | default | required | description                   |
|:-----|:-------|:--------|:---------|:------------------------------|
| name | String |         | true     | The name of the App           |
| icon | String |         | false    | The icon path for this flavor |

#### android (under *flavorname*)

| key                 | type   | default | required | description                                                                |
|:--------------------|:-------|:--------|:---------|:---------------------------------------------------------------------------|
| applicationId       | String |         | true     | The applicationId of the Android App                                       |
| firebase            | Object |         | false    | An object which contains a Firebase configuration                          |
| resValues           | Array  |         | false    | An array which contains a set of resValues configurations                  |
| buildConfigFields   | Array  |         | false    | An array which contains a set of buildConfigFields configurations          |
| customConfig        | Array  |         | false    | An array which contains a set of custom configs, *overrides defaultConfig* |
| generateDummyAssets | bool   | true    | false    | True if you want to generate dummy assets (icon set, strings, etc)         |
| icon                | String |         | false    | The icon path for this android flavor                                      |
| adaptiveIcon        | Array  |         | false    | An array which contains foreground and background of adaptive icon         |

#### ios (under *flavorname*)

| key                 | type       | default | required | description                                                                                                   |
|:--------------------|:-----------|:--------|:---------|:--------------------------------------------------------------------------------------------------------------|
| bundleId            | String     |         | true     | The bundleId of the iOS App                                                                                   |
| buildSettings       | Dictionary | {}      | false    | A flavor-specific XCode build configuration dictionary [XCode Build Settings](https://xcodebuildsettings.com) |
| firebase            | Object     |         | false    | An object which contains a Firebase configuration                                                             |
| variables           | Array      |         | false    | An array which contains a set of variables configurations                                                     |
| generateDummyAssets | bool       | true    | false    | True if you want to generate dummy assets (xcassets, etc)                                                     |
| icon                | String     |         | false    | The icon path for this iOS flavor                                                                             |

#### macos (under *flavorname*)

| key                 | type       | default | required | description                                                                                                   |
|:--------------------|:-----------|:--------|:---------|:--------------------------------------------------------------------------------------------------------------|
| bundleId            | String     |         | true     | The bundleId of the macOS App                                                                                 |
| buildSettings       | Dictionary | {}      | false    | A flavor-specific XCode build configuration dictionary [XCode Build Settings](https://xcodebuildsettings.com) |
| firebase            | Object     |         | false    | An object which contains a Firebase configuration                                                             |
| variables           | Array      |         | false    | An array which contains a set of variables configurations                                                     |
| generateDummyAssets | bool       | true    | false    | True if you want to generate dummy assets (xcassets, etc)                                                     |
| icon                | String     |         | false    | The icon path for this macOS flavor                                                                           | 

#### firebase

| key    | type   | default | required | description                                                                                                                   |
|:-------|:-------|:--------|:---------|:------------------------------------------------------------------------------------------------------------------------------|
| config | String |         | false    | The path to the Firebase configuration file (google-services.json for Android and GoogleService-Info.plist for iOS and macOS) |

#### agconnect (for Android)

| key    | type   | default | required | description                                                            |
|:-------|:-------|:--------|:---------|:-----------------------------------------------------------------------|
| config | String |         | false    | The path to the AGConnect configuration file (agconnect-services.json) |

#### resValue (for Android)

| key   | type   | default | required | description                                                                                                                              |
|:------|:-------|:--------|:---------|:-----------------------------------------------------------------------------------------------------------------------------------------|
| type  | String |         | true     | The type of the [resValue](https://developer.android.com/reference/tools/gradle-api/7.0/com/android/build/api/variant/ResValue) variable |
| value | String |         | true     | The value of the resValue variable                                                                                                       |

```yaml
flavors:
  apple:
    app:
      name: "Apple App"
  
    android:
      applicationId: "com.example.apple"
      resValues:
        variable_one:
          type: "string"
          value: "example variable one"
        variable_two:
          type: "string"
          value: "example variable two"
  
    ios:
      bundleId: "com.example.apple"
```

#### buildConfigField (for Android)

| key   | type   | default | required | description                                                                                                                              |
|:------|:-------|:--------|:---------|:-----------------------------------------------------------------------------------------------------------------------------------------|
| type  | String |         | true     | The type of the [buildConfigField](https://developer.android.com/reference/tools/gradle-api/4.2/com/android/build/api/variant/BuildConfigField) variable |
| value | String |         | true     | The value of the buildConfigField variable                                                                                                       |

```yaml
flavors:
  apple:
    app:
      name: "Apple App"
  
    android:
      applicationId: "com.example.apple"
      buildConfigFields:
        field_one:
          type: "String"
          value: "example field one"
        field_two:
          type: "char"
          value: "y"
        field_three:
          type: "double"
          value: "20.0"
  
    ios:
      bundleId: "com.example.apple"
```

#### variable (for iOS and macOS)

| key    | type   | default | required | description                                                                                                                                                                                                                                          |
|:-------|:-------|:--------|:---------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| target | String |         | false    | The type of the [target](https://medium.com/geekculture/what-are-debug-and-release-modes-in-xcode-how-to-check-app-is-running-in-debug-mode-8dadad6a3428) (debug, release, profile). Do not specify a target if you want to apply it to all of them. |
| value  | String |         | true     | The value of the variable                                                                                                                                                                                                                            |

```yaml
flavors:
  apple:
    app:
      name: "Apple App"
  
    android:
      applicationId: "com.example.apple"
  
    ios:
      bundleId: "com.example.apple"
      variables:
        VARIABLE_ONE:
          value: "variable1"
        VARIABLE_TWO:
          target: "Debug"
          value: "variable2"        
```
#### customConfig (for Android only)

You can define any custom property for android
```yml
flavors:
  apple:
    app:
      name: "Apple App"
  
    android:
      applicationId: "com.example.apple"
      customConfig:
          versionNameSuffix: "\"-green-prod\"" # Don't forget to escape strings with \"
          signingConfig: flavorSigning.green
          versionCode: 1000
          minSdkVersion: 23
          # ..... and any custom property you want to add
```

This .yml part, generate this custom android flavor:

```groovy
apple {
  dimension "flavor-type"
  applicationId "com.example.apple"
  versionNameSuffix "-green-prod"
  signingConfig flavorSigning.green
  versionCode 1000
  minSdkVersion 23
}
```

#### adaptiveIcon (for Android only)

You can define adaptiveIcon for android:
```yml
flavors:
  apple:
    app:
      name: "Apple App"
  
    android:
      applicationId: "com.example.apple"
      icon: "assets/icon/appleApp/ic_launcher.png"
      adaptiveIcon:
        foreground: "assets/adaptive_icon/appleApp/ic_launcher_foreground.png"
        background: "assets/adaptive_icon/appleApp/ic_launcher_background.png"
```
After removing adaptiveIcon key, the adaptive icons generated before will still exist. Please delete adaptiveIcon manually.


## Usage

When you finished defining the flavorizr configuration, you can proceed by running the script with:

```terminal
flutter pub run flutter_flavorizr
```

You can also run flutter_flavorizr with a custom set of processors by appending the -p (or --processors) param followed by the processor names separated by comma:

```terminal
flutter pub run flutter_flavorizr -p <processor_1>,<processor_2>
```

Example

```terminal
flutter pub run flutter_flavorizr -p assets:download
flutter pub run flutter_flavorizr -p assets:download,assets:extract
```

## Run your flavors

Once the process has generated the flavors, you can run them by typing

```terminal
flutter run --flavor <flavorName> -t lib/main_<flavorName>.dart
```

Example

```terminal
flutter run --flavor apple -t lib/main_apple.dart
flutter run --flavor banana -t lib/main_banana.dart
```

Currently, due to a bug in the Flutter SDK, it's not possible to run the macOS flavors from the terminal.
You can run them from XCode by selecting the proper schema and by pressing play.

### Default processors set

By default, when you do not specify a custom set of processors by appending the -p (or --processors) param, a default processors set will be used:

* assets:download
* assets:extract
* android:androidManifest
* android:buildGradle
* android:dummyAssets
* android:icons
* flutter:flavors
* flutter:app
* flutter:main
* flutter:targets
* ios:podfile
* ios:xcconfig
* ios:buildTargets
* ios:schema
* ios:dummyAssets
* ios:icons
* ios:plist
* ios:launchScreen
* macos:podfile
* macos:xcconfig
* macos:configs
* macos:buildTargets
* macos:schema
* macos:dummyAssets
* macos:icons
* macos:plist
* google:firebase
* huawei:agconnect
* assets:clean
* ide:config

## Customize your app

Flutter_flavorizr creates different dart files in the lib folder. In the
flavors.dart file we have the F class which contains all of our
customizations.

```dart
class F {
  static Flavor? appFlavor;

  static String get title {
    switch (appFlavor) {
      case Flavor.apple:
        return 'Apple App';
      case Flavor.banana:
        return 'Banana App';
      default:
        return 'title';
    }
  }

}
```

The process creates a simple title customization: a
switch which checks the current appFlavor (defined in our app starting
point) and returns the correct value. Here you can write whatever you
want, you can create your custom app color palette, differentiate the
URL action of a button, and so on.

If you are wondering how to use these
getters, you can find an example under the pages folder: in the
my_home_page.dart file, the page shown after the launch of the app, we
can see a clear reference on the title getter defined in the F class.

## Side notes

I haven't found yet a good groovy parser to guarantee the idempotency of the AndroidBuildGradleProcessor.  
The only way to keep track of the autogenerated flavorDimensions is to mark up the beginning and the end of the section with magic comments.  
Please do not erase these comments otherwise you will break down the AndroidBuildGradleProcessor.

## Third party services

### Google Firebase

In order to flavorize your project and enable Firebase in your flavor you have to define a firebase object below each OS flavor. Under the firebase object you must define the config path of the google-services.json (if you are under Android configuration) or GoogleService-Info.plist (if you are under iOS or macOS configuration).

As you can see in the example below, we added the path accordingly

```yaml
flavors:
  apple:
    app:
      name: "Apple App"
  
    android:
      applicationId: "com.example.apple"
      firebase:
        config: ".firebase/apple/google-services.json"
  
    ios:
      bundleId: "com.example.apple"
      firebase:
        config: ".firebase/apple/GoogleService-Info.plist"
  
  banana:
    app:
      name: "Banana App"
      
    android:
      applicationId: "com.example.banana"
      firebase:
        config: ".firebase/banana/google-services.json"
    ios:
      bundleId: "com.example.banana"
      firebase:
        config: ".firebase/banana/GoogleService-Info.plist"
```

### Huawei AppGallery Connect

In order to flavorize your project and enable AppGallery Connect in your flavor  
you have to define an agconnect object below each Android flavor. Under the agconnect object you must define the config path of the agconnect-services.json.

As you can see in the example below, we added the path accordingly

```yaml
flavors:
  apple:
    app:
      name: "Apple App"
  
    android:
      applicationId: "com.example.apple"
      agconnect:
        config: ".agconnect/apple/agconnect-services.json"
  
    ios:
      bundleId: "com.example.apple"
  
  banana:
    app:
      name: "Banana App"
      
    android:
      applicationId: "com.example.banana"
      agconnect:
        config: ".agconnect/banana/agconnect-services.json"
    ios:
      bundleId: "com.example.banana"
```

## Troubleshooting
How to fix the error ["Unable to load contents of file list"](doc%2Ftroubleshooting%2Funable-to-load-contents-of-file-list%2FREADME.md)

## Docs & Tutorials (from the community)
[Easily build flavors in Flutter (Android and iOS) with flutter_flavorizr](https://angeloavv.medium.com/easily-build-flavors-in-flutter-android-and-ios-with-flutter-flavorizr-d48cbf956e4) - Angelo Cassano

[Get the best out of Flutter flavors with flutter_flavorizr](https://pierre-dev.hashnode.dev/get-the-best-out-of-flutter-flavors-with-flutterflavorizr) - Pierre Monier

## Further developments

* Let the user define its custom set of available instructions.

## Questions and bugs

Please feel free to submit new issues if you encounter problems while using this library.

If you need help with the use of the library or you just want to request new features, please use
the [Discussions](https://github.com/AngeloAvv/flutter_flavorizr/discussions) section of the 
repository. Issues opened as questions will be automatically closed.

## License

Flutter Flavorizr is available under the MIT license. See the LICENSE
file for more info.
