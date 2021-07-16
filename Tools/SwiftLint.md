SwiftLint checks the source code for programmatic as well as stylistic errors. This is helpful in identifying some common and uncommon mistakes that are made during coding. SwiftLint is based on guidelines from the Swift style guide. To put it simply, it can help us with:

* maintaining a higher level of code discipline
* increasing the code's reliability

## Installation

You can easily install SwiftLint using Homebrew: `$ brew install swiftlint`.

If you have already installed SwiftLint, you can update it to the latest version using the `$ brew upgrade swiftlint` command.

*NOTE: Please update Homebrew to the latest version before installing and updating SwiftLint:* `$ brew update`.

## Running in Xcode

If you want to integrate SwiftLint to Xcode, add the following script to your target:

```bash
if which swiftlint >/dev/null; then
	swiftlint
else
	echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
```

### Example

![iOS SwiftLint Run script](/img/iOS-SwiftLint-script.jpg)

And that's it. SwiftLint will now run with default settings.

## Configuration file

You can find all rules by running `$ swiftlint rules`.

You have the possibility to control which rule is disabled/enabled and set thresholds for warnings and errors for a given rule. Just create a `.swiflint.yml` file and add it to your project root directory.

You need to change the `ProjectNameTests`  to the name of your Tests folder in the Project.

To disable a rule, comment it out from the list of `only_rules` and it will not be included in the linting process. However, if you do so, leave a note detailing why the rule is disabled for future reference and as a reminder that in the end the project should be updated to accommodate the new rules.

To customize a rule threshold for warnings and errors, go to the end of the file and change `warning` and `error` properties of the rule. If the rule is not present at the file end, just add it with your customization.

You can also exclude some parts of your project, such as Pods, so SwiftLint won't check them:

```yaml
excluded: # paths to ignore during linting. Takes precedence over `included`.
- Carthage
- Pods
- ProjectNameTests
```

## Disable a rule in code

Rules can be disabled with a comment inside a source file with the following format:

```swift
// swiftlint:disable <rule>
```

The rule will be disabled until the end of the file or until the linter sees a matching enable comment:

```swift
// swiftlint:enable <rule>
```

For example:

```swift
// swiftlint:disable colon
let noWarning :String = "" // No warning about colons immediately after variable names!
// swiftlint:enable colon
let hasWarning :String = "" // Warning generated about colons immediately after variable names
```

It's also possible to modify a disable or enable command by appending `:previous`, `:this`, or `:next` to apply the command only to the previous, this (the current), or the next line.

For example:

```swift
// swiftlint:disable:next force_cast
let noWarning = NSNumber() as! Int
let hasWarning = NSNumber() as! Int
let noWarning2 = NSNumber() as! Int // swiftlint:disable:this force_cast
let noWarning3 = NSNumber() as! Int
// swiftlint:disable:previous force_cast
```

*NOTE: Do not overuse this!*

### iOS SwiftLint rules

In accordance with our Swift Style Guide and our rules discussion, the configured file can be downloaded here: [SwiftLint configuration.](/resources/swiftlint.yml)

### Xcode trailing whitespace

By default, Xcode won't remove trailing whitespace if the line is empty. SwiftLint does not like that, and you will probably receive some warnings for this. For future coding, you should change Xcode settings and set it to automatically remove all trailing whitespace even if the line is empty.

![iOS trailing whitespace](/img/iOS_xcode_trim_whitespace.png)

*NOTE: This will not automatically fix the SwiftLint warnings you've already received, but it will prevent them from repeating.*

That's it. Install SwiftLint, add the configuration file to your root directory, and lint up your project!
