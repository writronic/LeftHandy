# Contributing to LeftHandy

Thanks for your interest in contributing to LeftHandy! Here's how you can help.

Before starting any work, please check the [issue tracker](https://github.com/writronic/LeftHandy/issues) to avoid duplicates and to see if someone is already working on it. For significant changes, open an issue first to discuss the approach.

## Bug Reports & Feature Requests

Use the Bug Report or Feature Request template when opening a new issue. Search existing issues first — including closed ones — to avoid duplicates.

## Contribution Workflow

1. Fork and clone the repository.
2. Open `LeftHandy.xcodeproj` in Xcode 16+.
3. Create a feature branch from `main`.
4. Commit your changes, test them, and push to your fork.
5. Open a Pull Request against `main` using the [PR template](PULL_REQUEST_TEMPLATE.md).

Tips for your pull request:

- Submit separate PRs for separate features — avoid bundling unrelated changes.
- Don't include unintended file changes (e.g. `project.pbxproj` signing identity changes).
- If `main` has been updated before your change was merged, rebase your branch:
  ```sh
  git rebase upstream/main
  ```

## Guidelines

- Stay consistent with the [macOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/macos/).
- Use SwiftUI for UI work; Objective-C/C for low-level system APIs.
- Keep changes focused and well-tested.
- Add comments when necessary.

Thank you for helping make LeftHandy better!
