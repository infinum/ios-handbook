## 1. Preface

![Git][image-1]

**Thou shalt use 2FA everywhere where we use Git!**

## 2. SSH keys

Before you start with Git, we encourage you to [connect to GitHub][1] or Bitbucket with SSH keys. First of all, you need to [generate a public/private SSH key pair][2], then add the public part to GitHub and Bitbucket accounts. 

Using SSH key you’ll be able to manage (clone, push, pull..) private repositories without entering your email/username password each time you need to perform an operation on the remote repository.

## 3. Creating a repository

Repo name should follow naming conventions below:

* **technology-client-project-name** for example: ios-infinum-connect, android-infinum-ispitivaci, js-infinum-design-islands, rails-infinum-labs
 * You should skip the client name in repo name if it is the same as project name, for example: ios-mBank
* or **type-client-project-name** if repo is not technology related, for example specification-isp-my-isp

The only allowed characters are [a-z0-9] and -. This way we will make our DevOps’ life easier.

## 4. Gitconfig

You should set **username** and **email** properties in your gitconfig file which are then shown in each commit you create. Those can be set by executing the following commands:
* git config --global user.name "FirstName LastName"
* git config --global user.email "firstName.lastName@infinum.com"

## 5. Git usage

### Branch naming
As mentioned, branch name should be lowercase. Words in branch names should be splitted with **hyphens** and not underscores. Also, when possible, task id from Productive/Jira should be included in branch name. For example:
* feature/123-add-followers-button
* hotfix/1337-recipe-details-crash

### Commits

In general, commits should be small and frequent - “Commit early, commit often”. You should follow the single responsibility principle in git. Whenever possible include task number in commit message, e.g.:”#123: Fix screen title”, this helps a lot in the future when another person needs to know why you had to implement it that way.

The important thing is that changes should be described in imperative mood, e.g. "Make xyzzy do frotz" instead of "[This patch] makes xyzzy do frotz" or "[I] changed xyzzy to do frotz", as if you are giving orders to the codebase to change its behavior.

When writing commit messages we should stick to these 7 rules:
1. Separate subject from body with a blank line
2. Limit the subject line to 50 characters (easier to read on client)
3. Capitalize the subject line
4. Do not end the subject line with a period
5. Use the imperative mood in the subject line
6. Wrap the body at 72 characters
7. Use the body to explain what and why vs. how
8. You can find more details about those in [this blog post][3].

There is also a [git hook][4] available to validate your commit message.

## 6. Pull requests

The preferred way of merging a branch back into `master` is by creating a pull request and assigning it to a colleague for review. At least one person should review any code that is going to be merged (reviewer on PR).

Each PR should have a description. Link to the Productive/Jira task is minimum for description. It would be great to include a link to design (if applicable) and describe the changes that PR introduces. You can find a good read on what the description should contain [here][5].

PR should have an assignee, which is usually a person who created a PR or the person who will be responsible for merging it. 

Master and/or release branches should always be marked as protected on Github in order to prevent direct push to those branches. Next options should be checked on the branch protection rules page on Github:
* ***Require pull request reviews before merging***
![Pull request][image-2]
* ***Require status check to pass before merging (this includes Bitrise CI and/or SonarCloud if used)***
![Status chec][image-3]
* ***Require branches to be up to date before merging***
![Branches][image-4]

## 7. Mobile specific

Above mentioned rules should be the minimum for all platforms. Few more are specific and applicable only for mobile platforms. If you cannot apply some of the mentioned rules to your project, please talk with another platform and try to find a viable solution for both of you.

### Git Flow/Infinum Flow

We’ll be using the Git Flow standard as a base for git branching with some modifications. More about Git Flow [here][6].

#### Branches
We’ll be using **master** as the main branch. Since we’ll be using tags and optionally **release** branches for deployment, **develop** branch becomes redundant and therefore should not be used in the project.

The main branches in this flow are:
* **master**
  * It is a main branch
  * anything in the master branch is deployable
  * is stable and it is always, always safe to deploy from it or create new branches off of it
  * feature and hotfix branches are merged into it only after pull request review is done
* **release**
  * used for parallel development (e.g. multiple versions of the app when version 1.0.0 is developed on master, version 1.1.0 can be a next ***release/1.1.0/*** or for developing multiple features that should or shouldn’t be in the same version: ***release/separate-cool-feature***)
  * same rules as for the master branch
* **feature**
  * used for developing new features / adding new functionality to the app
  * branches off of master/release
  * has prefix ***feature/***, e.g. feature/123-add-followers-button
* **fix**
  * used for fixing non-critical production bugs or bugs occurred in development phase
  * has prefix ***fix/***, e.g. fix/123-wrong-cards-sorting
* **refactor**
  * used for codebase/project refactoring
  * Has prefix ***refactor/***, e.g. refactor/123-alert-and-action-sheet
* **hotfix**
  * used for fixing critical bugs in production
  * may be branched off from the corresponding tag and create PR to the ***master*** or to the latest ***release*** branch if one exists
  * has prefix ***hotfix/***, e.g. hotfix/1337-recipe-details-crash
  * Example usage: there is a bug on app version 1.2.0. In that case you checkout to a commit tagged with v1.2.0. You create release/1.2.1 branch from that tag, and you create hotfix/whatever from that branch where you implement the fix and create PR back to the release/1.2.1 branch
 
#### Pull requests
Each pull request must have an automatic check - running tests or just building the app if your project doesn’t have tests. Setup on GitHub is described in general rules of this handbook, while on how to set up Bitrise Checks on projects you have [Android][7] and [iOS][8] handbook chapters.

#### Deployment
Deployment is done via tags and Bitrise CI/CD. Here are the chapters on setting up Bitrise on your project: [Android][7] and [iOS][9].

Sync with another platform as much as possible. Few stuff that should be defined and synced:
* Environment names - staging, production, uat, beta… whatever is convention on project, but should be the same. Exception probably will be iOS with its production and app store environments due to technical limitations. If using TryOutApps, please sync environment names.
* Build number/code version - Must be numbers only value. For build number you can use tag count (prefer using with [build script](10)) or commit count if tag count is unavailable (could be fetched with `git rev-list HEAD --count` from deploy script and bitrise has global variable `$GIT_CLONE_COMMIT_COUNT` that could be used). 
* Tag names - tags (used for tagging the TryOutApps version and/or triggering Bitrise CI) should be comprised of three parts: environment, app version with ***v*** prefix and build number/code version, e.g. ***internal-staging/v1.2.3-1234***
  * Each project will have different environments so this will be heavily project dependent, but some suggestions: tags should have prefix like ***internal-staging/***, ***internal-production/***, ***appstore/***... Due to limitation on tag triggers on Bitrise, tags with multiple / are not permitted, so you should use something like ***internal-production/***, ***internal-staging/***.
  * Use ***internal-*** prefix for all tags which will trigger internal builds on TryoutApps. The reason behind it: internal tags are not so relevant and one should clear internal tags from time to time to keep the project clean.
  * All the production versions that have been published to the app/play store should be tagged with one extra tag in order to have a better overview of released versions. Tag should look like this: ***v1.2.3*** (without build number).

[1]:  https://help.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh
[2]:  https://help.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
[3]:  https://chris.beams.io/posts/git-commit/
[4]:  https://github.com/m1foley/fit-commit
[5]:  https://infinum.com/handbook/books/rails/git-process#github-pull-request-descriptions
[6]:  https://nvie.com/posts/a-successful-git-branching-model/
[7]:  https://infinum.com/handbook/books/android/bitrise
[8]:  https://infinum.com/handbook/books/ios/bitrise-ci/pull-request-ci-check
[9]:  https://infinum.com/handbook/books/ios/bitrise-ci/general-intro
[10]: https://github.com/infinum/app-deploy-script

[image-1]:	http://imgs.xkcd.com/comics/git.png "Git"
[image-2]:	/img/iOS-pull-request.png
[image-3]:	/img/iOS-status-check.png
[image-4]:	/img/iOS-branches-up-to-date.png
