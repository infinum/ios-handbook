<div class="markdown-output__summary">
  Creating a new project from scratch is a rather simple task, but more often than not, you'll forget a tidbit or two, so here's a useful list to keep in mind. Use common sense—not all of these are necessary for every project. Also, when in doubt, ask someone to give you a hand.
</div>

## 1. Create a new Xcode project

Make sure the product name is something sane and easy to read. Spaces might be a pain in the ass, so keep that in mind (dashes instead of spaces is a better option). The organization identifier should be **Infinum**.

The Bundle ID should be something like co.infinum.my-app-dev. This might change for production, depending on whose account is being used for the App Store.

## 2. Create a new repository on GitHub

GitHub admin access is limited to team leads only. Find the nearest one and twist their arm until they opens up a new repo for you. :)

## 3. Init a git repo in your project

You can either use *git init* in the project folder or clone an empty repo and move your project there (or even create it inside after cloning). The latter option will ensure that the folder structure is consistent with anyone else's who might be working on the project.

## 4. Add a gitignore

Use [gitignore.io](https://www.gitignore.io/) or [GitHub](https://github.com/github/gitignore). The former one is much easier to use, just make sure to add both **macOS** and **Xcode** along with **Objective-C** or **Swift**.

**Make sure you have a .gitignore before your first commit.** Revising the repo is a bit painful.

## 5. Add a README

Your README should follow a standard layout:

**[badges]**—for example, BitriseCI, cocoapods, swift version, min iOS version, etc. You can add these after the services have been set up.

**[project architecture]**—just a quick overview of the project architecture and style.

**[gotchas]**—keep everything important about the project that might not be immediately clear here. Even if it is, keep it here. For example, "To test this project, you need credentials from www.credentials.com, ask Hrvatko about them", or: "This project keeps some lib in GitHub LFS, make sure you have it installed before pulling, or check the documentation to find out how to do it afterwards."

## 6. Reorganize your project

The Xcode default folder structure almost never works for you. This is the perfect time to sort everything into a neater little package. The project structure should look like this:

```
├── Application
│   ├── AppDelegate.swift
│   ├── Constants.swift
│   └── Intializers
│       └── Initializable.swift
├── Common
│   ├── API
│   ├── Extensions
│   ├── Views
│   └── VIPER
├── Modules
│   ├── Home
│   │   └── Home.storyboard
│   │   ├── HomeInteractor.swift
│   │   ├── HomeInterfaces.swift
│   │   ├── HomePresenter.swift
│   │   ├── HomeViewController.swift
│   │   └── HomeWireframe.swift
├── Resources
│   └── Assets.xcassets
└── Supporting Files
    ├── Base.lproj
    │   └── LaunchScreen.storyboard
    └── Info.plist
```

Keep your Xcode structure in sync with the folder structure on a disk. This means that every group in Xcode should be a folder on the disk.

## 7. Adding Shaman to the project

Shaman is a gem that we use which provides a nice CLI to setup **TryOutApps deployment**. 

It takes care of the configuration that's needed for the script to work for you. All you have to do is, prepare a project on TryOutApps and set up your environments.

Once that's done, running `shaman init` will lead you through a few simple steps and afterwards, generate a `shaman.yml` for you.

The file itself contains your `environments`, `release_path` per environment and a `token` that's used to communicate with the API.

During said steps, you'll be asked for your user token, which you can find on [TryOutApps](https://infinum.tryoutapps.com/users/me).

Everything else related to the installation and usage of Shaman, you can find [here](https://github.com/infinum/shaman).

### Common issues

During shaman installation you might end up running into potential issues due to some of the changes that were made to the MacOS file system. If these do happen, an error that you'll likely see will be:

```
Building native extensions. This could take a while...
ERROR:  Error installing shaman:
ERROR: Failed to build gem native extension.
```
This likely means that your Ruby version is outdated, so a simple update to a newer version will fix that. It's highly recommended to use RVM instead of manual gem updates because RVM allows you to specify the version that you'd like to use.

To get it working, use the following commands:

```bash
# Installs RVM
\curl -sSL https://get.rvm.io | bash -s stable 

# Install the desired Ruby version (replace $VERSION with an actual value)
rvm install ruby-$VERSION

# Set your desired version as the default (replace $VERSION with an actual value)
rvm --default use $VERSION
```

>Note: In case that you encunter permission errors when, in case that the installation wants to go into `/usr/bin`, please replace the installation target to `/usr/local/bin`.

With that in place, you shouldn't have issues with the shaman installation.

## 8. Add pods to your project

`pod init` and then add whatever pods you think you’ll want to use. Alamofire is a good start. No matter how simple your project is, there’s a good chance you’ll be needing pods anyway. `pod install` once you're done adding pods.

**KEEP PODS OUT OF YOUR GITIGNORE**

We always want a perfectly functional project in the repo, with the versions of the libs used at a certain point for reference. Bandwidth is cheap. Tracking uncommitted changes is not.

## 9. Add your build scripts, lints, analyzers, etc.

For example, build a number script, SwiftLint, or whatever else you might need. More complex projects will need more of these.

To keep your code clean and up to date with the latest coding style standards, add [SwiftLint](https://github.com/realm/SwiftLint) into your project. Consider installing the SwiftLint from the `brew` and then just add those few lines into the build phases:

```bash
if which swiftlint >/dev/null; then
  swiftlint
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
```

You can find the default config file for the SwiftLint [here](https://infinum.com/handbook/resources/ios/swiftlint.yml).

## 10. Add Crashlytics

To keep your app crash-free, keep an eye on those critical and noncritical bugs. Ask your client to open and create a new project on the Firebase and add [Crashlytics](https://firebase.google.com/products/crashlytics?gclid=CjwKCAiAp4KCBhB6EiwAxRxbpD2i1jOpCyendfMB7uPu8-cJEbpfX7CVPDI8p8pHXh72kgjLNO2srBoCegEQAvD_BwE&gclsrc=aw.ds) to the project. Implementation is fairly easy, just follow [few simple steps](https://firebase.google.com/docs/crashlytics/get-started) and make your app better!

## 11. Push your project to the repo

After setting everything up properly and making sure that everything works, push your project to the master branch. Until you deploy a build to the App Store, this will be your last commit to the `master`, so onto the next step.

## 12. Set up a GitFlow flow and start working

Create a `master` branch and a feature branch and start working on your project. Ask the lead engineer once more to protect your `master` and `release/*` branch.

## 13. Set up your schemes and configurations

Schemes are there to define different environments in our case. Each target should have at least one scheme to define a blueprint for the entire build process. That being said, each scheme can then have configurations that describe what build settings are to be used for the scheme (debug, release, etc.).

Ideally, a project should have a single or multiple targets, depending on the use case (the app itself, app extensions, etc.) which are then described by the mentioned schemes and configurations.

To set things up and read more about it, check out the [Custom xcconfigs chapter](https://infinum.com/handbook/books/ios/project-flow/custom-xcconfigs).

## 14. Get some provisioning profiles

Use the [Developer portal](https://developer.apple.com/) to create app IDs, provisioning profiles, and whatever you'll be needing for deployment.

## 15. Set up your CI

We use [Bitrise](https://www.bitrise.io/) for our continuous integration needs. Automatic deployment beats wasting time for manual builds, and its use is strongly advised.

To set one up, check the CI chapter in the handbook.

## 16. Get them fingers busy

Time to get to work. Happy coding!

# 2. The cookbook abridged

1. Create a new XCode project
2. Create a new repository on GitHub
3. Init a git repo in your project
4. Add a gitignore
5. Add a README
6. Reorganize your project
7. Install shaman and configure deployment
8. Add pods to your project
9. Add your build scripts, lints, analyzers, etc.
10. Add Crashlytics
11. Push your project to the repo
12. Set up a GitFlow flow and start working
13. Set up your configurations (what used to be targets)
14. Get some provisioning profiles
15. Set up your CI
16. Get them fingers busy
