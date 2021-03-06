# Speasy

## Introduction

Speasy is an ios mobile app which helps people with speech difficulties. Speasy uses the speech recognition API to recognize user’s voice. It will predict the potential words in the later conversation and in the future, it will play out the sentence with user’s own voice.

## Deployment Instruction
1. Clone this repository:
`git clone https://github.com/Realmonia/Speasy-ver2.0.git`

2. Open `brad3.xcodeproj` in Xcode.

3. Connect your iOS device to your Mac.

4. In `Product > Destination`, select your iOS device as the destination.

5. Click `Product > Run` (or `Command+R`) to build and run the app.

6. If a code signing issue occurs, you can fix the issue by following [the instructions from Apple developer site](https://developer.apple.com/library/content/documentation/IDEs/Conceptual/AppDistributionGuide/ConfiguringYourApp/ConfiguringYourApp.html#//apple_ref/doc/uid/TP40012582-CH28-SW7 "configuring-your-app guide").

## How to use
1. Select a scene and press “Confirm”.  
You will enter the speech recognition view. 

2. When you are ready to speak, press “Start”.  
The app will begin to recognize speech and predict the next word. 

3. Select one of the four word choices.  
The word you choose will appear on the screen. 

## Support
Currently this app supports iPhone X. The app will support all different kinds of iPhones in the next release.

## FAQ
* If you encounter a question when building the project, complaining "'GRDBCipher/sqlite3.h' file not found", that is a xcode issue. Please go to your xcode and follow: <br>
Product >> Scheme >> Manage Schemes >> add a new scheme named "GRDBCipher" and then rebuild the whole project. Everything should work well now.
