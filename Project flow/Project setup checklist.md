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

Use [gitignore.io](https://www.gitignore.io/) or [GitHub](https://github.com/github/gitignore). The former one is much easier to use, just make sure to add both **OSX** and **Xcode** along with **Objective-C** or **Swift**.

**Make sure you have a .gitignore before your first commit.** Revising the repo is a bit painful.

## 5. Add a README

Your README should follow a standard layout:

**[badges]**—for example, CircleCI, Codebeat, etc. You can add these after the services have been set up.

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

## 7. Add pods to your project

`pod init` and then add whatever pods you think you’ll want to use. Alamofire is a good start. No matter how simple your project is, there’s a good chance you’ll be needing pods anyway. `pod install` once you're done adding pods.

**KEEP PODS OUT OF YOUR GITIGNORE**

We always want a perfectly functional project in the repo, with the versions of the libs used at a certain point for reference. Bandwidth is cheap. Tracking uncommitted changes is not.

## 8. Add your build scripts, lints, analyzers, etc.

For example, build a number script, SwiftLint, codebeat, or whatever else you might need. More complex projects will need more of these.

Stuff to consider:
1. [SwiftLint](https://github.com/realm/SwiftLint)—a tool to help you keep your Swift code swifty
2. [Codebeat](https://codebeat.co/)—a static analyzer of your code's quality

For both of the above, we already have the default config files for you to use [here]() and [here]().

## 9. Push your project to the repo

After setting everything up properly and making sure that everything works, push your project to the master branch. Until you deploy a build to the App Store, this will be your last commit to the `master`, so onto the next step.

## 10. Set up a GitFlow flow and start working

Create a `development` branch and a feature branch and start working on your project. Ask the team lead once more to protect your `development` branch.

## 11. Set up your configurations (what used to be targets)

TBA

## 12. Get some provisioning profiles

Use the [Developer portal](https://developer.apple.com/) to create app IDs, provisioning profiles, and whatever you'll be needing for deployment.

## 13. Set up your CI

We use [Bitrise](https://www.bitrise.io/) for our continuous integration needs. Automatic deployment beats wasting time for manual builds, and its use is strongly advised.

To set one up, check the CI chapter in the handbook.

## 14. Get them fingers busy

Time to get to work. Happy coding!

# 2. The cookbook abridged

1. Create a new XCode project
2. Create a new repository on GitHub
3. Init a git repo in your project
4. Add a gitignore
5. Add a README
6. Reorganize your project
7. Add pods to your project
8. Add your build scripts, lints, analyzers, etc.
9. Push your project to the repo
10. Set up a GitFlow flow and start working
11. Set up your configurations (what used to be targets)
12. Get some provisioning profiles
13. Set up your CI
14. Get them fingers busy
