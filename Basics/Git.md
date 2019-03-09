## 1. Preface

![Git][image-1]

**Thou shalt use 2FA everywhere where we use Git!**

## 2. GitFlow

This section describes only the basics of the GitFlow workflow. Check out a detailed description [here][1] if you want more information.

The basic idea of using GitFlow workflow:

![Gitflow workflow][image-2]

### 2.1. Branch explanations

#### 2.1.1. Master

The **Master** branch is used to represent your App Store builds. Each commit in the master branch represents one app version in the App Store, and each one of them is tagged with the version in the App Store. Use `git tag <app-store-version-number> && git push --tags` to create a new tag.

#### 2.1.3. Develop

**Develop** is the lifeline of your project. You’ll want this branch up-to-date at all times, and this is the branch you should branch from almost every time you add a feature, enhancement, and other branches.

Once your feature branch is ready, tested, and working, you submit a pull request here.

#### 2.1.4. Feature branches

**Feature branches** are what you’ll be doing on the project. Try to make your branches as atomic as possible, and keep only as little change as possible in each of them. These are new features, enhancements, fixes, etc.

At any given point in time, only one developer should be actively working on one of these branches.

Once more, you should submit a pull request to *develop* only when everything is tested, working, and not breaking the project. Once it has been approved, close your branch down and start working on a new one.

## 3. GitFlow for small projects

In order to keep things rolling faster, small projects also use GitFlow, but to a very limited extent.

For one-man projects, you will have only the **master** and **develop** branches, and will commit your code directly to develop, while the master stays the same.

If there is more than one developer, you'll need a standard GitFlow model.

## 4. Tools (optional)

Although you don’t need to use any tools with GitFlow workflow, and may prefer sticking to the workflow manually, you still have an option to add commands to your console/terminal for commonly used workflows.

If you want to use Git with Gitflow commands and terms, you might find the [git-flow][2] tool useful.

[1]:	https://www.atlassian.com/git/tutorials/comparing-workflows#gitflow-workflow
[2]:	https://github.com/nvie/gitflow

[image-1]:	http://imgs.xkcd.com/comics/git.png "Git"
[image-2]:	/img/iOS-Gitflow.png
