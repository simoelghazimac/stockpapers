# StockPapers
> Beautiful iOS wallpaers app

### Index
- [The idea behind](#The-idea-behind)
- [Contribute](#Contribute)
	- [New Features](#new-features)
	- [Commits](#Commits)
- [Building](#Building)
- [License](#License)
<!-- - [Screenshots](#screenshots) -->

# 💡 The idea behind the app
I made that app just for learn Swift development and best practice. Now I made this open-source because I thought that would be useful to someone that just like it has been for me.

# 🚀 Contribute
Contributors are always welcome! 
Please make sure to follow the [**contributing guidelines**](#contributing-guidelines) before submitting a new PR.

## Contributing Guidelines
Please give a priority to the TODOs tag in the issues page.

- ### New Features
> Every new feature should have a separate branch.

If you want to add new features you're welcome! Please before start coding make sure to create a new issue, describe it and wait for a manteiner approval. Every `non approved` PR will be closed.


- ### Commits
	- Each commit should have a single clear purpose. If a commit contains multiple unrelated changes, those changes should be split into separate commits.
	- If a commit requires another commit to build properly, those commits should be squashed.
	- Follow-up commits for any review comments should be squashed. Do not include "Fixed PR comments", merge commits, or other "temporary" commits in pull requests.

# 🏗️ Build
> ⚠️ **This project requires Xcode 10** ⚠️
1. Install the latest [Xcode developer tools](https://developer.apple.com/xcode/downloads/) from Apple.
2. Install Carthage
	```sh
		brew update
		brew install carthage
	```
3. Clone the repo:
	```sh
		git clone https://github.com/rawnly/stockpapers
	```

4. Pull in the project dependecies:
	```sh
		cd stockpapers
		carthage update --platform=ios
	```
5. Open `StockPapers.xcodeproj` in Xcode
6. Build/Run

# License
This project is under [`GNU GPL 3.0`](LICENSE)

