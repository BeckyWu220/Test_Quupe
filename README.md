# TestFlight Instruction
If you're testing through Test Flight, please ignore the section at the bottom named Test_Quupe (Xcode) directly.
Check your mailbox to receive invitation email send by admin of apple developer account. Download Testflight from App Store and input the redeem code in the invitation email. 

# Test_Quupe (Xcode)

This project is an Objective-C project, which need Xcode to launch and run. Please ensure that you have the Xcode installed first.

This project using CocoaPods to install and maintain frameworks conveniently. In order to run this project please install CocoaPods before launch.

1. To install CocoaPods, please follow the tutorial from https://guides.cocoapods.org/using/getting-started.html.
2. Download or sync the project file. In the project folder, you would find a folder name Pods, which stored all the frameworks that are used in this project.
3. Open Terminal on mac, locate to the project folder using command line like cd /Downloads/Test_Quupe/FireBase_Quupe-Placeholder. 
4. Input command: pod install, in Terminal. You should be able to see the installation of many frameworks.
5. After all frameworks are installed, open the quupe.xcworkspace instead of quupe.xcodeproj to launch the project with Xcode.

To launch the projct to your iOS device.
1. Link the device with Mac.
2. At the left top corner, you should select your device from a dropdown list.
3. Click the play button on the left of the dropdown list to launch the project.
4. You might need to trust the developer from your device if it reminds you to do it. To trust the developer, go Settings->General->Device Managerment, choose Quupe and click Trust. Click the Run button again to launch.


