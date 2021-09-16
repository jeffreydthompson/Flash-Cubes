# Flash-Cubes
Flash Cubes education app

## Table of contents
* [General info](#general-info)
* [Technologies](#technologies)
* [Setup](#setup)

## General info
This project is an education app that employs the [Anki](https://en.wikipedia.org/wiki/Anki_(software)) learning technique.  Competitor software creates flashcards which challenges a learner to recall the opposite of a given prompt.  This app offers several prompts to enhance the learning experience.  A picture can be a prompt to recall a sound, or a character, or phrase.  Or vice versa.  As a learner improves, they can go from easy recall prompts to more difficult to solidify the memory associations created.
	
[Preview video](https://firebasestorage.googleapis.com/v0/b/flash-cubes.appspot.com/o/FlashCubesAppPreview5.5.mp4?alt=media&token=fca580d1-d544-4baf-bb6b-0d2902ef43c5)
  
## Technologies
Project is created with:
* XCode 10
* Swift 5
* UIKit
* Firebase
	
## Setup
To run this project, first install Google Firebase using cocoapods:

In terminal:
```
$ cd ../FlashCubes
$ pod init
$ open podfile
```

Edit the pod file and save:
```
  # Pods for FlashCubes
  pod 'Firebase/Auth'
  pod 'Firebase/Database'
  pod 'Firebase/Storage'
```
Install from terminal:
```
$ pod install
```
