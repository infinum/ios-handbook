## A guide to our Swift style and conventions.

This is an attempt to encourage patterns of coding that help accomplish the following goals (in
rough priority order):

1. increased rigor and decreased likelihood of programmer error,
2. increased clarity of intent,
3. reduced verbosity, and
4. fewer debates about aesthetics

## One rule to rule them all ---> **KISS** <---

* Don't be a smartass.
* Read, understand, and apply [KISS](https://en.wikipedia.org/wiki/KISS_principle).

***Trivia:*** The phrase was coined by the lead engineer of SR-71 Blackbird.

## Whitespace

* Tabs, not spaces.
* End files with a new line.
* Make liberal use of vertical whitespace to divide code into logical chunks.
* Don’t leave trailing whitespace.
* Not even leading indentation on blank lines.

## Code organization

```swift
//1. Imports

import UIKit

//2. Clases, structs, enums

class Person {

  //2.1. public, internal properties
  let name: String
  private(set) var oib: Int

  //2.2. private properties
  unowned private let _bankCard: BankCard

  //2.3. Initializers
  init(name: String, bankCard: BankCard)

  //2.4. Public, internal functions
  func hasValidBankCard() -> Bool

  //2.5. Private functions
  private func _setupPerson() -> Void
}

//3. extensions, protocol implementations
extension Person : CustomStringConvertible {

  var description: String {
    return "\(name) has \(bankCard.name) card."
  }
}
```

## Code segmentation

* Use `MARK:`, aka `PRAGMA MARK:`.
* Add one empty row after `MARK`.

## Naming

* Names should be written in lower camel case.
* __Be mindful about grammar!__
* Names should be meaningful and compact.

## Constants

* You should use structs to define your constants. You can even define multiple substructures to break your constants into logical sections.
* The struct's constants are written in lowercase.

```swift
// Definiton
struct Constants {

	struct UserDefaults {
    	static let onboardingPassed = "UserDefaultsOnboardingPassed"
	}

	struct API {
        static let baseURL = "https://www.example.com/api/v1"
	}
}

// Usage
Constants.UserDefaults.onboardingPassed
```

## Comments
* Use comments when code is not self-explanatory:
	* Rx
	* API calls
	* dark magic

## Language

### Preferred

```swift
let color: String = "red"
```

### Not preferred

```swift
let colour:String = "red"
```

_Rationale:_ Use US English spelling to match Apple's API.

## Closures
* If the last argument of the function is a closure, use trailing closure syntax.
* If it's the only argument, parentheses may be omitted.
* Unused closure arguments should be replaced with _ (or fully omitted if no arguments are used).
* In most cases, argument types should be inferred.
* If **capturing self**, always use `[weak self]`.
* If **in doubt**, always use `[weak self]`.

## Closure expressions

### Preferred

```swift
UIView.animate(withDuration: 0.3) { 
    self.myView.alpha = 0
}

UIView.animate(withDuration: 0.3,
    animations: {
        self.myView.alpha = 0
    }, completion: { finished in
        self.myView.removeFromSuperview()
    }
)
```

### Not preferred

```swift
UIView.animate(withDuration: 0.3, animations: {
    self.myView.alpha = 0
})

UIView.animate(withDuration: 0.3, animations: { 
    self.myView.alpha = 0
}) { (finished) in
    self.myView.removeFromSuperview()
}
```

## Prefer `let`-bindings over `var`-bindings wherever possible

Use `let foo = …` over `var foo = …` wherever possible (and when in doubt). Use `var` only if you absolutely have to (i.e., you *know* that the value might change, for example, when using the `weak` storage modifier).

_Rationale:_ The intent and meaning of both keywords is clear, but *let-by-default* results in safer and clearer code.

A `let`-binding guarantees and *clearly signals to the programmer* that its value will never change. Subsequent code can thus make stronger assumptions about its usage.

It becomes easier to reason about code. Had you used `var` while still making the assumption that the value never changed, you would have to manually check that.

Accordingly, whenever you see a `var` identifier being used, assume that it will change and ask yourself why.

## Return and break early

When you have to meet certain criteria to continue execution, try to exit early. So, instead of this:

```swift
if n.isNumber {
    // Use n here
} else {
    return
}
```
use this:

```swift
guard n.isNumber else {
    return
}
// Use n here
```

You can also do it with an `if` statement, but using `guard` is preferred because a `guard` statement without `return`, `break`, or `continue` produces a compile-time error, so exit is guaranteed.

## Avoid using force unwrapping of Optionals

If you have a `foo` identifier of the `FooType?` or `FooType!` type, don't force unwrap it to get to the underlying value (`foo!`) if possible.

Instead, do this:

```swift
if let foo = foo {
    // Use unwrapped `foo` value in here
} else {
    // If appropriate, handle the case where the optional is nil
}
```

Alternatively, you might want to use Swift's Optional Chaining in some of these cases, such as:

```swift
// Call the function if `foo` is not nil. If `foo` is nil, ignore we ever tried to make the call
foo?.callSomethingIfFooIsNotNil()
```

_Rationale:_ Explicit `if let`-binding of Optionals results in safer code. Force unwrapping is more prone to lead to runtime crashes.

## Avoid using implicitly unwrapped Optionals

Where possible, use `let foo: FooType?` instead of `let foo: FooType!` if `foo` may be nil (note that, in general, `?` can be used instead of `!`).

_Rationale:_ Explicit optionals result in safer code. Implicitly unwrapped optionals have the potential of crashing at runtime.

## Prefer implicit getters on read-only properties and subscripts

Omit the `get` keyword on read-only computed properties and
read-only subscripts when possible.

So, write these:

```swift
var myGreatProperty: Int {
  return 4
}

subscript(index: Int) -> T {
    return objects[index]
}
```

… not these:

```swift
var myGreatProperty: Int {
  get {
    return 4
  }
}

subscript(index: Int) -> T {
    get {
        return objects[index]
    }
}
```

_Rationale:_ The intent and meaning of the first version is clear, and it results in less code.

## Always specify access control explicitly for top-level definitions

Top-level functions, types, and variables should always have explicit access control specifiers:

```swift
public var whoopsGlobalState: Int
internal struct TheFez {}
private func doTheThings(things: [Thing]) {}
```

However, the definitions within those can leave access control implicit, where appropriate:

```swift
internal struct TheFez {
  var owner: Person = Joshaber()
}
```

_Rationale:_ It's rarely appropriate for top-level definitions to be specifically `internal`, and being explicit ensures that careful thought is put into that decision. Within a definition, reusing the same access control specifier is just duplicative, and the default is usually reasonable.

## Always associate the colon with the identifier when specifying a type

When specifying the type of an identifier, always put the colon immediately
after the identifier, followed by a space, and then the type name.

```swift
class SmallBatchSustainableFairtrade: Coffee { ... }

let timeToCoffee: TimeInterval = 2

func makeCoffee(type: CoffeeType) -> Coffee { ... }
```

_Rationale:_ The type specifier is saying something about the _identifier_, so
it should be positioned together with it.

Also, when specifying the dictionary type, always put the colon immediately
after the key type, followed by a space, and then the value type.

```swift
let capitals: [Country: City] = [Sweden: Stockholm]
```

## Refer to `self` explicitly only when required

When accessing properties or methods on `self`, leave the reference to `self` implicit by default:

```swift
private class History {
  var events: [Event]

  func rewrite() {
    events = []
  }
}
```

Include the explicit keyword only when required by the language—for example, in a closure, or when the parameter names conflict:

```swift
extension History {
  init(events: [Event]) {
    self.events = events
  }

  var whenVictorious: () -> () {
    return {
      self.rewrite()
    }
  }
}
```

_Rationale:_ This makes the capturing semantics of `self` stand out more in closures, and prevents verbosity elsewhere.

## Prefer structs over classes

Unless you require functionality that can be provided only by a class (like identity or deinitializers), implement a struct instead.

Note that inheritance is (by itself) usually _not_ a good reason to use classes because polymorphism can be provided by protocols, and implementation reuse can be provided through composition.

For example, this class hierarchy:

```swift
class Vehicle {
    let numberOfWheels: Int

    init(numberOfWheels: Int) {
        self.numberOfWheels = numberOfWheels
    }

    func maximumTotalTirePressure(pressurePerWheel: Float) -> Float {
        return pressurePerWheel * Float(numberOfWheels)
    }
}

class Bicycle: Vehicle {
    init() {
        super.init(numberOfWheels: 2)
    }
}

class Car: Vehicle {
    init() {
        super.init(numberOfWheels: 4)
    }
}
```

could be refactored into these definitions:

```swift
protocol Vehicle {
    var numberOfWheels: Int { get }
}

func maximumTotalTirePressure(vehicle: Vehicle, pressurePerWheel: Float) -> Float {
    return pressurePerWheel * Float(vehicle.numberOfWheels)
}

struct Bicycle: Vehicle {
    let numberOfWheels = 2
}

struct Car: Vehicle {
    let numberOfWheels = 4
}
```

_Rationale:_ Value types are simpler, easier to reason about, and they behave as expected with the `let` keyword.

## Make classes `final` by default

Classes should start as `final` and only be changed to allow subclassing if a valid need for inheritance has been identified. Even in that case, as many definitions as possible _within_ the class should be `final` as well, following the same rules.

_Rationale:_ Composition is usually preferable to inheritance, and opting _in_ to inheritance hopefully means that more thought will be put into the decision.


## Omit type parameters where possible

Methods of parameterized types can omit type parameters on the receiving type when they’re identical to the receiver’s. For example:

```swift
struct Composite<T> {
  …
  func compose(other: Composite<T>) -> Composite<T> {
    return Composite<T>(self, other)
  }
}
```

could be rendered as:

```swift
struct Composite<T> {
  …
  func compose(other: Composite) -> Composite {
    return Composite(self, other)
  }
}
```

_Rationale:_ Omitting redundant type parameters clarifies the intent, and makes it obvious by contrast when the returned type takes different type parameters.

## Use whitespace around operator definitions

Use whitespace around operators when defining them. Instead of:

```swift
func <|(lhs: Int, rhs: Int) -> Int
func <|<<A>(lhs: A, rhs: A) -> A
```

write:

```swift
func <| (lhs: Int, rhs: Int) -> Int
func <|< <A>(lhs: A, rhs: A) -> A
```

_Rationale:_ Operators consist of punctuation characters, which can make them difficult to read when immediately followed by punctuation for a type or value parameter list. Adding whitespace separates the two more clearly.

## Forbidden

Types should never have prefixes because their names are already implicitly mangled and prefixed by their module name.

Semicolons are obfuscative and should never be used.
