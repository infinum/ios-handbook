## Your app  
* Never crashes
* Has no memory leaks
* Works on all iOS devices with different (minimum and maximum!) OS versions and resolutions
* Remains responsive after long/excessive use
* Securely stores sensitive information (Keychain)
* Works with different region and language settings
* Does not make use of any private APIs in the SDK
* Does not make use of any undocumented features in the SDK
* Does not refer to hardware capabilities that don't exist on the user's device
* Warns the user when there is no network connectivity, if it needs a connection
* Handles orientation appropriately
* Does not use any unapproved hardware accessories
* Does not contain a scripting interpreter, plugin, or other runtime that can execute downloaded content
* Does not use continuous vibration
* Uses the relevant keyboard for an input field (e.g., numbers for a phone number field)
* Deselects rows in table views after their selection causes another view to be displayed
* Restricts video streaming or other big downloads to WiFi connections only
* Makes clear to the user when private data will be sent to a server and provides an opt-out
* Does not make covert or non-obvious use of the camera or microphone
* Uses Core Location (GPS) for a real user benefit, not just advertising or tracking (if applicable)
* Does not make excessive use of iCloud storage
* Only stores user-created content in iCloud
* Stores temporary files in /tmp and deletes these on exit
* Uses the "do not back up" attribute for files that need to persist but should not be saved to iCloud

## Version compatibility

### Make sure that the new release is installed over the old version in a correct way:

* Install the application from the App Store
* Upload a new build to the iTunesconnect
* Enable internal and/or external testing for the new build
* Install the new version from TestFlight over the old version from the App Store
* Check that the user doesn't lose any of his information in the application after the update

### Check that data from NSUserDefaults is read in a correct way:

* App doesn't crash trying to read non-existing keys
* You haven't changed keys in the `initWithCoder:` and `encodeWithCoder:` methods (your current app should be able to read data saved by an old version of the application)  

## iOS SDK API updates:

* Check that geolocation is working (iOS8 SDK)
* Check that local notifications are working (iOS8 SDK)
* Check that push notifications are working

## Logging
* Remove or disable the `NSLog()` and `print()` calls. At least like this: #define NSLog(...)  

## Conforms to Apple's Human Interface Guidelines
* The app looks well designed and of high quality
* Native button icons are consistent with their native actions
* Activity spinners should not spin indefinitely
* Buttons trigger on touch-up inside an event
* Screen layout can handle the double-height status bar (e.g., during a phone call)
* Landscape mode, if supported, looks well-designed (i.e., is not accidental and bad)

You can find more information about this topic [here][1].

## iPad-specific
* Your app should work in all four orientations, but if it is only portrait or landscape, it has to support both ways up
* Your app doesn't nest popovers, i.e., selecting something on a popover should not display another popover
* Your app doesn't show more than one popover at a time

## Submission package details
* The name of your app (in the binary package) matches (or is the abbreviated version of) its iTunes name
* Your iTunes description accurately describes the functionality of the app, i.e., it works as advertised
* Your iTunes description does not state the price
* Your iTunes description (and the binary) does not include the names of any competing platforms (e.g., Android or Blackberry)
* Your iTunes description does not mention unreleased iOS version numbers
* Your iTunes keywords match the functionality of the app
* Your iTunes keywords do not contain the names of other apps
* If your app's price is over $100, or it has in-app purchases over $100, it is rated 17+
* The screenshots do not include error states
* The categories the app is in match its functionality
* Any Easter eggs in the app are innocuous and are disclosed in the 'demo account' field
* Icons are provided for each of the required sizes
* All different sizes of icons contain the same artwork
* Version number (bundle version number) is >= 1.0
* The required-device-capabilities entry in the info.plist file match the requirements of the app
* Your app matches your claimed OS version compatibility
* NSZombieEnabled is set to NO

[1]:	https://developer.apple.com/ios/human-interface-guidelines/overview/design-principles/
