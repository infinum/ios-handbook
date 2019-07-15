## Nested subscribes

One of the most important things that you'll likely run into at some point is chaining observables. With closures, you're familiar with this. When one closure completes, we simply call another function in its completion. We then keep chaining function as we need until inevitably creating a pyramid of doom.

Thankfully, Rx offers us a solution for that. Whenever you need to chain a "closure", that is, an observable in this case - you'll want to use an operator. We've talked a lot about that operator and you may have guessed it, it's `flatMap`. Using operators like this lets us write code vertically, following the same indentation level. This helps us to completely avoid pyramid of doom and just generally improve code readability.

You will never, ever, absolutely never want a subscribe that's nested inside of another subscribe. Doing things that way defeats the purpose of using Rx, since the point is to use it differently from closures. You'll only ever want one subscribe, after you're done with all of the operators that are needed for a single sequence.

If you feel like you need to go down this road, you're likely doing something wrong - so give it another thought.

## Observable to Single

Converting between signals is something that's used quite a lot. One of the main advantages of different types of Rx signals is to be more explicit of the work that's being done. For instance, an API call can almost always be a `Single` since once you request something from the server, you'll only ever expect either a response or an error. That means that only one _(single)_ event will flow down the observable sequence.

In case that multiple signals try to flow down that sequence (for instance, you hook to a server through sockets), conversion to `Single` will always fail.
This also greatly helps debugging, since in such instances you'll be aware right away that something has either gone horribly wrong or that maybe `Single` isn't something you'd use in that case.

However, there's a catch. If you have a sequence that sends multiple events it will _throw an exception_ when casting to `Single`. Also, it's important to note that if you filter those events, you won't see the exception! Example:

```swift
Observable.of(1, 2, 3)
    .skip(1)
    .asSingle()
    .subscribe()
```

We're created an observable and emit a few events through it. The first signal is skipped and the `Observable` is converted to `Single`. At first glance, this looks correct. You'll be able to build the app just fine and you won't be seeing any errors thrown in the console - so we're free to assume that everything works ok, right?
Well, we are, but we would be in the wrong here. What happens is - it'll actually skip the first event, but the sequence itself _knows_ that there are more events in there and that the first one was simply skipped.

Because of that, conversion to `Single` will _**silently**_ fail. You won't get an error in this case, nothing would blow up, the only thing you'll notice is that anything after that call simply wouldn't execute. Putting a `.debug()` also won't help because we effectively aren't doing anything wrong, `.asSingle()` receives a single event and doesn't mention anything about it being an observable grammar error.

If this gets wrapped deeper down in the code it can and will end up being quite a pain to debug, so be mindful in cases such as this!

A simple solution to the above code would look like this:

```swift
Observable.of(1, 2)
    .take(1)
    .asSingle()
    .subscribe()
```

Now, in this case single will only ever receive a single event which will be either success or an error, and will terminate after that. Conversion to `Single` in this case succeeds and everything is good in the world again.

To recap - it's worth noting that even if `.asSingle()` receives a singular event, although the sequence had multiple events which were filtered in any way, it will fail without really giving you a heads up.
In this particular case the sequence needs to send only one event and it needs to be either a success event or an error.

## Share

You have an API call that's used for two different actions. If you simply do something like this:

```swift
let result = interactor.apiCall()

result.map { $0.model }.subscribe()
result.map { $0.model.nestedModels }.subscribe()
```

You might not notice it right away, but if you go out your way to put a `.debug()`, you might notice that you api call will be triggered *twice*. What happens is that on each subscription you're essentially getting a new stream of data. If you decide to add further mapping on the stream, you'll make it even worse, as it'll end up basically being an additional _subscription_ since the stream will be duplicated each time.

This is pretty bad, right? Well, thankfully, we have `share` operator which comes in our rescue.

>So what'll happen is, `share` will _share_ the resources of a specific stream and pass that *same* stream to all of its subscribers.

Don't let that sentence scare you - if we simplify that statemenet a bit, we can say:

>After using share on a specific Rx sequence, the part before the share operator will become a shared stream. That stream itself will execute only once, and each subscriber will simply get a result from that exact
stream without performing any further actions.

In our specific case this means that the API call will only be fired off once - and all that it brings back will be sent down through the sequence to all of subscriptions!

```swift
let result = interactor.apiCall().share()
```

And that fixes all of our issues, neat, right?

## Nested calls error handling (flatMaps, etc.)

One common issue that you'll experience sooner or later is that a nested operation, inside of a larger sequence might fail. That'll then contribute to a chain reaction which'll propagate all the way through to your topmost Rx sequence which will end with an error, too.
In most instances, that isn't good because if your main sequence dies (for instance, a sequence that generates your items) it means that no further actions will be available from that point.

Debugging might prove difficult in this case because the most obvious approach would be to put a `.debug()` before your last subscribe to see what happens. In cases where there's a lot of additional trasnformations happening, catching this issue can become a real pain to debug.

For instance:

```swift
interactor.apiCall()
    .map(Model.init)
    .flatMap { [unowned interactor] model in
        interactor.getNestedModels(from: model)
    }
    .subscribe()
```

In the above given case, the nested `getNestedModels(from:)` call might fail breaking the rest of the sequence, without giving a _proper_ error that would be easy for you to catch.
That's why you always want to remember your nested but failable calls, whether to API or any other parts of the app, that might fail.

Also, an important note that doing something like this will _**NOT**_ fix your issue:

```swift
interactor.apiCall()
    .map(Model.init)
    .flatMap { [unowned interactor] model in
        interactor.getNestedModels(from: model)
    }
    .subscribe()
    .catchErrorJustReturn([])
```

Catching the error in the outer sequence is not something that'll stop the issue from happening. It's important to catch that at the *the call site* of your failable sequence. In this example it would be the inner sequence, i.e. the block of the `flatMap` operator.

In order to prevent this from going haywire, we'll simply need to catch the error when doing the said API call.

```swift
interactor.apiCall()
    .map(Model.init)
    .flatMap { [unowned interactor] model in
        interactor.getNestedModels(from: model).catchErrorJustReturn([])
    }
    .subscribe()
```

This is something that we can work with. Do note that you'll still need an outer error catching mechanism in case that your initial `apiCall` fails, through which we create the model in this case. This is one of the most
important things that you need to keep on your mind while chaining requests. (Besides the capture list!)

## Completable chaining

Sometimes you'll simply want to execute an action and get notified when it completes, without actually wanting any sort of response other than that. In those instances you'll want to use a `Completable` trait.
Essentially, what completable does differently in comparison to a regular `Observable`, `Driver` or a `Single` is - that when the job is done, it completes.

That's great, right? Well, yes - unless you need to chain something after that operation. Why? Well, because the signal _**completes**_, therefore ends up being disposed.
You might be wondering how is that useful now - but in some cases where all you care is for example an upload or download, it'll do more than enough.

But fret not, there's an operator to save us from that, too and it's called `andThen()`. This comes in handy when you need to display a message or navigate somewhere, or just keep your sequence alive once the operation finishes.

Using the operator, you can effectively chain anything you want just like with a normal `Observable`:

```swift
Completable.empty()
    .andThen(Observable.just("Operation completed!"))
    .subscribe()
```

Just like that, your sequence will still be alive and well and you can keep chaining other operations on to it as you like.

If you take a second to compare this to an existing operator, you'll soon see that it's essentially the same thing as `flatMap`. The main difference between the two is that `andtThen` is semantically more correct to use when you work with a `Completable`.

## Subjects, Relays and memory leaks

We've mentioned that passing `Subjects` or `Relays` from a child module into the parent module and storing them there is not a good idea. At first, it might not seem like a bad idea and that is perfectly reasonable. However, if you store a subject or a relay from your parent module in a child, as a property, you're essentially storing that into an object that has a different lifecycle from the object where it was created.

Why does that matter? Well, because that different object will also have its `DisposeBag`, to which you'll add your `Disposables` which will include any Rx sequences derived from that `Subject` or a `Relay`.

What does that mean? Since it was stored, given a value and added into the `DisposeBag`, due to how `Relays` and `Share` in RxSwift works, it will end up clutching onto the last value it stored, _even when the child module deallocates, cleaning up resources from it's `DisposeBag`!_.

Why does that happen? Because the subject itself came from a different object, that is still alive and well, along with its `DisposeBag`. It's still holding value internally and depending on the size of the value it stored that might end up being a larger or a smaller leak.
Of course, this will _fix itself_ once the parent object completely deallocates, but for the time being it will end up consuming additional memory. In case of larger objects, that might build up quite a bit or eventually even cause weird bugs because of _value replay_.

Another example of that would also be any cell, in case that you decide to store your `DisposeBag` in its item/presenter. However, due to how cells work, `DisposeBag` in almost all instances ends up being in a cell since we also need to take care of the `prepareForReuse` calls, which we've already covered in previous parts of the handbook.

To sum it all up, keep your subjects in the scope of your functions (preferably the configure functions) and pass it around without storing it between objects with different lifecyles.
