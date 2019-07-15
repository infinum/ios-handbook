# Naming style

## Observables, drivers and the rest of the observable types

In most instances we want to ditch `observable` from our object names and treat these in the following way:

* Input that we get from the VC - `events`
* Output that we send into the VC from the presenter - `actions`

Not Preferred:

```swift
let buttonTapObservable: Observable<Void>
let itemsObservable: Observable<Void>
```

Preferred:

```swift
let buttonTap: Observable<Void>
let items: Observable<Void>
```

## Relays and subjects

An exception to this are `Relays` and `Subjects`. Since they aren't only meant to be read and can accept values, keeping `Relay` and `Subject` in the name helps to immediatelly recognize their context.

```swift
let modelUpdateSubject = BehaviorSubject<Model?>(value: nil)
let formEditsRelay = BehaviorRelay<Model>(value: model)
```

## Actions grouping

Actions which can be grouped should be organized as such. For instance, we've mentioned `events` and `actions` that are sent between our module components.
In instances where we can do that, a simple `struct` wrapper works wonders to help you out organizing the code, if ever so slightly.

An example of that would look like the following:

```swift
struct Actions = (
    save: Observable<Void>,
    cancel: Observable<Void>,
    ...
)
```

```swift
struct Events = (
    ...
)
```

We delcare these in our namespace `struct`, not to polute the rest of the project. Afterwards, simply use them in our default I/O approach during the initial binding:

```swift
struct ViewOutput {
    let actions: Actions
}
```

```swift
struct ViewInput {
    let events: Events
    let items: Observable<Item>
}
```

>Note: In cases where it makes no sense to group actions, e.g. `let items: Observable<Item>` in the above example, it is only important to follow the very first part of the naming section. That includes deciding on a property name, while omitting the observable _type_ from the name.

## Presenters' bind function

We should strive towards the exact same name for the bind function, along with its parameters. Please use the following in your projects:

```swift
presenter.configure(with output: Module.ViewOutput) -> Module.ViewInput
```

## Handle functions

Considering that all of the actions we need to handle will end up in the given `configure` function, we'll need to format the code appropriatelly so that we don't end up with a _"Massive View Controller"_ configure function.
General template that we follow is to use `handle` functions, which will transform our data and then either _subscribe_ or _return the value_. Example:

```swift
func configure(with output: Module.ViewOutput) -> Module.ViewInput {

    _handle(action: output.action)

    let result = _handle(action: output.action)

    return Module.ViewInput(
        result: result
    )
}
```

Depending on the action name and whether it conflicts with an already given name, for instance `_handle(viewDidLoad: output.viewDidLoad)`, we can make use of labels to further identify what are we going to do in the `handle` function. In those instances we would use the _viewActionWith_ label.
