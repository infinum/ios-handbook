<div class="markdown-output__summary">
  How to organize all your code and not end up with a couple of <i>Massive View Controllers</i> with millions of lines of code?
</div>

In short, **VIPER (View Interactor Presenter Entity Router)** is an architecture which aims at solving the common *Massive View Controller* problem in iOS apps. When implemented to its full extent, it achieves separation of concerns between modules in your code, which yields testability. This is also good because poor testability is another problem with Apple's Model View Controller architecture.

If you search the web for VIPER architecture in iOS apps, you'll find a number of different implementations. At Infinum, we have tested several approaches to this architecture. Through that experience, and after discussing it at length, we have defined our own version of VIPER, which will be described in this chapter.

The main components of VIPER are:

* **View**—contains UI logic and knows how to lay out and animate itself. It displays what it's _told_ by the Presenter and it _delegates_ user interaction actions to the Presenter. Ideally, it contains no business logic, only view logic.
* **Interactor**—used for fetching data regardless of where the data is coming from. Contains only business logic.
* **Presenter**—prepares the content which it receives from the Interactor to be presented by the View. Contains business and view logic.
* **Entity**—a model which is handled by the Interactor. Contains only business logic.
* **Router**—handles navigation logic. In our case, we use components called wireframes for this responsibility. These contain business and view logic.

## Components
Your entire app is made up of multiple modules which you group in logical entities and use one storyboard for that entity. In most cases, the modules will represent screens, and your entities will represent user stories, business flows, and so on.

![iOS VIPER MODULES](/img/ios_viper_modules.png "iOS VIPER MODULES")

**Module** components:

* **View**
* **Presenter**
* **Interactor** (not mandatory)
* **Wireframe**

In some simpler cases, you won't need an Interactor for a certain module, which is why this component is not mandatory.

Wireframes, Presenters, and Interactors inherit PONSOs (Plain Old NSObject). Views inherit UIViewControllers. All protocols should be located in one file called *Interfaces*.

## Communication and references

The following picture shows the relationships and communication for one module.

![iOS VIPER GRAPH](/img/ios_viper_graph.jpg "iOS VIPER GRAPH")

* The View contains a *presenter* property/var with a strong reference. It communicates with that Presenter via a *DogViewDelegate* protocol. This protocol defines methods which delegate event responses to the Presenter, such as taps on buttons and table cells. As such, their names should begin with verbs like *should...*, *did...*, *will...*, and so on.
* The Presenter contains a *view* property/var with a weak reference. It communicates with that View via a *DogViewInterface* protocol.
* The Presenter contains an *interactor* property/var with a strong reference. It communicates with that Interactor via a *DogInteractorInterface* that defines the methods in which the Interactor passes the data to the Presenter via closures.
* The Presenter contains a *wireframe* property/var with a strong reference. It communicates with that wireframe via a protocol.

Although the strong/weak references might appear a bit counterintuitive, they are organized this way to ensure that all module components are not deallocated from memory as long as one of its Views is active.

Module components are created and set up in its wireframe. A new wireframe is almost always created in the previous wireframe. We'll provide more details on this later in the actual code.

## VIPER modules

Using this architecture demands a lot of boilerplate code, which is a pain to write each time. Therefore, you should use the [VIPER module generator][1], which goes hand-in-hand with the [iOS project generator][2]. The project generator creates some base interfaces that are needed for your modules. Try out both of these tools and get real cozy with them because you'll be using them on all new projects.

Using this VIPER module generator, you will get 5 _Swift_ files that implement this logic. Let's go over these generated files one by one. For example, we'll create a *Login* module.

Before we get to the generated file, we'll need to cover the base protocols/classes, which are: `BaseWireframe`/`WireframeInterface`, `ViewInterface`, `PresenterInterface`, and `InteractorInterface`:

### BaseWireframe

```swift
protocol WireframeInterface: class {
}

class BaseWireframe {

    private unowned var _viewController: UIViewController

    // To retain view controller reference upon first access
    private var _temporaryStoredViewController: UIViewController?

    init(viewController: UIViewController) {
        _temporaryStoredViewController = viewController
        _viewController = viewController
    }

}

extension BaseWireframe: WireframeInterface {

}

extension BaseWireframe {

    var viewController: UIViewController {
        defer { _temporaryStoredViewController = nil }
        return _viewController
    }

    var navigationController: UINavigationController? {
        return viewController.navigationController
    }

}

extension UIViewController {

    func presentWireframe(_ wireframe: BaseWireframe, animated: Bool = true, completion: (()->())? = nil) {
        present(wireframe.viewController, animated: animated, completion: completion)
    }

}

extension UINavigationController {

    func pushWireframe(_ wireframe: BaseWireframe, animated: Bool = true) {
        self.pushViewController(wireframe.viewController, animated: animated)
    }

    func setRootWireframe(_ wireframe: BaseWireframe, animated: Bool = true) {
        self.setViewControllers([wireframe.viewController], animated: animated)
    }

}

```

The `BaseWireframe`, as its name states, is a base class for each wireframe. Each wireframe has its own instance of a *view controller*. The *navigation controller* is a computed property inferred from the *view controller*. The file contains two extensions. The first is a `UIViewController` extension with implementation for wireframe presentation. The second extension is a `UINavigationController` extension, which offers methods for wireframe navigation:

* pushing the wireframe on stack, and
* setting the wireframe as the root wireframe of *navigation controller*.

### ViewInterface

This interface is initially empty. It exists just to simplify the insertion of any and all functions needed in all views in your project.

### PresenterInterface

```swift
protocol PresenterInterface: class {
    func viewDidLoad()
    func viewWillAppear(animated: Bool)
    func viewDidAppear(animated: Bool)
    func viewWillDisappear(animated: Bool)
    func viewDidDisappear(animated: Bool)
}

extension PresenterInterface {

    func viewDidLoad() {
        fatalError("Implementation pending...")
    }

    func viewWillAppear(animated: Bool) {
        fatalError("Implementation pending...")
    }

    func viewDidAppear(animated: Bool) {
        fatalError("Implementation pending...")
    }

    func viewWillDisappear(animated: Bool) {
        fatalError("Implementation pending...")
    }

    func viewDidDisappear(animated: Bool) {
        fatalError("Implementation pending...")
    }
}
```
`PresenterInterface` offers only optional methods that are used for the *Presenter* to perform tasks based on view events. For methods you use without implementing them, you'll get a nice, big fatal error.

### InteractorInterface

This interface, like `ViewInterface`, is initially empty. It exists just to simplify the insertion of any and all functions needed in all interactors in your project.

OK, let's get to the actual module files generated by [VIPER module generator][1]...

### Interfaces

```swift
enum LoginNavigationOption {
}

protocol LoginWireframeInterface: WireframeInterface {
    func navigate(to option: LoginNavigationOption)
}

protocol LoginViewInterface: ViewInterface {
}

protocol LoginPresenterInterface: PresenterInterface {
}

protocol LoginInteractorInterface: InteractorInterface {
}
```

This interface file will provide you with a nice overview of your entire module in one place.
The `LoginNavigationOption` enum is used for all navigation options which involve creating a new wireframe and navigating to it in whichever way possible. Since this is an action which almost always involves some user interaction on the view, which then notifies the presenter, which notifies the wireframe to perform the navigation—this is generalized and generated automatically for each module. We'll provide a more detailed example a bit later.

### Wireframe

```swift
final class LoginWireframe: BaseWireframe {

    // MARK: - Private properties -

    private let _storyboard: UIStoryboard = UIStoryboard(name: "Login", bundle: nil)

    // MARK: - Module setup -

    init() {
        let moduleViewController = _storyboard.instantiateViewController(ofType: LoginViewController.self)
        super.init(viewController: moduleViewController)

        let interactor = LoginInteractor()
        let presenter = LoginPresenter(wireframe: self, view: moduleViewController, interactor: interactor)
        moduleViewController.presenter = presenter
    }

}

// MARK: - Extensions -

extension LoginWireframe: LoginWireframeInterface {

    func navigate(to option: LoginNavigationOption) {
    }
}
```

The `init` method should implement all initialization logic for the module. Since this is an automatically generated class, we cannot know what you will use it for, so it is up to you to define all the needed data models in the initializer.

The `navigate(to:)` method will implement logic for navigation to other modules.

For example, for a module showing bank account details, you'll probably need a bank account model or its `ID`. Instantiating and showing a module with the `navigate(to:)` method would look something like this:

```swift
...
func navigate(to option: BankAccountNavigationOption) {
    switch option {
    case .bankAccountDetails(let bankAccount):
        let bankAccountDetailsWF = BankAccountDetailsWireframe(bankAccount: bankAccount)
        navigationController?.pushWireframe(bankAccountDetailsWF)
    }
}
...
```

### Presenter

```swift
final class LoginPresenter {

    // MARK: - Private properties -

    private unowned let _view: LoginViewInterface?
    private let _interactor: LoginInteractorInterface
    private let _wireframe: LoginWireframeInterface

    // MARK: - Lifecycle -

    init(wireframe: LoginWireframeInterface, view: LoginViewInterface, interactor: LoginInteractorInterface) {
        _wireframe = wireframe
        _view = view
        _interactor = interactor
    }
}

// MARK: - Extensions -

extension LoginPresenter: LoginPresenterInterface {
}
```

This is the skeleton of a *presenter* which will get a lot more flesh on it once you start implementing business logic.

### ViewController

```swift
final class LoginViewController: UIViewController {

    // MARK: - Public properties -

    var presenter: LoginPresenterInterface!

    // MARK: - Life cycle -

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - Extensions -

extension LoginViewController: LoginViewInterface {
}
```

Like the *presenter* above, this is only a skeleton which you will populate with IBOutlets, animations, and so on.

### Interactor

```swift
final class LoginInteractor {
}

extension LoginInteractor: LoginInteractorInterface {
}
```

Once again, this is only a skeleton which you will, in most cases, use to proxy API services, database services, etc.

### Example

Here is an example of a wireframe for a home screen module which uses two types of navigation options: `.login`, which takes a `UserAccount` instance, and `.register`. Notice how the navigation option enum is handled in the `navigate(to:)` method—this is the preferred way of using it.

```swift
// HomeInterfaces

enum HomeNavigationOption {
    case login(UserAccount)
    case register
}

// HomeWireframe

final class HomeWireframe: BaseWireframe {

    // MARK: - Private properties -

    private let _storyboard: UIStoryboard = UIStoryboard(name: "Home", bundle: nil)

    // MARK: - Module setup -

    init() {
        let moduleViewController = _storyboard.instantiateViewController(ofType: HomeViewController.self)
        super.init(viewController: moduleViewController)

        let interactor = HomeInteractor()
        let presenter = HomePresenter(wireframe: self, view: moduleViewController, interactor: interactor)
        moduleViewController.presenter = presenter
    }

}

// MARK: - Extensions -

extension HomeWireframe: HomeWireframeInterface {

    func navigate(to option: HomeNavigationOption) {
        switch option {
        case .login(let userAccount):
            let wireframe = LoginWireframe(userAccount: userAccount)
            navigationController?.pushWireframe(wireframe)
        case .register:
            let wireframe = RegisterWireframe()
            viewController.presentWireframe(wireframe, animated: true)
        }
    }
}
```

## Resources

All resources should be located in the dedicated *Resources* folder. This folder should contain image assets, fonts, audio and video files, and so on. Use only one *.xcassets* for images and separate them into logical folders inside of it.

Sometimes, you'll have to handle temp mock resources. Don't put these files into your standard *.xcassets* because it's easy to lose track of them and leave them in production! Instead, create a separate *.xcassets* file called *temp.xcassets*. This will make it very easy for you to locate and delete these items later. Also, delete each of these mock files the moment you don't need them any more since there is no point in keeping them, and they increase build file size.

### Useful links

* [Architecting iOS Apps with VIPER][3]

### Tools

* [VIPER Module Generator][1]
* [iOS Project Generator][2]

[1]:    https://github.com/infinum/iOS-VIPER-Xcode-Templates
[2]:    https://bitbucket.org/infinum_hr/ios-project-generator
[3]:    https://www.objc.io/issues/13-architecture/viper/
