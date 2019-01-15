## 1. Preface

![Git][image-1]

**Thou shalt use 2FA everywhere where we use Git!**

## 2. Git flow

This section describes only basics of the Gitflow workflow. Check detailed description [here][1] if you want more information.

Basic idea how to use Gitflow workflow:

![Gitflow workflow][image-2]

### 2.1. Branch explanations

#### 2.1.1. Master

**Master** branch is used to represent your App Store builds. Each commit in the master branch represents one app version in the App Store, and each one of them is tagged with the version in the App Store. Use `git tag <app-store-version-number> && git push --tags` to create a new tag.

#### 2.1.3. Develop

**Develop** is the lifeline of your project. You’ll want this branch up to date at all times, and this is the branch you should branch from almost always when adding your feature, enhancement and other branches.

Once your feature branch is ready, tested and working, you submit a pull request here.

#### 2.1.4. Feature branches

**Feature branches** are what you’ll be doing on the project. Try to make your branch as atomic as possible, and keep only as little change as possible in each of them. These are new features, enhancements, fixes etc.

At one point, only one developer should be actively working on one of these branches.

Once more, only, and only when everything is tested working and not breaking the project, you should submit a pull request to *develop*, and once it’s approved, close your branch down and start working on a new one.

## 3. Git flow for small projects

In order to keep things rolling faster, small projects still use git flow, but a very limited one.

For one man projects, you will only have **master** and **develop** branches, and commit your code directly to develop, while the master stays the same.

If there are more developers than one, a standard git flow model is the kind you’re looking.

## 4. Tools (optional)

Although you don’t need any tools to be used with Gitflow workflow, and may prefer sticking to the workflow manually, you still have an option to add commands for commonly used workflows to your console/terminal.

If you want to use git with Gitflow commands and terms, you might find useful this tool: [git-flow][2]

[1]:	https://www.atlassian.com/git/tutorials/comparing-workflows#gitflow-workflow
[2]:	https://github.com/nvie/gitflow

[image-1]:	http://imgs.xkcd.com/comics/git.png "Git"
[image-2]:	/img/iOS-Gitflow.png
