SwiftLint checks the source code for programmatic as well as stylistic errors. This is most helpful in identifying some common and uncommon mistakes that are made during coding. SwiftLint is based on guidelines from Swift style guide. Simply saying it can just helps us with:

* maintaining a higher level of code discipline and
* increasing the reliability of the code.

## Installation

You can easily install SwiftLint using Homebrew: `$ brew install swiftlint`.

If you have already installed SwiftLint, you can update it to the latest version using the command: `$ brew upgrade swiftlint`

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

And thats it, now SwiftLint will run with the default settings.

## Configuration file

You can find all rules by running `$ swiftlint rules`.

You have the possibility to control which rule is disabled/enabled and to set thresholds for warnings and errors for a given rule, just create a `.swiflint.yml` file and add it to your project root directory.

To disable a rule you add the following to your .yml file:

```yaml
disabled_rules: # rule identifiers to exclude from running
  - force_cast
  - force_unwrappingitespace
  - type_name
```

To customize a rule thresholds for warnings and errors you can add one of the following:

```yaml
force_unwrapping: warning

line_length: 510

type_body_length:
  - 300 # warning
  - 400 # error

file_length:
  warning: 500
  error: 1200
```

You can also exclude some parts of your project like Pods, so SwiftLint won't check them:

```yaml
excluded: # paths to ignore during linting. Takes precedence over `included`.
- Carthage
- Pods
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

It's also possible to modify a disable or enable command by appending `:previous`, `:this` or `:next` for only applying the command to the previous, this (current) or next line respectively.

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

In accordance to our Swift Style Guide and our rules discussion, the configured file can be downloaded here: [SwiftLint configuration.](/resources/.swiftlint.yml)

### Xcode trailing whitespace

By default, Xcode won't remove trailing whitespace if the line is empty. SwiftLint does not like that and you will probably receive some warnings for this. For future coding you should change Xcode settings and set it to automatically remove all trailing whitespace even if the line is empty.

![iOS Trailing whitespace](/img/iOS_xcode_trim_whitespace.png)

*NOTE: This will not automatically fix your SwiftLint warnings you already have, but will prevent it's happening again.*

That's it. Install SwiftLint, add the configuration file to your root directory and lint up your project!
