As our Swift projects are getting bigger, we noticed that the compile time was way above what one would call acceptable. I'm talking in range of ~25 min for clean build.

After some investigation, we realize that there are two major problem groups, one was Cocoapods, and other was Swift syntax.

Bellow you can find some issues and how to resolve them. Also this isn't silver bullet, so the best way is to do it gradually and measure intermediate state.

## Common issues

### Complex expressions, e.g.

**Bad**

```swift
let x = ["A", nil, "B", nil,"C"].flatMap{$0}.reduce("", +)
```

**Good**

```swift
let x: String = ["A", nil, "B", nil,"C"]
    .flatMap { letter -> String? in
        return letter
    }
    .reduce("") { (accumulator, nextItem) -> String in
        return accumulator + nextItem
    }
```

### Concatenation of string:

**Bad**

```swift
let greeting1 = "Hello, \(firstName) \(lastName)!"
let greeting2 = "Hello, " + firstName + " " + lastName + "!"
```
**Good**

```swift
let greeting = String(format: "Hello, %@ %@!", firstName, lastName)
```

### Literal array build

**Bad**

```swift
let x = [
    CellItem(name: "A", count: 23, selected: false, actionHandler: {}),
    CellItem(name: "B", count: 12, selected: true, actionHandler: {}),
    CellItem(name: "C", count: 15, selected: true, actionHandler: {}),
    CellItem(name: "D", count: 44, selected: false, actionHandler: {}),
]
```

**Good**

```swift
var x = [CellItem]()
x.append(CellItem(name: "A", count: 23, selected: false, actionHandler: {}))
x.append(CellItem(name: "B", count: 12, selected: true, actionHandler: {}))
x.append(CellItem(name: "C", count: 15, selected: true, actionHandler: {}))
x.append(CellItem(name: "D", count: 44, selected: false, actionHandler: {}))
```

*Above mentioned problems may or may not affect your build time, the only way to be sure of this is to actually measure how long does it take for each method call to compile. If you ask yourself how to do it, scroll to the bottom ;)*

## Cocoapods

* Everytime you do Clean and Build, all of your pods will be recompiled.
* That takes a lot of time, in our case almost 17 min!
* To alleviate this, here is a small trick, put this inside of your pod file as a post installation hook:

```ruby
post_install do |installer|
  puts "********** PODS POST INSTALLATION HOOK **********"
  puts "Updating **BUILD SETTINGS** key **DEBUG_INFORMATION_FORMAT** for **ALL PODS** to allow faster build time by changing **DWARF with dSYM** to **DWARF** when in **DEBUG** ... "
  installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
      if config.name =~ /Debug/
          # This adds the flag to the Pods.xcodeproj itself at the most local level (basically per **Pod**)
          config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf';
      end
    end
  end
end
```

* What this will do is it will go trough all of your Pod target, **Build Settings** and under **Debug Information** it will change `DWARF with dSYM` to only `DWARF`. This is perfectly fine when in **DEBUG** for 99% of the time.
* dSYM are symbols that you need to symbolicate crash logs (so that you can get method names etc ...)

## Global project compile time:

* If you want to see how long does it take for the whole project to build, just copy/paste this to console and restart Xcode

  `$ defaults write com.apple.dt.Xcode ShowBuildOperationDuration YES`

## Compile time per method call:

* Go to **Build Settings** and add to **Swift flags** key, **-Xfrontend -debug-time-function-bodies**
* Clean and build your project
* Follow the screenshot

![iOS Methods Compile Time](/img/iOS-Method-Compile-Time.png)

* Open text editor and paste copied log, save to the ~/Desktop
* Wait a bit because it can be well over 100MB
* Copy Ruby script [iOS Compile Time Review](/img/compile_time_review.rb) to ~/Desktop
* Run script in terminal
  `$ ruby compile_time_review.rb YOUR_FILE_NAME > out.txt`
* Open out.txt and look at the results
* Fix da shit, clean build, and run again to see if improved.
