## Initial setup

**Prerequisite:** Have Objective-C project

1. Add a new Swift file to the project
2. A dialogue box will appear on which you select "Create Bridging Header"
3. In project's general settings:
    * Go to Build Settings
    * In Packaging section, switch "Defines Module" from "No" to "Yes"
        * This is necessary for importing Swift code into Objective-C within the same framework.

### Multiple targets in a project

* **Bridging header**

If your project contains multiple targets, you will have multiple bridging headers. To avoid issues that can arise by having multiple bridging headers, you can:

1. Delete all bridging headers except one, and rename the one that remained to `{Product_Module_Name}-Bridging-Header.h`.
2. In Build Settings, under `Objective-C Bridging Header` put the path to the one bridging header that remained for every target.

After these steps, all targets will use the same bridging header.

* **Objective-C Generated Interface Header Name**

To avoid multiple names for Objective-C generated interface header name, you should use the same logic as with bridging headers.

In Build Settings, under `Objective-C Generated Interface Header Name`, you should use common name for every target, for example  `{Product_Module_Name}-Swift.h`.

### General project configuration

After adding your first Swift file to the project, some additional flags are going to come up in General project configuration. Some flags are important to you, and they are:

* `Other Swift Flags` used for Swift part
* `Preprocessor Macros` used for for Objective-C part

You want to configure both of them so you can use them in Objective-C and Swift codebase.

**Flags example:**

```
$(inherited)
"-D"
"COCOAPODS"
"-D"
"APPSTORE"
```

**Macros example:**

```
 $(inherited)
 COCOAPODS=1
 APPSTORE=1
```

**Usage example:**

* Swift

```swift
#if DEBUG
...
#endif
```

* Objective-C

```objc
#ifdef DEBUG
...
#endif
```

## Using Swift code in Objective-C

### Make Swift visible to Objective-C

In order to expose Swift class or methods to Objective-C, you can use different attributes:

* `@objc` - exposes single method or property
* `@objcMembers` - exposes all members of the class, its extensions, its subclasses, and all of the extensions of its subclasses

This will only work after you build your project.

It is possible to customise the way Swift method or class is represented in Objective-C. If you want to do that, you should use `@objc(name)` instead just `@objc`. For example,

```swift
@objc(sharedManager)
static let shared = MyManager()
```
In this example, by using `@objc(sharedManager)`, our singleton will be used in Swift files like `MyManager.shared`, while in Objective-C it will be used `[MyManager sharedManager]`. It is also possible to rename whole methods and parameters so it can match Objective-C naming style.

```swift
@objc(processNotificationPayload:notificationType:)
static func processNotification(with payload: String, notificationType: NotificationType) {
  ...
}
```
Finally, exposing Swift won't always work and here are possible reasons why:

* Structs and tuples are not visible in Objective-C
* Swift generic types are not visible in Objective-C
* Objective-C can't have default values in functions

Here are some useful information that can help in further development:

 * To make a Swift class available in Objective-C, it has to be descendant of an Objective-C class (e.g. NSObject)
 * `Any` in Swift is represented as `id` in Objective-C
 * You can't subclass a Swift class in Objective-C
 * If null specifiers are not provided, Objective-C properties will be implicitly unwrapped optionals in Swift -> can cause a crash!
 * If you want to use Swift enums in Objective-C, they have to have Int as a raw type

Only exposing Swift methods and classes to Objective-C is not enough to use it in Objective-C codebase. **You should also import exposed code into Objective-C**.

### Importing Swift into Objective-C

To access Swift code in Objective-C codebase, you have to use XCode - generated header file. Header name form is `{Product_Module_Name}-Swift.h`.

>Important: Never include `{Product_Module_Name}-Swift.h` in any `.h` file since this can cause cyclic reference.

* Importing into `.m` file

If you only want to use Swift code in `.m` file, you should import `{Product_Module_Name}-Swift.h` in that `.m` file.

* Importing into `.h` file

If you need to use Swift code in `.h` file, you should use something called Forward declaration, which is explained below.

#### Forward declaration

* Importing MySwiftClass.swift into Objective-C example:
1. Add `@class MySwiftClass` into `.h` file
2. Add `import {Product_Module_Name}-Swift.h`. into `.m` file

![1](/img/iOS-objc-swift-interoperability.png)

## VIPER

Whether you already have Base VIPER in your project written in Objective-C or not, **you should add Swift version of Base VIPER** which are going to be used for every new module written in Swift.

### Interoperability between Objective-C VIPER and Swift VIPER

* **Conflicts**

Having both versions of VIPER in your project will cause an issue with Wireframe naming since both versions of VIPER base wireframes have the same name.

The solution is to rename Objective-C `BaseWireframe` into `BaseWireframeOld`. After that, you should search your project for every time Objective-C BaseWireframe was used and rename it accordingly.

* **Interaction**

Since there are differences in BaseWireframe implementations and the way each of them navigates to the next screen, you should add `@objc` annotation into Swift BaseWireframe as it is shown in the code below to achieve easy navigation from Objective-C module to Swift module.

```swift
extension BaseWireframe {

    @objc var viewController: UIViewController {
        defer { temporaryStoredViewController = nil }
        return _viewController
    }

    @objc var navigationController: UINavigationController? {
        return viewController.navigationController
    }
}
```

- Example for navigation from Objective-C module to Swift module

```objc
    ...
    SwiftWireframe *wireframe = [SwiftWireframe new];
    [self.navigationController pushViewController:wireframe.viewController animated:YES];
```

## Polyglot

### Initial setup

* In `polyglot.yml` file of your project, change language from Objective-C to Swift

```
    language: swift
    ...
```

After you've changed `polyglot.yml` file, you should fetch translations with `polyglot pull`.

###  Tailoring language files for Objective-C needs

All language files that were created by Polyglot for the Objective-C should be replaced with Swift files.

This will cause an issue since structs are not visible in Objective-C, so Language struct in `Language.swift` won't be visible in Objective-C codebase. To fix this, you should create `LanguageObjC.swift` file with class that should represent Language struct from `Language.swift` file. An example of how to do that is shown below.

* Language.swift

```swift
public struct Language {

    public let name: String
    public let localName: String
    public let locale: String
    public let languageCode: String

    public static let croatian = Language(name: "Croatian", localName: "Hrvatski", locale: "hr_HR", languageCode: "hr_hr")

    public static let all = [
        Language.croatian
    ]

}
```

* LanguageObjC.swift

```swift
@objcMembers
class LanguageObjC: NSObject {

    public let name: String
    public let localeName: String
    public let locale: String
    public let languageCode: String

    init(language: Language) {
        self.name = language.name
        self.localeName = language.localName
        self.locale = language.locale
        self.languageCode = language.languageCode
    }

    public static let croatian = LanguageObjC(language: Language.croatian)

    public static let all = Language.all.map { LanguageObjC(language: $0) }
}
```

>Important: **If a new language is added to the project, LanguageObjC.swift file should be updated.**

Finally, change all instances where you used polyglot translations in .swift files from `_(@"...")` to `Strings.{...}.localized`.

### Language Manager

> Important: To localize your app, you should use this library: https://github.com/infinum/iOS-SwiftI18n

However, there is always a possibility to write your language manager which supports both Swift and Objective-C, and if you do decide to do that, it should look something like this:

```swift
var LanguageManagerLocaleKey: String = "LanguageManagerLocaleKey"

@objcMembers
class LanguageManager: NSObject {

    @objc(sharedManager)
    static let shared = LanguageManager()

    var locale: String {
        get {
            let locale = UserDefaults.standard.object(forKey: LanguageManagerLocaleKey)

            guard let localeTmp = locale else {
                return "hr_hr"
            }

            return localeTmp as! String
        }
        set (newValue) {
            UserDefaults.standard.set(newValue, forKey: LanguageManagerLocaleKey)
        }
    }

    private override init() {}
}
```

### Setting up language in Objective-C

* macro

To set up your macro which is going to be used throughout Objective-C codebase, you need to expose your LanguageManager to Objective-C.

```
#ifndef _
#define _(s) NSLocalizedStringFromTable(s, [LanguageManager sharedManager].locale, s)
#endif

#ifndef __
#define __(s,...) [NSString stringWithFormat:NSLocalizedStringFromTable(s, [LanguageManager sharedManager].locale, s), ##__VA_ARGS__]
#endif
```

* example

```swift
[LanguageManager sharedManager].locale = [LanguageObjC croatian].languageCode;
```

### Usage

Usage remains the same:

* in Objective-C files:
```swift
... = _(@"some_message")
```

* in Swift files:
```swift
... = Strings.someMessage.localized
```

## Colors, Images, Constants, and much more...

It is always important to have a single source of truth in your codebase. For that reason, initialising the same resource on two sides (Swift and Objective-C) is error-prone, since it is easy to forget to update both. Keeping that in mind, the developer can write an Objective-C - visible Swift class to expose Swift structures. An example is shown below: 

* UIColorExtensions.swift

```swift
extension UIColor {

    struct MyProject { }
}

// MARK: - Button -

extension UIColor.MyProject {

    static var button: UIColor {
        return UIColor(named: "MyProject/Color/Primary")!
    }

    static var secondaryButton: UIColor {
        return UIColor(named: "MyProject/Color/Secondary")!
    }
}
```

* UIColorObjC.swift

```swift
@objcMembers
class UIColorMyProject: NSObject {
    private override init() {}

    static var button: UIColor { return UIColor.MyProject.button }
    static var secondaryButton: UIColor { return UIColor.MyProject.secondaryButton }
}
```

## Testing

To test Objective-C in Swift unit test class and vice versa, you should do the same thing you do when you want to use some Swift code in Objective-C and Objective-C in Swift:

* **using Objective-C class in Swift unit test class**

It is only important to add Objective-C class which you want to test to bridging header file.

* **using Swift class in Objective-C unit test class**

Add `@objc` or `@objcMembers` in front of the class or function you want to test.
