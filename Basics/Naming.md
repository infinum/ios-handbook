## Basic:

* use descriptive names
* lower camel case for classes, methods, variables, etc.
* class names should be capitalized
* method names and variables should start with a lowercase letter
* use `_` for private methods and variables _(open for discussion)_

### Preferred:

```swift
let maximumWidgetCount = 100

class WidgetContainer {
	var widgetButton: UIButton
	let widgetHeightPercentage = 0.85
}
```

### Not preferred:

```swift
let MAX_WIDGET_COUNT = 100

class app_widgetContainer {
    var wBut: UIButton
    let wHeightPct = 0.85
}
```

## Functions

Since _Swift 3_, all function parameters have labels unless you request otherwise by using underscore.

* Prefer method and function names that make use sites form grammatical English phrases.
    ##### Preferred:
    
    ```swift
    x.insert(y, at: z)          “x, insert y at z”
    x.subViews(havingColor: y)  “x's subviews having color y”
    x.capitalizingNouns()       “x, capitalizing nouns”
    ```
    ##### Not preferred:
    
    ```swift
    x.insert(y, position: z)
    x.subViews(color: y)
    x.nounCapitalize()
    ```
    
* Include all the words necessary to avoid ambiguity for a person reading code where the name is used.
    ##### Preferred:
    
    ```swift
    func remove(at position: Index) -> Element
    employees.remove(at: x)
    ```
    ##### Not preferred:
    
    ```swift
    func remove(_ position: Index) -> Element
    employees.remove(x) // unclear: are we removing x?
    ```

* When the first argument forms a part of a [prepositional phrase][3], give it an argument label. The argument label should begin at the preposition.
    ##### Preferred:
    
    ```swift
    func numberOfSections(in tableView: UITableView) -> Int
    func viewForZooming(in scrollView: UIScrollView) -> UIView?
    names.index(of: "Taylor")
    color.fadeFrom(red: b, green: c, blue: d) // Begin the argument label after the preposition, to keep the abstraction clear.
    ```
    ##### Not preferred:
    
    ```swift
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView?
    names.indexOf("Taylor")
    color.fade(fromRed: b, green: c, blue: d) // The first two arguments represent parts of a single abstraction
    ```
* Please visit [Swift API Design Guidelines][2] for more info and examples on function naming—they provide a lot of examples and explanations on edge cases.

## Enumerations

* Each enumeration definition defines a brand new type. So, like other types in Swift, their names should start with a capital letter.
* Use lower CamelCase for enumeration values.

### Preferred:

```swift
enum CompassPoint {
    case north
    case south
    case east
    case west
}
```

### Not preferred:

```swift
enum compassPoint {
    case North
    case South
    case East
    case West
}
```

## Prose

* When referring to functions in prose (tutorials, books and comments) include the required parameter names from the caller's perspective or `_` for unnamed parameters
* When in doubt, check how Xcode lists the method in the jump bar `(CTRL + 6)`.

![iOS NAMING - JUMP BAR](/img/xcode_jump_bar.png "iOS xCode jump bar methods naming")

### Example—Prose
```swift
Call convertPointAt(column:row:) from your own init implementation.

If you call date(from:) make sure that you provide a string with the format "yyyy-MM-dd".

You should not call the data source method tableView(_:cellForRowAt:) directly.
```

## Typealias

* Use `typealias` to make parameters meaningful.

### Example—Typealias:

```swift
typealias MimeType: String

func fileURL(with mimeType: MimeType, data: Data) -> URL
```

## Class prefixes

* Swift types are automatically namespaced by the module that contains them, and you should not add a class prefix. If two names from different modules collide, you can disambiguate by prefixing the type name with the module name.

### Example:

```swift
import SomeModule

let myClass = MyModule.UsefulClass()
```

This guide is mostly copied from [Swift API Design Guidelines][2], [Ray Wenderlich Swift guide][1], and [What's new in Swift 3.0][4], with some minor changes.

[1]:    https://github.com/raywenderlich/swift-style-guide#naming
[2]:    https://swift.org/documentation/api-design-guidelines/
[3]:    https://en.wikipedia.org/wiki/Adpositional_phrase#Prepositional_phrases
[4]:    https://www.hackingwithswift.com/swift3
