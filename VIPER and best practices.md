<div class="markdown-output__summary">
  How to organise all your code and not end up with a couple of <i>Massive View Controllers</i> with millions of lines of code?
</div>

In short, **VIPER (View Interactor Presenter Entity Router)** is an architecture which aims at solving the common *Massive View Controller* problem in iOS apps. When implemented to its full extent it achieves separation of concerns between modules in your code, which yields testability. This is also good because another problem with Apple's Model View Controller architecture is poor testability.

If you search the web for VIPER architecture in iOS apps you'll find a number of different implementations. At Infinum we have tested several approaches to this architecture and through that experience and a couple of at length discussions we have defined our own version of VIPER which will be described in this chapter.

The main components of VIPER are as follows:

* **View**: contains UI logic and knows how to layout and animate itself. It displays what it's _told_ by the Presenter and it _delegates_ user interaction actions to the Presenter. Ideally it contains no business logic, only view logic.
* **Interactor**: used for fetching data regardless of where the data is coming from. Contains only business logic.
* **Presenter**: prepares the content which it receives from the Interactor to be presented by the View. Contains business and view logic.
* **Entity**: models which are handled by the Interactor. Contains only business logic.
* **Router**: handles navigation logic. In our case we use components called Wireframes for this responsibility. These contain business and view logic.

## Components
Your entire app is made up of multiple modules which you group in logical entities and use one storyboard for that entity. In most cases the modules will represent screens and your entities will represent user-stories, buisness-flows and so on.

![iOS VIPER MODULES](/img/ios_viper_modules.png "iOS VIPER MODULES")

**Module** components:

* **View**
* **Presenter**
* **Interactor** (not mandatory)
* **Wireframe**

In some simpler cases you won't need an Interactor for a certain module, which is why this component is not mandatory.

Wireframes, Presenters and Interactors inherit PONSOs (Plain Old NSObject). Views inherit UIViewControllers. All protocols should be located in one file called *Interfaces*.

## Communication and references
The following pictures shows relationships and communication for one module.

![iOS VIPER GRAPH](/img/ios_viper_graph.jpg "iOS VIPER GRAPH")

* The View contains a *presenter* property/var with a strong reference. It communicates with that Presenter via a *DogViewDelegate* protocol. This protocol defines methods which delegate event responses to the presenter, such as taps on buttons and table cells. As such their names should begin with verbs like *should...*, *did...*, *will...*, and so on.
* The Presenter contains a *view* property/var with a weak reference. It communicates with that View via a *DogViewInterface* protocol.
* The Presenter contains an *interactor* property/var with a strong reference. It communicates with that Interactor via a *DogInteractorInterface* which defines methods in which the Interactor passes the data to the Presenter via closures.
* The Presenter contains a *wireframe* property/var with a strong reference. It communicates with that Wireframe via a protocol.

Although the strong/weak references might appear a bit counter-intuitive they are organised this way to assure all module components are not deallocated from memory as long as one of its Views is active.

The creation and setup of module components is done in it's Wireframe. The creation of a new Wireframe is almost always done in the previous Wireframe. More details on this later in the actual code.

## VIPER modules

Using this architecture demands a lot of boilerplate code which is a pain to write each time. Therefore you should use [VIPER module generator][1] which goes hand-in-hand with [iOS project generator][2]. The project generator creates some base interfaces which are needed for your modules. Try both of these tools and get real cozy with them because you'll be using them on all new projects!

Using this VIPER module generator you will get 5 _Swift_ files which implement this logic. Let's go over these generated files one by one. For an example we'll create a *Login* module.

Before we get to the actual generated files we'll need to cover the base protocols/classes which are: `BaseWireframe`/`WireframeInterface`, `ViewInterface`, `PresenterInterface` and `InteractorInterface`:

### BaseWireframe

```swift
enum Transition {
    case root
    case push
    case present(fromViewController: UIViewController)
}

protocol WireframeInterface: class {
    func popFromNavigationController(animated: Bool)
    func dismiss(animated: Bool)
}

class BaseWireframe {

    unowned var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func show(_ viewController: UIViewController, with transition: Transition, animated: Bool) {
        switch transition {
        case .push:
            navigationController.pushViewController(viewController, animated: animated)
        case .present(let fromViewController):
            navigationController.viewControllers = [viewController]
            fromViewController.present(navigationController, animated: animated, completion: nil)
        case .root:
            navigationController.setViewControllers([viewController], animated: animated)
        }
    }
}

extension BaseWireframe: WireframeInterface {
    
    func popFromNavigationController(animated: Bool) {
        let _ = navigationController.popViewController(animated: animated)
    }

    func dismiss(animated: Bool) {
        navigationController.dismiss(animated: animated)
    }
}

```
The `Transition` enumeration provides three standard ways of showing a module:

1. setting it as a root module,
2. pushing it on a current navigation controller and 
3. presenting it over given view controller.

The `WireframeInterface` is pretty straightforward and it's extension offers very practical out-of-the-box navigational functions which you should use whenever possible. 

The `BaseWireframe`, as its name states, is base class for each wireframe. Every wireframe has its own *navigation controller*. Also, it provides default implementation for `show(_:with:animated:)` method which takes care of showing the module. Showing behaviour is controlled with `Transition` enum in these ways:

1.  `.push` will push current module on wireframe's *navigation controller*,
2.  `.present` will first embed given *view controller* as an initial view controller on wireframe's *navigation controller* and then it will present *navigation controller* over `fromViewController`, and
3.  `.root` will make given *view controller* as an initial view controller on wireframe's *navigation controller* (useful when setting current module as root view controller on `UIWindow`).


### ViewInterface

This interface is initially empty. It exists just to make it simple to insert any and all functions needed in all views in your project.

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
The `PresenterInterface` offers only optional methods which are used for the *Presenter* to perform tasks based on view events. For methods you use without implementing them you'll get a nice big fatal error.

### InteractorInterface

This interface, like `ViewInterface`, is initially empty. It exists just to make it simple to insert any and all functions needed in all interactors in your project.

Ok, let's get to the actual module files generated by [VIPER module generator][1]...

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

This interface file will provide you with a nice overview of your entire module at one place.
The `LoginNavigationOption` enum is used for all navigation options which envolve creating a new wireframe and navigating to it in which ever way possible. Since this is an action which almost always envolves some user interaction on the view which then notifys the presenter which then just notifies the wireframe to perform the navigation - this is generalised and generated automatically for each module. Well provide a more detailed example for this a bit later.

### Wireframe

```swift
final class LoginWireframe: BaseWireframe {

    // MARK: - Private properties -

    private let _storyboard: UIStoryboard = UIStoryboard(name: "Login", bundle: nil)

    // MARK: - Module setup -

    func configureModule(with viewController: LoginViewController) {
        let interactor = LoginInteractor()
        let presenter = LoginPresenter(wireframe: self, view: viewController, interactor: interactor)
        viewController.presenter = presenter
    }

    // MARK: - Transitions -

    func show(with transition: Transition, animated: Bool = true) {
        let moduleViewController = _storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        configureModule(with: moduleViewController)

        show(moduleViewController, with: transition, animated: animated)
    }
}

// MARK: - Extensions -

extension LoginWireframe: LoginWireframeInterface {

    func navigate(to option: LoginNavigationOption) {
    }
}
```

In `configureModule` method, as its name states, should be implemented all logic for initial module configuration. Probably you are asking yourself now: _Configure with what?_. Since this is automatically generated class, we cannot know for what will you use it, so, it is on you to define all needed data models in interactor and/or presenter initializers, and also to define them in `configureModule` and `show` methods. 

Let say, for showing bank account details module you'll probably need a bank account model or its `ID` so instantiating and showing module would look something like this:

```swift
...
let wireframe = BankAccountDetailsWireframe(navigationController: navigationController)
wireframe.show(with: bankAccount, transition: .push)
...
```

The `navigate(to:)` method will implement logic for navigating to other modules, more detail on this in an example a bit later.

### Presenter

```swift
final class LoginPresenter {

    // MARK: - Private properties -

    fileprivate weak var _view: LoginViewInterface?
    fileprivate var _interactor: LoginInteractorInterface
    fileprivate var _wireframe: LoginWireframeInterface

    // MARK: - Lifecycle -

    init (wireframe: LoginWireframeInterface, view: LoginViewInterface, interactor: LoginInteractorInterface) {
        _wireframe = wireframe
        _view = view
        _interactor = interactor
    }
}

// MARK: - Extensions -

extension LoginPresenter: LoginPresenterInterface {
}
```

This is the skeleton of a *presenter* which will get a lot more meat on it once you start implementing the business logic.

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
Like the *presenter* above, this is only a skeleton which you will populate with IBoutlets, animations and so on.

### Interactor

```swift
final class LoginInteractor {
}

extension LoginInteractor: LoginInteractorInterface {
}
```
Once again, this is only a skeleton which you will, in most cases, use to proxy API services, database services, etc.

### Example
Here is an example of a wireframe for a home screen module which uses two types of navigation options: `.login` which takes an `UserAccount` instance and `.register`. Notice how the navigation option enum is handled in the `navigate(to:)` method, this is the preferred way of using it.

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

    func configureModule(with viewController: HomeViewController) {
        let interactor = HomeInteractor()
        let presenter = HomePresenter(wireframe: self, view: viewController, interactor: interactor)
        viewController.presenter = presenter
    }

    // MARK: - Transitions -

    func show(with transition: Transition, animated: Bool = true) {
        let moduleViewController = _storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        configureModule(with: moduleViewController)

        show(moduleViewController, with: transition, animated: animated)
    }
}

// MARK: - Extensions -

extension HomeWireframe: HomeWireframeInterface {

    func navigate(to option: HomeNavigationOption) {
        switch option {
        case .login(let userAccount):
            let wireframe = LoginWireframe(navigationController: navigationController)
            wireframe.show(with: userAccount, transition: .push)
        case .register:
            let moduleNavigationController = UINavigationController()
            let wireframe = RegisterWireframe(navigationController: moduleNavigationController)
            wireframe.show(with: .present(fromViewController: self.navigationController!))
        }
    }
}
```

## Resources

All resources should be located in dedicated *Resources* folder. This folder should contain image assets, fonts, audio and video files, and so on. For images use only one *.xcassets* and separate them into logical folders inside of it.

Sometimes you'll need to be handling temp mock resources. Don't put these files into your standard *.xcassets* because it's easy to lose track of them that way and leave them in production! Instead create a separate *.xcassets* files called *temp.xcassets*, this will make it very easy for you to locate and delete these items later. Also delete each of these mock files the moment you don't need them any more since there is no point in keeping them and they increase build file size.


### Useful links

* [Architecting iOS Apps with VIPER][3]

### Tools

* [VIPER Module Generator][1]
* [iOS project generator][2]


[1]:    https://github.com/infinum/iOS-VIPER-Xcode-Templates
[2]:    https://bitbucket.org/infinum_hr/ios-project-generator
[3]:    https://www.objc.io/issues/13-architecture/viper/
