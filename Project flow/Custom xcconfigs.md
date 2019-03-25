Usually, when you work in a team environment, and/or when you need to use multiple configurations, _Xcode_ project settings UI can quickly get really messy, and it becomes hard to track changes.

`git log` is not really useful with the amount of noise you get by changing one simple _bool_.

## Proposed project structure (xcconfig files, build targets, build configurations)

- use __xcconfig files__ for project build settings and for custom user-defined keys
	- custom user keys (e.g., GOOGLE_ANALYTICS_KEY...)
- use __build configurations__ (default are release and debug) for different build setups
	- release build
	- qa build
	- test build
	- production build
- use __target__ to define a __single product__
	- it organizes the inputs into the build system
	- source files and instructions for processing those source files required to build that product
	- it usually doesn't make sense to use targets in place of build configurations

### Configuration structure

- two targets (and a project)
- three build configurations
- each build configuration (debug, release, qa)

```
Configurations
	|
	|-----> Shared (Project settings - Inherited from Xcode and custom (e.g. extra CLANG warnings))
	|	|
	|	|-----> Project - Shared.xcconfig
	|	|-----> Project - Debug.xcconfig
	|	|-----> Project - Release.xcconfig
	|	|-----> Project - QA.xcconfig
	|
	|-----> Target0
	|	|
	|	|-----> Target0 - Shared.xcconfig
	|	|-----> Target0 - Debug.xcconfig
	|	|-----> Target0 - Release.xcconfig
	|	|-----> Target0 - QA.xcconfig
	|
	|-----> Target1
	|	|
	|	|-----> Target1 - Shared.xcconfig
	|	|-----> Target2 - Debug.xcconfig
	|	|-----> Target3 - Release.xcconfig
	|	|-----> Target4 - QA.xcconfig
```

#### Shared

- will contain all settings that are inherited for a specific type of project (e.g., iOS)
- you'll want to have this included in everything else
- usually compiler flags and friends ... :)

		//  Clang Warnings
		OTHER_CFLAGS = -Wall -Wextra

- you would get those from the UI by clicking on a top-level project
	- PROJECT -> Name Of Your Project -> Build Settings
	
#### Target

- specific target settings would be
	- custom Info.plist
	- developer profile for signing the app
	- app icon
	- analytics key
	- Facebook key
	- iOS version...
 
### xcconfig

- the key/value file for storing build settings and user-defined keys

```
// Asset Catalog App Icon Set Name
//
// Name of the asset catalog app icon set whose contents will be merged into the
// Info.plist.

ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon

// Code Signing Identity
//
// The name ("common name") of a valid code-signing certificate in a keychain within your
// keychain path.   A missing or invalid certificate will cause a build error.

CODE_SIGN_IDENTITY = iPhone Developer


// Info.plist File
//
// This is the project-relative path to the plist file that contains the Info.plist
// information used by bundles.

INFOPLIST_FILE = Park-AAA copy-Info.plist


// Runpath Search Paths
//
// This is a list of paths to be added to the runpath search path list for the image
// being created.  At runtime, dyld uses the runpath when searching for dylibs whose load
// path begins with '@rpath/'. [-rpath]

LD_RUNPATH_SEARCH_PATHS = $(inherited) @executable_path/Frameworks


PRODUCT_BUNDLE_IDENTIFIER = infinum.co.Park-BBB


// Product Name
// 
// This is the basename of the generated product.

PRODUCT_NAME = $(TARGET_NAME)
```

- we will leverage this to make our project settings cleaner and easier to understand

### Build targets

- use when dealing with a template app, for example. One target for every vendor.
	- can have separate assets
	- a whole new project, except code, can be shared between targets more easily

### Build configurations

- use when we need to fine-tune certificates, third-party SDK keys, versioning APIs...

### User-defined keys

```
[[NSBundle mainBundle] objectForInfoDictionaryKey:@"HockeyKey"]];
```

## Custom xcconfigs

### Step 0—empty project

![](/img/xcconfig_tutorial/step_0.png)

### Step 1—targets

- add a new target
	- __CMD + D__

![](/img/xcconfig_tutorial/step_1.png)

- new target added
	
![](/img/xcconfig_tutorial/step_1_1.png)

### Step 2—add new build configurations

- select _project_
- _Info tab_
- _Configurations_
- always duplicate an existing one (choose between __debug__ and __release__)
	- use case: we are currently using our enterprise account for develop,
	but the client wants to use their account for release to the Store
	- so basically, we would have to change certificates, provisioning profiles, and bundle identifiers before
	each submission. This is both cumbersome and error-prone!
	- that is why we will create copies of both __debug__ and __release__ build configurations

![](/img/xcconfig_tutorial/step_2.png)

### Step 3—build settings

#### Project

- _Build settings_
	- always use `All` and `Levels`
- Settings will be resolved from __right to left__
	- __iOS Default—Project - Resolved__
- __iOS Default__—default settings defined by Apple (compiler flags, architecture, etc.)
- __Project__—user-defined using UI
- __Resolved__—by combining the previous two

![](/img/xcconfig_tutorial/step_3.png)

#### Target

- _Build Settings_
	- always use `All` and `Levels`
- Settings will be resolved from __right to left__
	- __iOS Default -> Project -> Target0 -> Resolved__
- the same as _project_, the only difference is that here you can define custom settings per target
	- user profiles, bundle identifiers, user defined keys (e.g., analytics)

![](/img/xcconfig_tutorial/step_3_1.png)

### Step 4—custom xcconfig

- for everything above, we want to use _xcconfig_ files to make it easier for us in the long run
	- it is much easier to add something in a text file than in _Xcode_
- but copying keys from _Xcode_ to _xcconfig_ files manually is cumbersome and error-prone
- we will use this handy tool for automatic creation: [BuildSettingsExtractor](https://github.com/dempseyatgithub/BuildSettingExtractor)
	- just drop you _Xcode_ project on top of it, and it will _autogenerate_ all the files you need
- what is great about this tool is that it __will not do anything__ to __your project__, you have to do it manually!

![](/img/xcconfig_tutorial/step_4.png)

### Step 5—set up custom xcconfig

- add all of the above to your project
	- I would suggest adding those by _drag'n'drop_ so that, when _Xcode_ asks you for which _target_ you want to add, those
	_unselect all targets_.
- add all of the custom _xcconfig_ files to your build configurations
	- select _Project_
	- select _Info_
	- _Configurations_
		- add custom config files

		![](/img/xcconfig_tutorial/step_5_1.png)

- select _project_ — _Build Settings_ (__All__ + __Levels__)

![](/img/xcconfig_tutorial/step_5_2.png)

- as you can see, there is a new field __Config.file(...)__—this is our custom config file
- but if we think about our goal to have everything inside our custom file:
	- we don't want the UI settings to override our custom file
	- settings will be resolved from right to left
	- that means that UI has higher precedence than custom files
	- go trough the Project row and delete it, you can only edit the Project row on the current level
		- you have to delete only the rows that have something

		![](/img/xcconfig_tutorial/step_5_3.png)

- _select target_ — _Build Settings_ (__All__ + __Levels__)

![](/img/xcconfig_tutorial/step_5_4.png)

- as you can see, there is also a new field on this level. Now we have 6 columns.

```
Resolved | Target0 | Config.File (Target Build) | Project | Config.File (Project Build)| iOS Default
```

- Config File (Target Build)
	- build configuration based on current target build configuration settings

	![](/img/xcconfig_tutorial/step_5_5.png)
	
- go through the target row and delete it

### Step 6—custom Info.plist

- after duplicating the default target in step 1., __Info.plist__ can get all messed up.
	- delete newly created __Info.plist__, which is probably in the root of the project
	- copy default __Info.plist__
	- rename both to something meaningful (e.g., Info—Target0.plist, Info—Target1.plist)
	- add those files to the project as you would add any other file
	- be sure to __unselect__ _Target Membership_

	![](/img/xcconfig_tutorial/step_6.png)

- set up your custom files to use those
	- open __Target0-Shared.xcconfig__
	- find __INFOPLIST_FILE__
	- change to __INFOPLIST_FILE = CustomConfiguration/Info - Target0.plist__ (your newly created)
	- check that everything is OK by clicking on
		- _Project_
		- _Target_
		- _General_

_The great thing about custom Info.plist is that you can easily setup custom AppIcon, Assets Catalog..._

### Step 7—Cocoapods

- be careful when installing _Pods_ in a project with multiple targets

```
platform :ios, '8.0'

use_frameworks!

link_with 'Target0', 'Target1'

pod 'Alamofire'

target 'Target0' do

end

target 'Target1' do

end
```

- pod install will probably give you a warning

![](/img/xcconfig_tutorial/step_7.png)

- this is normal because, as you know by now, we are using custom configuration files :). So in order for pods to work, we need to edit our _xcconfig_ files to also include pods custom _xcconfig_ files;

- open Target1-Debug.xcconfig

	![](/img/xcconfig_tutorial/step_7_1.png)

- and change to
	
	![](/img/xcconfig_tutorial/step_7_2.png)

- open Target1-Release.xcconfig
	
	![](/img/xcconfig_tutorial/step_7_3.png)

- and change to
	
	![](/img/xcconfig_tutorial/step_7_4.png)

- repeat this process for Target0.

__Build a project :)__

## Resources

- [Sample project](/resources/Sample_xcconfig.zip)
- [Using xcconfig files for your Xcode Project][1]
- [Generating Xcode Build Configuration Files with BuildSettingExtractor (xcodeproj → xcconfig)][2]

[1]:	http://www.jontolof.com/cocoa/using-xcconfig-files-for-you-xcode-project/
[2]:	http://jamesdempsey.net/2015/01/31/generating-xcode-build-configuration-files-with-buildsettingextractor-xcodeproj-to-xcconfig/
