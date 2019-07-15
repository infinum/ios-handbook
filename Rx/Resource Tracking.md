## Main project—DEBUG flag

- for every __debug__ target or scheme in your main project
- `OTHER_SWIFT_FLAGS = "-D" "DEBUG"`

### Pods project—TRACE RESOURCES flag

- add to your `Podfile`, replace config name with your config

```ruby
post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == 'RxSwift'
            target.build_configurations.each do |config|
                if config.name == 'Debug' || config.name == 'StagingDebug' || config.name == 'ProductionDebug'
                    config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['$(inherited)', '-D', 'TRACE_RESOURCES']
                end
            end
        end
    end
end
```

### Third-party stuff

- `SwiftyBeaver` pod, to make logging nicer

## Implementation

### ViewController-based tracking (preferred way)

- use this view controller as your base class

```swift
import UIKit
import RxSwift

class ViewController: UIViewController {

    #if DEBUG
        private let startResourceCount = Resources.total
    #endif

    // MARK: - Public -

    // MARK: - Overrides -

    // MARK: - Lifecycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        #if DEBUG
            let logString = "⚠️ Number of start resources = \(Resources.total) ⚠️"
            log.info(logString)
        #endif
    }

    deinit {
        #if DEBUG

            let mainQueue = DispatchQueue.main
            let when = DispatchTime.now() + DispatchTimeInterval.milliseconds(UIApplication.isInUITest ? 1000 : 300)

            mainQueue.asyncAfter (deadline: when) {
                let logString = "⚠️ Number of resources after dispose = \(Resources.total) ⚠️"
                log.info(logString)
            }

            /*
             !!! This cleanup logic is adapted for example app use case. !!!

             It is being used to detect memory leaks during pre-release tests.

             !!! In case you want to have some resource leak detection logic, the simplest
             method is to just print out `RxSwift.Resources.total` periodically to output. !!!

             /* add somewhere in
             func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
             */
             _ = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
             .subscribe(onNext: { _ in
             print("Resource count \(RxSwift.Resources.total)")
             })

             The most efficient way to test for memory leaks is:
             * navigate to your screen and use it
             * navigate back
             * observe the initial resource count
             * navigate to your screen once more and use it
             * navigate back
             * observe final resource count

             In case there is a difference in resource count between the initial and final resource counts, there might be a memory
             leak somewhere.

             The reason why we suggest two navigations is because the first navigation forces loading of lazy resources.
             */

        #endif
    }
}
```

### Periodic sampling

- basically, you put this part of the code in `AppDelegate` or any other class

```swift
_ = Observable<Int>
        .interval(1, scheduler: MainScheduler.instance)
        .subscribe(onNext: { _ in
             print("Resource count \(RxSwift.Resources.total)")
        })
```

## Testing

- check out the comments inside the `ViewController` base above ;)
    - go back and forth on the view controller that you wish to test and observe `Resources count`
    - if the discrepancy is too big, or if the count never drops after `dealloc`, you probably have a leak
    - also, it would be good practice to periodically use `Xcode's` memory debugger

## Troubleshooting (if you have memory leaks)

- you didn't clean up resources in `prepareForReuse` in `UITableViewCell`
- you are not using `DisposeBag` or `takeUntil`
- you are referencing `self` inside the `closures`
