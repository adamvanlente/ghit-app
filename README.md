## Ghit

ghit is a native iOS app for GitHub users.  It takes advantage of the GitHub api, allowing users to update and create new issues on their repos quickly and easily.


### Using ghit

Ghit can be used by any GitHub user with existing repositories.  ghit does not (as of v1.0.1) allow you to create repos from within the app.

###### Two Factor Authentication

Users with 2FA enabled will be prompted for their auth code after attempting login with their username/password.  The flow is identical to a browser-based login.

###### Organization Repos

As of v1.0.1 users can access repos for all of their member organizations.  These repos can be hidden/revealed using a toggle in the settings screen.


### Libraries used by ghit

ghit uses cocoapods to manage its libraries.  If cloning this repo, be sure to run <code>pod install</code> before opening the project in xcode.

##### Octokit
ghit uses GitHub's objective c library, Octokit.  All GitHub api requests are run through this library.  Several methods were added to Octokit where needed, for instance, to add comments to issues.

##### MMMarkdown
Since GitHub allows users to write their comments in Markdown, this library was brought in to make sure that user's comments are printed correctly on the screen.
