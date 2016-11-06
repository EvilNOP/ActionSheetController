# ActionSheetController
Action sheet controller provides a modern as well as good-looking action sheet different with the system.

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Appearance](#appearance)

## Features

- [x] The usage is designed as the same as the UIAlertController

## Requirements

- iOS 8.0+ / macOS 10.11+
- Xcode 8.0+
- Swift 3.0+

## Installation
- Add the ActionSheetController.swift and UIImage+imageWithColor.swift to your project.

## Usage

```swift
let actionSheetController = ActionSheetController(title: "Title!")

let alertAction1 = AlertAction(title: "Alert action one", style: .default, handler: nil)
let alertAction2 = AlertAction(title: "Alert action two", style: .default, handler: nil)
let alertActionCancel = AlertAction(title: "Cancel", style: .cancel, handler: nil)

actionSheetController.addAction(alertAction: alertAction1)
actionSheetController.addAction(alertAction: alertAction2)
actionSheetController.addAction(alertAction: alertActionCancel)
        
present(actionSheetController, animated: true, completion: nil)

```

## Appearance
![Screenshot](https://github.com/EvilNOP/ActionSheetController/Screenshot.png)