At WWDC 2019., Apple revealed **[Sign in with Apple - Apple Developer][1]**, a privacy and security focused login service. It provides users with a way to sign up or log in into application by leveraging the Apple ID they have set up on their devices.

Initially it provided a nice alternative to Google/Facebook login, but as time passed, it became mandatory for all applications which are using any other type of third party login services, which is why it's necessary for you to know how to implement it. 

Don’t fret, it’s actually quite simple, as you’ll be able to see after reading and following the steps below.

## 1. Add the required capability

The first thing you need to do is to add the new **Sign in with Apple capability**. To do so, you need to:  
* click on your app target,
* go to the *Signing and capabilities* tab,
* click on the *+ Capability* button, 
* double click on *Sign in with Apple*

![Sign in with Apple capability][image-1]

This capability is **available only for non-enterprise account types**, which means that in 99% of cases you can only add this capability to the production target/configuration (depending on your project setup) which is **signed using the client’s account, not Infinum D.O.O.**. `#if APPSTORE` or whatever you have configured in your project for diferentiating environments will be your friend when following the next steps.

## 2. Add the Sign in with Apple button

Apple provides a dedicated class for the Sign in with Apple button, `ASAuthorizationAppleIDButton`. To create it, you just need to initialize it like you would a normal button and place it somewhere on the screen: 

```swift
import AuthenticationServices

let authorizationButton = ASAuthorizationAppleIDButton()
authorizationButton.center = view.center // Or wherever you want to place it.
view.addSubview(authorizationButton)
```

You can't manually adjust the font of this button, but you can change its frame, and the font size will adapt accordingly.

![Different button sizes][image-2]

Alternatively, if your layout requires it, you can create a custom Sign in with Apple button by following Apple's rules and using their resources - you can read more about it over at the [Human interface guidelines SIWA overview](https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple/overview/buttons/).

Since you'll be using the default button most of the times, it's good to know that along with the button's size and position, you can modify two more of its properties:
* **appearance** - you can choose between *white*, *white with an outline* and *black*,
* **corner radius**.

Now that the button is placed properly and looks the way you want to, let's get to the meat of this chapter - authorization handling.

## 3. Handle user authorization

You can add the action just like you usually would: 

```swift
authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
```

Of course, you can wrap this up in a nice Rx blanket if you like, but we'll leave that for the brave. 

Apple does pretty much all of the hard work and packs everything in the `ASAuthorizationController`, which will handle all the UI and presentation logic.

The only thing you need to do is to specify information you need via the `ASAuthorizationAppleIDRequest`, which you can create from `ASAuthorizationAppleIDProvider` and pass it on as a parameter to `ASAuthorizationController`.

In the following example, we request both *email* and *fullName* of the user:

```swift
@objc
func handleAuthorizationAppleIDButtonPress() {
    let appleIDProvider = ASAuthorizationAppleIDProvider()
    let request = appleIDProvider.createRequest()
    request.requestedScopes = [.fullName, .email]
    
    let authorizationController = ASAuthorizationController(authorizationRequests: [request])
    authorizationController.delegate = self
    authorizationController.presentationContextProvider = self
    authorizationController.performRequests()
}
```

As you can see, we are making our view controller a delegate for two things - **ASAuthorizationControllerPresentationContextProviding** and **ASAuthorizationControllerDelegate**. Let's set them up!

### Setting up delegate methods

`presentationContextProvider` (*ASAuthorizationControllerPresentationContextProviding*) asks for one thing, a window it will use for presenting the sign in dialog.

```swift
// MARK: - ASAuthorizationControllerPresentationContextProviding
func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    view.window ?? UIWindow()
}
```

`delegate` (*ASAuthorizationControllerDelegate*) has two methods which are called when signing in succedes or fails, respectively.

```swift
func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {        
        guard let appleIDToken = appleIDCredential.identityToken 
        else {
            print("Unable to fetch identity token")
            return
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) 
        else {
            print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            return
        }
                
        let userIdentifier = appleIDCredential.user
        let fullName = appleIDCredential.fullName
        let email = appleIDCredential.email
        
        // Add logic for handling these, you'll probably need to pass them to the backend.
    }
}
    
func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    guard let error = error as? ASAuthorizationError 
    else { return }

    // Instead of using these prints, add error handling and show the proper alert to the user. 
    switch error.code {
    case .canceled: print("Canceled")
    case .unknown: print("Unknown")
    case .invalidResponse: print("Invalid Response")
    case .notHandled: print("Not handled")
    case .failed: print("Failed")
    @unknown default: print("Default")
    }
}
```

This is pretty much everything you need to do to integrate Sign in with Apple into your apps. You can tap the sign in button now and see it in action.

## 4. Test different flows

The sign in flow is quite simple; let's have a quick look at what can happen when the sign in button is tapped.

### 1st case - the user not logged into Apple ID

If the device has no Apple ID, `authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error)` will be called with an `ASAuthorizationErrorUnknown` error case.

You don't have to do anything about this, system alert will automatically be shown, guiding users to the settings where they can sign in to their Apple ID.

![No Apple ID][image-3]

### 2nd case - user is logged into Apple ID

If the user is already signed in but using sign in with Apple for the first time, they will see the Data and privacy information screen.

![Data and privacy information][image-4]

If they cancel here, you will get the `ASAuthorizationErrorCanceled` error case, while tapping the **Continue** button would bring them to the sign in screen. We will also get this same error case if the user cancels the flow in any other subsequent case.

> Note - Every sign in request done in a simulator is treated as the first time, so you will see this dialog every time if you test in a simulator.

On the sign in screen, users will be presented with a form, prefilled with the full name and email that they used to register their Apple account.

Scope of the information that is shown here will depend on the scope you required when you were creating the request: 

```swift
let appleIDProvider = ASAuthorizationAppleIDProvider()
let request = appleIDProvider.createRequest()
request.requestedScopes = [.fullName, .email]
```

![Information scope][image-5]

After the users choose their preference regarding sharing their real name and e-mail adress and press **Continue**, there are no extra steps - Apple will do their magic, authenticate the user for you, and then notify you via the `authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization)` delegate method where you can get user information from the `ASAuthorization` object.

You can retrieve **fullName**, **email**, **user**, and **identityToken** from the object.

```swift
func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {        
        guard let appleIDToken = appleIDCredential.identityToken else {
            print("Unable to fetch identity token")
            return
        }
        
        // JWT token you will probably need to send to the backend.
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            return
        }
        
        let userIdentifier = appleIDCredential.user
        let fullName = appleIDCredential.fullName
        let email = appleIDCredential.email
        
        print(idTokenString) 
        print(userIdentifier)
        print(fullName)
        print(email)  
    } 
}
```

And just like that, you've just implemented your first Sign in with Apple!

## Implementation notes

These are some notes that we've gathered while testing out this feature, which could prove to be useful to you:

* Sign in with Apple is supported only on iOS 13+, so if you're supporting older OS versions `@available` will be your friend
* simulators can be hit or miss when it comes to working as one would expect, so test your implementation on a real device as much as you can; if it works in a simulator, great, but if you get an error 1000 (undefined) and you can’t figure out why, switch to a real device and see if the problem persists
* you will get a jwt token every time the user successfully signs in, it contains more info about your application and about the user - **application id, user's id, user’s email** etc - you’ll probably be sending this token to the backend
* you **don’t** need to setup SIWA Service on the developer portal, that is for web applications/services

[1]: https://developer.apple.com/sign-in-with-apple/

[image-1]: /img/sign_in_with_apple/add_capability.png
[image-2]: /img/sign_in_with_apple/button_sizes.png
[image-3]: /img/sign_in_with_apple/no_apple_id.png
[image-4]: /img/sign_in_with_apple/data_and_privacy.png
[image-5]: /img/sign_in_with_apple/scopes.png